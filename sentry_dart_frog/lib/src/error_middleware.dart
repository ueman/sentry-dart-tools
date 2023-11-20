import 'package:sentry/sentry.dart';
import 'package:dart_frog/dart_frog.dart';

/// Middleware which does performance tracing and error handling
Handler sentryErrorMiddleware(Handler innerHandler) {
  return (context) async {
    try {
      // If innerHandler isn't awaited, the error isn't caught by the try-catch
      return await innerHandler(context);
    } catch (exception, stackTrace) {
      final mechanism = Mechanism(
        type: 'MiddlewareErrorHandler',
        handled: false,
      );
      final throwableMechanism = ThrowableMechanism(mechanism, exception);

      final event = SentryEvent(
        throwable: throwableMechanism,
        // ignore: invalid_use_of_internal_member
        transaction: Sentry.currentHub.options.isTracingEnabled()
            ? null
            : context.request.uri.toString(),
        level: SentryLevel.fatal,
        request: SentryRequest(
          method: context.request.method.value,
          headers: context.request.headers,
          cookies: context.request.headers['Cookies'],
          url: context.request.uri.path,
          queryString: context.request.url.query,
          fragment: context.request.url.fragment,
        ),
      );
      await Sentry.captureEvent(event, stackTrace: stackTrace);
      rethrow;
    }
  };
}
