import 'package:gql_error_link/gql_error_link.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:sentry/sentry.dart';
import 'extension.dart';

/// Provides a `Link` which captures exceptions and GraphQL errors
class SentryLink {
  /// Provides a `Link` which captures exceptions and GraphQL errors
  static ErrorLink link({
    Hub? hub,
    bool reportExceptions = true,
    bool reportExceptionsAsBreadcrumbs = false,
    bool reportGraphQlErrors = true,
    bool reportGraphQlErrorsAsBreadcrumbs = false,
  }) {
    hub = hub ?? HubAdapter();

    final handler = SentryLinkHandler(
      hub: hub,
      reportExceptions: reportExceptions,
      reportExceptionsAsBreadcrumbs: reportExceptionsAsBreadcrumbs,
      reportGraphQLErrors: reportGraphQlErrors,
      reportGraphQlErrorsAsBreadcrumbs: reportGraphQlErrorsAsBreadcrumbs,
    );

    return ErrorLink(
      onException: handler.onException,
      onGraphQLError: handler.onGraphQlError,
    );
  }
}

// See https://github.com/gql-dart/gql/blob/master/links/gql_error_link/lib/gql_error_link.dart
class SentryLinkHandler {
  const SentryLinkHandler({
    required this.hub,
    required this.reportExceptions,
    required this.reportExceptionsAsBreadcrumbs,
    required this.reportGraphQLErrors,
    required this.reportGraphQlErrorsAsBreadcrumbs,
  });

  final Hub hub;

  final bool reportExceptions;
  final bool reportExceptionsAsBreadcrumbs;

  final bool reportGraphQLErrors;
  final bool reportGraphQlErrorsAsBreadcrumbs;

  Stream<Response>? onGraphQlError(
    Request request,
    NextLink forward,
    Response response,
  ) async* {
    final errors = response.errors;
    if (errors == null) {
      yield response;
      return;
    }
    if (reportGraphQlErrorsAsBreadcrumbs) {
      hub.addBreadcrumb(Breadcrumb(
        level: SentryLevel.error,
        category: 'GraphQLError',
        type: 'error',
        data: {
          'request': request.toJson(),
          'response': response.toJson(),
        },
      ));
    } else if (reportGraphQLErrors) {
      final exceptions = errors.toSentryExceptions(request, response);
      if (exceptions.isNotEmpty) {
        // try to format it nicely
        await hub.captureEvent(
          SentryEvent(
            exceptions: response.errors?.toSentryExceptions(request, response),
            level: SentryLevel.error,
          ),
        );
      } else {
        // we couldn't format it nicely
        await hub.captureEvent(
          SentryEvent(
            exceptions: response.errors?.toSentryExceptions(request, response),
            level: SentryLevel.error,
            contexts: Contexts()
              ..['GraphQL'] = <String, dynamic>{
                'request': request.toJson(),
                'response': response.toJson(),
              },
          ),
        );
      }
    }
    yield response;
  }

  Stream<Response>? onException(
    Request request,
    NextLink forward,
    LinkException exception,
  ) async* {
    if (reportExceptionsAsBreadcrumbs) {
      hub.addBreadcrumb(Breadcrumb(
        message: exception.toString(),
        level: SentryLevel.error,
        category: 'LinkException',
        type: 'error',
        data: request.toJson(),
      ));
    } else if (reportExceptions) {
      await hub.captureException(
        exception,
        withScope: (scope) {
          scope.contexts['GraphQL'] = <String, dynamic>{
            'request': request.toJson(),
          };
        },
      );
    }
    yield* Stream.error(exception);
  }
}
