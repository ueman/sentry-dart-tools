import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter_plus/src/widgets/sentry_widget.dart';

import '../method_channel/sentry_binary_messenger.dart';

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
        WidgetsBinding,
        SentryBinding {
  static WidgetsSentryBinding get instance =>
      BindingBase.checkInstance(_instance);
  static WidgetsSentryBinding? _instance;

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  static WidgetsSentryBinding ensureInitialized() {
    _assertNoBindingIsInitialized();
    if (WidgetsSentryBinding._instance == null) {
      WidgetsSentryBinding();
    }
    return WidgetsSentryBinding.instance;
  }
}

mixin SentryBinding on WidgetsBinding {
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

/// Before initializing [WidgetsSentryBinding], you need to make sure
/// that no other [BindingBase], like [WidgetsFlutterBinding], was initialized
/// before.
///
/// In release mode ([kReleaseMode]), there's no way to check whether a binding
/// was already initialized.
/// Therefore, in release mode this method is a no-op.
///
/// In debug mode ([kDebugMode]), this method returns normally if no binding was
/// initialized.
/// It throws an [AssertionError] if a binding was previously initialized.
void _assertNoBindingIsInitialized() {
  assert(
    BindingBase.debugBindingType() == null,
    "Make sure you don't use any other Bindings than `WidgetsSentryBinding`. "
    'If you want to use other Bindings either opt out of using the '
    '`WidgetsSentryBinding` or create your own custom Binding and mixin '
    '`SentryBinding`.',
  );
}
