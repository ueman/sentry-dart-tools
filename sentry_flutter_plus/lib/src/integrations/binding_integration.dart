import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../method_channel/sentry_binary_messenger.dart';

class BindingIntegration extends Integration<SentryFlutterOptions> {
  @override
  FutureOr<void> call(Hub hub, SentryFlutterOptions options) {
    // Can't be undone, so no overridden close method.
    SentryWidgetsBinding();
    options.sdk.addIntegration('BindingIntegration');
  }
}

class SentryWidgetsBinding extends WidgetsFlutterBinding {
  @override
  @protected
  BinaryMessenger createBinaryMessenger() {
    return SentryBinaryMessenger(
      binaryMessenger: super.createBinaryMessenger(),
    );
  }

  // RestorationManager looks interesting too
}
