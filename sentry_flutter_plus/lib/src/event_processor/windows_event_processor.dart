import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class WindowsEventProcessor implements EventProcessor {
  WindowsEventProcessor({Hub? hub}) : _hub = hub ?? HubAdapter();

  final Hub _hub;
  // ignore: invalid_use_of_internal_member
  SentryFlutterOptions get _options => _hub.options as SentryFlutterOptions;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  @override
  FutureOr<SentryEvent?> apply(SentryEvent event, {dynamic hint}) async {
    if (!_options.platformChecker.platform.isWindows) {
      return event;
    }
    final windowsInfo = await _deviceInfo.windowsInfo;

    final contexts = event.contexts.copyWith(
      operatingSystem:
          _getOperatingSystem(event.contexts.operatingSystem, windowsInfo),
      device: _getDevice(event.contexts.device, windowsInfo),
    );

    return event.copyWith(
      contexts: contexts,
    );
  }

  SentryOperatingSystem _getOperatingSystem(
    SentryOperatingSystem? os,
    WindowsDeviceInfo info,
  ) {
    return (os ?? const SentryOperatingSystem()).copyWith(
      build: info.buildNumber.toString(),
      name: info.productName,
      version: info.displayVersion,
    );
  }

  SentryDevice _getDevice(
    SentryDevice? device,
    WindowsDeviceInfo info,
  ) {
    return (device ?? const SentryDevice()).copyWith(
      name: info.computerName,
      processorCount: info.numberOfCores,
      // memorySize is bytes
      memorySize: info.systemMemoryInMegabytes * 1024 * 1024,
    );
  }
}
