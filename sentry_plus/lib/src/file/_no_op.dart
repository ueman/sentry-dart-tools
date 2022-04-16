import 'package:sentry/sentry.dart';

void addFileTracing(SentryOptions options) {
  options.logger(
    SentryLevel.info,
    'This platform does not support file tracing. Doing a no op.',
  );
}
