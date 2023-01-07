import 'package:sentry/sentry.dart';
import 'package:sentry_plus/src/event_processor/unhandled_event_processor.dart';
import 'http/http_extension.dart';
import 'integration/in_app_integration.dart';

extension AddAllExtension on SentryOptions {
  /// Add all automatic integrations
  void addSentryPlus({
    bool addHttpTracing = true,
    bool addUnhandledEventProcessor = true,
    bool inAppIntegration = true,
  }) {
    if (addHttpTracing) {
      this.addHttpTracing();
    }
    if (addUnhandledEventProcessor) {
      addEventProcessor(UnhandledEventProcessor());
    }
    if (inAppIntegration) {
      addAutomaticInApp();
    }
  }
}
