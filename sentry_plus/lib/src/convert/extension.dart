import 'dart:convert';

import 'package:sentry/sentry.dart';
import 'package:sentry_plus/src/convert/converter.dart';
import 'codec.dart';

extension WrapCodec<S, T> on Codec<S, T> {
  /// Wrap a codec to add performance tracing
  Codec<S, T> wrapWithTraces() {
    return SentryCodec<S, T>(HubAdapter(), this);
  }
}

extension WrapConvert<S, T> on Converter<S, T> {
  /// Wrap a converter to add performance tracing
  SentryConverter<S, T> wrapWithTraces() {
    return SentryConverter<S, T>(HubAdapter(), this);
  }
}
