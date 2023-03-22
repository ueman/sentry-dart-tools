import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sentry_connectivity/src/network_breadcrumb.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ConnectivityIntegration extends Integration<SentryFlutterOptions> {
  Hub? _hub;
  StreamSubscription<ConnectivityResult>? _subscription;

  @override
  void call(Hub hub, SentryFlutterOptions options) {
    _hub = hub;
    _subscription =
        Connectivity().onConnectivityChanged.listen(_recordBreadcrumb);
  }

  @override
  void close() {
    _hub = null;
    _subscription?.cancel();
    _subscription = null;
  }

  void _recordBreadcrumb(ConnectivityResult result) {
    _hub?.addBreadcrumb(NetworkBreadcrumb(connectivityState: result));
  }
}
