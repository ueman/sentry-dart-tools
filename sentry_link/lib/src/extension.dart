import 'dart:convert';

import 'package:gql/ast.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:sentry/sentry.dart';
import 'package:gql/language.dart' show printNode;

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

  SentryRequest toSentryRequest() {
    return SentryRequest(
      apiTarget: 'graphql',
      data: {
        'query': printNode(operation.document),
        'variables': variables,
        'operationName': operation.operationName
      },
    );
  }
}

extension ResponseX on Response {
  Map<String, dynamic> toJson() {
    return {
      'errors': errors?.map((e) => e.toJson()).toList(),
      'data': data,
    };
  }

  SentryResponse toSentryResponse() {
    return SentryResponse(
      data: {
        'errors': errors?.map((e) => e.toJson()).toList(),
        'data': data,
      },
    );
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
