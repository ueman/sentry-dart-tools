import 'package:dart_frog/dart_frog.dart';
import 'package:sentry/sentry.dart';

/// Middleware for performance tracing
Handler sentryPerformanceMiddleware(Handler innerHandler) {
  // ignore: invalid_use_of_internal_member
  if (!Sentry.currentHub.options.isTracingEnabled()) {
    return innerHandler;
  }
  return (context) async {
    Response response;
    final trx = Sentry.startTransaction(
      context.request.uri.toString(),
      'http',
      bindToScope: true,
    );
    try {
      response = await innerHandler(context);
      trx.status = SpanStatus.fromHttpStatusCode(response.statusCode);
    } catch (e) {
      trx
        ..throwable = e
        ..status = const SpanStatus.internalError();
      rethrow;
    } finally {
      await trx.finish();
    }
    return response;
  };
}
