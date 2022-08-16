import 'package:dart_frog/dart_frog.dart';
import 'package:sentry_dart_frog/src/error_middleware.dart';
import 'package:sentry_dart_frog/src/tracing_middleware.dart';

/// Add automatic error reporting and performance tracing, if enabled.
Handler sentryMiddleware(Handler innerHandler) {
  return innerHandler
      .use(sentryErrorMiddleware)
      .use(sentryPerformanceMiddleware);
}
