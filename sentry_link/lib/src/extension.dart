import 'dart:convert';

import 'package:gql_exec/gql_exec.dart';
import 'package:sentry/sentry.dart';
import 'package:gql/language.dart' show printNode;

extension GraphQLErrorListX on List<GraphQLError> {
  List<SentryException> toSentryExceptions(Request request, Response response) {
    return map((e) => e.toSentryException(response, request))
        .where((element) => element != null)
        .cast<SentryException>()
        .toList();
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

  SentryException? toSentryException(Response response, Request request) {
    final locations = this.locations;
    if (locations == null) {
      return null;
    }
    final contextLineNumber = locations.first.line - 1;
    final contextLineColumn = locations.first.column;
    final lines = printNode(request.operation.document).split('\n');
    final contextLine = lines[contextLineNumber];
    return SentryException(
      type: message,
      value: message,
      mechanism: Mechanism(type: 'GraphQlError', data: extensions),
      stackTrace: SentryStackTrace(frames: [
        SentryStackFrame(
          fileName: request.operation.operationName ?? 'Unnamed Query',
          lineNo: contextLineNumber,
          colNo: contextLineColumn,
          preContext: lines.take(contextLineNumber).toList(),
          contextLine: contextLine,
          postContext: lines.skip(contextLineNumber + 1).toList(),
          vars: request.variables
              .map((key, value) => MapEntry(key, value.toString())),
          inApp: false,
          platform: 'other',
        )
      ]),
    );
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
