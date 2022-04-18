import 'package:sentry/sentry.dart';
import 'package:sentry_plus/src/event_processor/unhandled_event_processor.dart';
import 'file/file_extension.dart';
import 'http/http_extension.dart';

extension AddAllExtension on SentryOptions {
  void addSentryPlus({
    bool addFileTracing = true,
    bool addHttpTracing = true,
    bool addUnhandledEventProcessor = true,
  }) {
    if (addFileTracing) {
      this.addFileTracing();
    }
    if (addHttpTracing) {
      this.addHttpTracing();
    }
    if (addUnhandledEventProcessor) {
      addEventProcessor(UnhandledEventProcessor());
    }
  }
}
