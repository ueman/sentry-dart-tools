import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_plus/sentry_plus.dart';

extension SentryFlutterPlus on SentryFlutterOptions {
  void addSentryFlutterPlus({
    // Sentry Plus
    bool addFileTracing = true,
    bool addHttpTracing = true,
    bool addUnhandledEventProcessor = true,
  }) {
    addSentryPlus(
      addFileTracing: addFileTracing,
      addHttpTracing: addHttpTracing,
      addUnhandledEventProcessor: addUnhandledEventProcessor,
    );
  }
}
