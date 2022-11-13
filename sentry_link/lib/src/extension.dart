import 'dart:convert';

import 'package:gql/ast.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:sentry/sentry.dart';
import 'package:gql/language.dart' show printNode;

extension GraphQLErrorListX on List<GraphQLError> {
  List<SentryException> toSentryExceptions(Request request, Response response) {
    return map((e) => e.toSentryException(response, request))
        .where((element) => element != null)
        .whereType<SentryException>()
        .toList();
  }

  List<SentryException> toSentryExceptionsWithoutRequest(Response response) {
    return map((e) => e.toSentryExceptionWithoutRequest(response))
        .where((element) => element != null)
        .whereType<SentryException>()
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
      // It's common that GraphQL errors have an extension with an error code
      // therefore try to use it.
      type: extensions?['code']?.toString() ?? message,
      value: message,
      mechanism: Mechanism(type: 'GraphQlError', data: extensions),
      stackTrace: SentryStackTrace(
        frames: [
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
        ],
      ),
    );
  }

  SentryException? toSentryExceptionWithoutRequest(Response response) {
    return SentryException(
      // It's common that GraphQL errors have an extension with an error code
      // therefore try to use it.
      type: extensions?['code']?.toString() ?? message,
      value: message,
      mechanism: Mechanism(type: 'GraphQlError', data: extensions),
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

// Can be removed when
// https://github.com/gql-dart/gql/issues/360
// is fixed.
extension RequestTypeExtension on Request {
  OperationType get type {
    final definitions = operation.document.definitions
        .whereType<OperationDefinitionNode>()
        .toList();
    if (definitions.length != 1 && operation.operationName != null) {
      definitions.removeWhere(
        (node) => node.name!.value != operation.operationName,
      );
    }

    assert(definitions.length == 1);
    return definitions.first.type;
  }

  bool get isQuery => type == OperationType.query;
}
