// ignore_for_file: invalid_use_of_internal_member, unused_field

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
    final span = _hub.getSpan()?.startChild('serialize');
    if (span == null || !_options.isTracingEnabled()) {
      return innerCodec.decode(encoded);
    }
    span.setData('conversion', 'convert from type "$S" to type "$T"');
    T converted;
    try {
      converted = innerConverter.convert(input);
      span.status = const SpanStatus.ok();
    } catch (e) {
      span.throwable = e;
      span.status = SpanStatus.internalError();
      rethrow;
    } finally {
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
