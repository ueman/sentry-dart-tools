import 'package:sentry/sentry.dart';

void addHttpTracing(SentryOptions options) {
  options.logger(
    SentryLevel.info,
    'This platform does not support http tracing. Doing a no op.',
  );
}
