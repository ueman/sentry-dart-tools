import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class NetworkBreadcrumb extends Breadcrumb {
  NetworkBreadcrumb({
    required ConnectivityResult connectivityState,
    DateTime? timestamp,
    Map<String, dynamic>? data,
  }) : super(
          message:
              'Network state changed to ${connectivityState.toHumanReadable()}',
          timestamp: timestamp,
          category: 'network',
          level: SentryLevel.info,
          type: 'network',
          data: data,
        );
}

extension on ConnectivityResult {
  String toHumanReadable() {
    switch (this) {
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.wifi:
        return 'Bluetooth';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.mobile:
        return 'mobile network';
      case ConnectivityResult.none:
        return 'none';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'unknown';
    }
  }
}
