import 'package:gql_error_link/gql_error_link.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:sentry/sentry.dart';
import 'extension.dart';

class SentryLink {
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
  ) {
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
    } else {
      if (reportGraphQLErrors) {
        hub.captureEvent(
          SentryEvent(
            message: SentryMessage('GraphQL Error'),
            level: SentryLevel.error,
            extra: {
              'request': request.toJson(),
              'response': response.toJson(),
            },
          ),
          withScope: (scope) {
            scope.extra['graphQlRequest'] = request.toJson();
          },
        );
      }
    }

    return null;
  }

  Stream<Response>? onException(
    Request request,
    NextLink forward,
    LinkException exception,
  ) {
    if (reportExceptionsAsBreadcrumbs) {
      hub.addBreadcrumb(Breadcrumb(
        message: exception.toString(),
        level: SentryLevel.error,
        category: 'LinkException',
        type: 'error',
        data: request.toJson(),
      ));
    } else {
      if (reportExceptions) {
        hub.captureException(
          exception,
          withScope: (scope) {
            scope.extra['graphQlRequest'] = request.toJson();
          },
        );
      }
    }
    return null;
  }
}
