import 'package:sentry/sentry.dart';
import '_io.dart' if (dart.library.html) '_no_op.dart' as http_tracer;

extension SentryHttpExtension on SentryOptions {
  /// Must be called outside the RunZoneGuardedIntegration.
  /// Otherwise the HttpOverrides aren't attached to the root zone.
  void addHttpTracing() => http_tracer.addHttpTracing(this);
}
