import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../method_channel/sentry_binary_messenger.dart';

/// Must be used instead of [WidgetsFlutterBindingIntegration].
/// If [WidgetsFlutterBindingIntegration] is used, this won't have
/// any effect.
/// Therefore, when using this integration, [WidgetsFlutterBindingIntegration]
/// must be removed beforehand.
///
/// Must be used instead of [WidgetsFlutterBinding] and
/// [WidgetsFlutterBinding.ensureInitialized].
/// If [WidgetsFlutterBinding] is initialized before, this
/// does not do anything.
class WidgetsSentryBinding extends BindingBase
    with
        GestureBinding,
        SchedulerBinding,
        ServicesBinding,
        PaintingBinding,
        SemanticsBinding,
        RendererBinding,
        WidgetsBinding {
  static bool _initialized = false;

  static WidgetsBinding ensureInitialized() {
    if (!_initialized) WidgetsSentryBinding();
    _initialized = true;
    return WidgetsBinding.instance;
  }

  // RestorationManager looks interesting too,
  // see https://api.flutter.dev/flutter/services/ServicesBinding/restorationManager.html

  @override
  @protected
  BinaryMessenger createBinaryMessenger() {
    return SentryBinaryMessenger(
      binaryMessenger: super.createBinaryMessenger(),
    );
  }
}
