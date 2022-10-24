import 'dart:async';

import 'package:sentry/sentry.dart';
import 'package:graphql/client.dart';
// ignore: implementation_imports
import 'package:graphql/src/core/result_parser.dart';

class SentryQueryResult<TParsed> implements QueryResult<TParsed> {
  // ignore: invalid_use_of_internal_member
  SentryQueryResult(this._inner, {Hub? hub}) : _hub = hub ?? HubAdapter();

  final QueryResult<TParsed> _inner;
  final Hub _hub;

  @override
  Context get context => _inner.context;

  @override
  set context(Context c) => _inner.context = c;

  @override
  Map<String, dynamic>? get data => _inner.data;

  @override
  set data(Map<String, dynamic>? d) => _inner.data = d;

  @override
  OperationException? get exception => _inner.exception;

  @override
  set exception(OperationException? e) => _inner.exception = e;

  @override
  ResultParserFn<TParsed> get parserFn => _inner.parserFn;

  @override
  set parserFn(ResultParserFn<TParsed> fn) => _inner.parserFn = fn;

  @override
  QueryResultSource? get source => _inner.source;

  @override
  set source(QueryResultSource? s) => _inner.source = s;

  @override
  DateTime get timestamp => _inner.timestamp;

  @override
  set timestamp(DateTime time) => _inner.timestamp = time;

  @override
  bool get hasException => _inner.hasException;

  @override
  bool get isConcrete => _inner.isConcrete;

  @override
  bool get isLoading => _inner.isLoading;

  @override
  bool get isNotLoading => _inner.isNotLoading;

  @override
  bool get isOptimistic => _inner.isOptimistic;

  @override
  TParsed? get parsedData {
    final span = _hub.getSpan()?.startChild(
          'serialize',
          description: 'Serializing from JSON to ${(TParsed).toString()}',
        );
    TParsed? result;
    try {
      result = _inner.parsedData;
      span?.status = const SpanStatus.ok();
    } catch (e) {
      span?.status = const SpanStatus.internalError();
      span?.throwable = e;
      rethrow;
    } finally {
      unawaited(span?.finish());
    }
    return result;
  }
}
