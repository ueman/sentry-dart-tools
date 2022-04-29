import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:battery_plus/battery_plus.dart';

class FlutterEventProcessor implements EventProcessor {
  FlutterEventProcessor({Hub? hub}) : _hub = hub ?? HubAdapter();

  final Hub _hub;
  // ignore: invalid_use_of_internal_member
  SentryFlutterOptions get _options => _hub.options as SentryFlutterOptions;
  final Battery battery = Battery();

  @override
  FutureOr<SentryEvent?> apply(SentryEvent event, {dynamic hint}) async {
    final contexts = event.contexts.copyWith(
      device: await _getDevice(event.contexts.device),
    );

    return event.copyWith(
      contexts: contexts,
    );
  }

  Future<SentryDevice> _getDevice(
    SentryDevice? device,
  ) async {
    double? batteryLevel;
    String? state;
    if (!_options.platformChecker.hasNativeIntegration) {
      batteryLevel = (await battery.batteryLevel).toDouble();
      state = (await battery.batteryState).toHumanReadable();
      if (await battery.isInBatterySaveMode) {
        state = '$state - battery saving mode';
      }
    }

    String? deviceType;
    final views =
        WidgetsFlutterBinding.ensureInitialized().platformDispatcher.views;
    final displayFeatures = views
        .map((view) => view.displayFeatures)
        .reduce((value, element) => [...value, ...element])
        .map((e) => e.type)
        .toSet();

    if (displayFeatures.contains(DisplayFeatureType.fold)) {
      deviceType = 'fold';
    } else if (displayFeatures.contains(DisplayFeatureType.hinge)) {
      deviceType = 'hinge';
    }

    return (device ?? const SentryDevice()).copyWith(
      batteryLevel: batteryLevel,
      batteryStatus: state,
      deviceType: deviceType,
    );
  }
}

extension on BatteryState {
  String toHumanReadable() {
    switch (this) {
      case BatteryState.full:
        return 'Full';
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.discharging:
        return 'Discharging';
      case BatteryState.unknown:
        return 'Unknown';
    }
  }
}
