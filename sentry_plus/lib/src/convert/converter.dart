// ignore_for_file: invalid_use_of_internal_member, unused_field

import 'dart:async';
import 'dart:convert';

import 'package:sentry/sentry.dart';
import 'extension.dart';

class SentryConverter<S, T> implements Converter<S, T> {
  final Hub _hub;
  final SentryOptions _options;
  final Converter<S, T> innerConverter;

  SentryConverter(this._hub, this.innerConverter) : _options = _hub.options;

  @override
  Stream<T> bind(Stream<S> stream) => innerConverter.bind(stream);

  @override
  Converter<RS, RT> cast<RS, RT>() => innerConverter.cast();

  @override
  T convert(S input) {
    final span = _hub.getSpan()?.startChild(
          'serialize',
          description: 'convert from type "$S" to type "$T"',
        );
    if (span == null || !_options.isTracingEnabled()) {
      return innerConverter.convert(input);
    }
    T converted;
    try {
      converted = innerConverter.convert(input);
      span.status = const SpanStatus.ok();
    } catch (e) {
      span.throwable = e;
      span.status = SpanStatus.internalError();
      rethrow;
    } finally {
      // It's only needed to be awaited if it's a transaction.
      // Since we're not creating a transaction, no need to await it.
      unawaited(span.finish());
    }
    return converted;
  }

  @override
  Converter<S, TT> fuse<TT>(Converter<T, TT> other) {
    return innerConverter.fuse(other).wrapWithTraces();
  }

  @override
  Sink<S> startChunkedConversion(Sink<T> sink) {
    return innerConverter.startChunkedConversion(sink);
  }
}
