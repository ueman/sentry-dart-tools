import 'dart:convert';

import 'package:gql_exec/gql_exec.dart';
import 'package:sentry/sentry.dart';
import "package:gql/language.dart" show printNode;

extension GraphQLErrorListX on List<GraphQLError> {
  SentryEvent toSentryEvent(Request request) {
    return SentryEvent(
      message: SentryMessage('GraphQlError'),
      level: SentryLevel.error,
      extra: _toMap(request),
    );
  }

  Breadcrumb toBreadcrumb(Request request) {
    return Breadcrumb(
      level: SentryLevel.error,
      category: 'GraphQLError',
      type: 'error',
      data: _toMap(request),
    );
  }

  Map<String, dynamic> _toMap(Request request) {
    return {
      'errors': map((e) => e.toJson()).toList(),
      'request': request.toJson(),
    };
  }
}

extension GraphQLErrorX on GraphQLError {
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'locations':
          locations?.map((e) => {'line': e.line, 'column': e.column}).toList(),
      'paths': path?.map((e) => e.toString()).toList(),
      'extensions': extensions,
    };
  }
}

extension RequestX on Request {
  Map<String, dynamic> toJson() {
    return {
      'operation': operation.toJson(),
      'variables': variables,
    };
  }
}

extension ResponseX on Response {
  Map<String, dynamic> toJson() {
    return {
      'errors': errors?.map((e) => e.toJson()).toList(),
      'data': data,
    };
  }
}

extension OperationX on Operation {
  Map<String, dynamic> toJson() {
    return {
      'name': operationName,
      'document': json.encode(printNode(document)),
    };
  }
}

extension FooBar on GraphQLError {
  SentryException toSentryException() {
    final frames = locations
        ?.map(
          (e) => SentryStackFrame(
            colNo: e.column,
            lineNo: e.line,
            rawFunction: path?.join('.'),
            inApp: true,
            vars: Map.fromEntries(
              extensions?.entries.map(
                    (e) => MapEntry<String, String>(
                        e.key, e.value?.toString() ?? ''),
                  ) ??
                  [],
            ),
          ),
        )
        .toList(growable: false);

    SentryStackTrace? stackTrace;
    if (frames != null) {
      stackTrace = SentryStackTrace(
        frames: frames,
      );
    }
    return SentryException(
      type: 'GraphQL Error',
      value: message,
      stackTrace: stackTrace,
    );
  }
}
