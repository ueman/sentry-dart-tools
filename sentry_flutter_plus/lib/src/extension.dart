import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_flutter_plus/sentry_flutter_plus.dart';
import 'package:sentry_flutter_plus/src/integrations/exclude_integrations.dart';

extension SentryFlutterPlus on SentryFlutterOptions {
  void addSentryFlutterPlus({
    // Sentry Flutter Plus
    bool automaticInAppExcludes = true,
    bool platformMenuIntegration = true,
    bool evenMoreEventEnrichment = true,
  }) {
    if (evenMoreEventEnrichment) {
      addEventProcessor(FlutterEventProcessor());
      addEventProcessor(LinuxEventProcessor());
      addEventProcessor(WindowsEventProcessor());
      addEventProcessor(ExceptionEventProcessor(this));
    }

    if (automaticInAppExcludes) {
      addIntegration(ExcludeIntegration());
    }
    if (platformMenuIntegration) {
      addIntegration(PlatformMenuIntegration());
    }
  }
}
