import 'package:dart_frog/dart_frog.dart';
import 'package:sentry/sentry.dart';

/// Middleware for performance tracing
Handler sentryPerformanceMiddleware(Handler innerHandler) {
  // ignore: invalid_use_of_internal_member
  if (!Sentry.currentHub.options.isTracingEnabled()) {
    return innerHandler;
  }
  return (context) async {
    // see https://develop.sentry.dev/sdk/performance/#header-sentry-trace

    final urlDetails =
        // ignore: invalid_use_of_internal_member
        HttpSanitizer.sanitizeUrl(context.request.url.toString());

    var description = context.request.method.toString();

    if (urlDetails != null) {
      description += ' ${urlDetails.urlOrFallback}';
    }

    final traceHeaderValue = context.request.headers['sentry-trace'];
    final baggageHeaderValue = context.request.headers['baggage'];

    SentryTransactionContext? trxContext;

    if (traceHeaderValue != null) {
      trxContext = SentryTransactionContext.fromSentryTrace(
        description,
        'http.client',
        SentryTraceHeader.fromTraceHeader(traceHeaderValue),
        baggage: baggageHeaderValue != null
            ? SentryBaggage.fromHeader(baggageHeaderValue)
            : null,
      );
    }

    Response response;
    final trx = trxContext != null
        ? Sentry.startTransactionWithContext(trxContext, bindToScope: true)
        : Sentry.startTransaction(
            description,
            'http.client',
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
