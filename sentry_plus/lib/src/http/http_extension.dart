import 'package:sentry/sentry.dart';
import '_io.dart' if (dart.library.html) '_no_op.dart' as http_tracer;

extension SentryHttpExtension on SentryOptions {
  void addHttpTracing() => http_tracer.addHttpTracing(this);
}
