import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

typedef ErrorCallback = bool Function(Object exception, StackTrace stackTrace);

class PlatformMessageIntegration implements Integration<SentryFlutterOptions> {
  PlatformMessageCallback? _default;
  PlatformMessageCallback? _integration;

  WidgetsBinding? get _binding => WidgetsBinding.instance;
  PlatformDispatcher get _dispatcher => _binding!.platformDispatcher;

  @override
  FutureOr<void> call(Hub hub, SentryFlutterOptions options) {
    _default = _dispatcher.onPlatformMessage;
    _integration = (name, data, callback) {
      hub.addBreadcrumb(Breadcrumb(
        message: 'MethodChannel message from $name',
      ));
      _default?.call(name, data, (ByteData? data) {
        callback?.call(data);
      });
    };

    _dispatcher.onPlatformMessage = _integration;

    options.sdk.addIntegration('PlatformDispatcher.onPlatformMessage');
  }

  @override
  FutureOr<void> close() async {
    /// Restore default if the integration is still set.
    if (_dispatcher.onPlatformMessage == _integration) {
      _dispatcher.onPlatformMessage = _default;
      _default = null;
      _integration = null;
    }
  }
}
