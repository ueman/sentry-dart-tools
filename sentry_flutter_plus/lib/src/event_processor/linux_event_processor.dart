import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LinuxEventProcessor implements EventProcessor {
  LinuxEventProcessor({Hub? hub}) : _hub = hub ?? HubAdapter();

  final Hub _hub;
  // ignore: invalid_use_of_internal_member
  SentryFlutterOptions get _options => _hub.options as SentryFlutterOptions;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  @override
  FutureOr<SentryEvent?> apply(SentryEvent event, {dynamic hint}) async {
    if (!_options.platformChecker.platform.isLinux) {
      return event;
    }
    final linuxInfo = await _deviceInfo.linuxInfo;

    final contexts = event.contexts.copyWith(
      operatingSystem:
          _getOperatingSystem(event.contexts.operatingSystem, linuxInfo),
    );

    return event.copyWith(
      contexts: contexts,
    );
  }

  SentryOperatingSystem _getOperatingSystem(
    SentryOperatingSystem? os,
    LinuxDeviceInfo info,
  ) {
    return (os ?? const SentryOperatingSystem()).copyWith(
      build: info.buildId,
      name: info.prettyName,
      version: info.version,
    );
  }
}
