import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_flutter_plus/src/widgets/sentry_widget.dart';

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
// ignore: todo
// TODO: Make a mixin out of this so this could be used with other peoples
// custom bindings
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

  @override
  void attachRootWidget(Widget rootWidget) {
    super.attachRootWidget(SentryWidget(child: rootWidget));
  }

  @override
  @protected
  BinaryMessenger createBinaryMessenger() {
    return SentryBinaryMessenger(
      binaryMessenger: super.createBinaryMessenger(),
    );
  }
}
