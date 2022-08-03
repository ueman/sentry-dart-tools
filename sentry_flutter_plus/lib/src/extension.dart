import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_flutter_plus/src/event_processor/flutter_event_processor.dart';
import 'package:sentry_flutter_plus/src/event_processor/linux_event_processor.dart';
import 'package:sentry_flutter_plus/src/event_processor/windows_event_processor.dart';
import 'package:sentry_flutter_plus/src/integrations/exclude_integrations.dart';
import 'package:sentry_flutter_plus/src/integrations/platform_menu_integration.dart';
import 'package:sentry_plus/sentry_plus.dart';

extension SentryFlutterPlus on SentryFlutterOptions {
  void addSentryFlutterPlus({
    // Sentry Plus
    bool addFileTracing = true,
    bool addHttpTracing = true,
    bool addUnhandledEventProcessor = true,
    // Sentry Flutter Plus
    bool automaticInAppExcludes = true,
    bool platformMenuIntegration = true,
    bool evenMoreEventEnrichment = true,
    bool methodChannelTracing = true,
  }) {
    addSentryPlus(
      addFileTracing: addFileTracing,
      addHttpTracing: addHttpTracing,
      addUnhandledEventProcessor: addUnhandledEventProcessor,
    );

    if (evenMoreEventEnrichment) {
      addEventProcessor(FlutterEventProcessor());
      addEventProcessor(LinuxEventProcessor());
      addEventProcessor(WindowsEventProcessor());
    }

    if (automaticInAppExcludes) {
      addIntegration(ExcludeIntegration());
    }
    if (platformMenuIntegration) {
      addIntegration(PlatformMenuIntegration());
    }

    if (methodChannelTracing) {
      removeIntegration(integrations.firstWhere(
          (element) => element is WidgetsFlutterBindingIntegration));
    }
  }
}
