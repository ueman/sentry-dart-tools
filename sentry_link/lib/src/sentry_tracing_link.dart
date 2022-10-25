import 'dart:async';

import 'package:gql/ast.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:sentry/sentry.dart';

class SentryTracingLink extends Link {
  /// If [shouldStartTransaction] is set to true, an [SentryTransaction]
  /// is automatically created for each GraphQL query/mutation.
  /// If a transaction is already bound to scope, no [SentryTransaction]
  /// will be started even if [shouldStartTransaction] is set to true.
  SentryTracingLink({
    required this.shouldStartTransaction,
    Hub? hub,
  }) : _hub = hub ?? HubAdapter();

  final Hub _hub;
  final bool shouldStartTransaction;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    assert(
      forward != null,
      "This is not a terminating link and needs a NextLink",
    );

    final isQuery = request.isQuery;

    // See https://develop.sentry.dev/sdk/performance/span-operations/
    final operation = isQuery ? 'http.graphql.query' : 'http.graphql.mutation';
    final type = isQuery ? 'query' : 'mutation';

    final transaction = _startSpan(
      "GraphQL $type ${request.operation.operationName ?? 'unnamed'}",
      operation,
      shouldStartTransaction,
    );
    return forward!(request).transform(StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        transaction?.finish(status: const SpanStatus.ok());
        sink.add(data);
      },
      handleError: (error, stackTrace, sink) {
        // Error handling can be significantly improved after
        // https://github.com/gql-dart/gql/issues/361
        // is done.
        // The correct `SpanStatus` can be set on
        // `HttpLinkResponseContext.statusCode` or
        // `DioLinkResponseContext.statusCode`
        transaction?.throwable = error;
        transaction?.finish(status: const SpanStatus.unknownError());

        sink.addError(error, stackTrace);
      },
    ));
  }

  ISentrySpan? _startSpan(
    String op,
    String description,
    bool shouldStartTransaction,
  ) {
    final span = _hub.getSpan();
    if (span == null && shouldStartTransaction) {
      return _hub.startTransaction(description, op);
    } else if (span != null) {
      return span.startChild(op, description: description);
    }
    return null;
  }
}

// Can be removed when
// https://github.com/gql-dart/gql/issues/360
// is fixed.
extension on Request {
  OperationType get type {
    final definitions = operation.document.definitions
        .whereType<OperationDefinitionNode>()
        .toList();
    if (operation.operationName != null) {
      definitions.removeWhere(
        (node) => node.name!.value != operation.operationName,
      );
    }

    assert(definitions.length == 1);
    return definitions.first.type;
  }

  bool get isQuery => type == OperationType.query;
}
