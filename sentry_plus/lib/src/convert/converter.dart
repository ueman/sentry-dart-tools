// ignore_for_file: invalid_use_of_internal_member, unused_field

import 'dart:convert';

import 'package:sentry/sentry.dart';

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
    return innerConverter.convert(input);
  }

  @override
  Converter<S, TT> fuse<TT>(Converter<T, TT> other) {
    return innerConverter.fuse(other);
  }

  @override
  Sink<S> startChunkedConversion(Sink<T> sink) {
    return innerConverter.startChunkedConversion(sink);
  }
}
