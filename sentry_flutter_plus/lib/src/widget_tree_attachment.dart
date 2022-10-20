import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// This class only works in debug mode.
/// See https://docs.flutter.dev/testing/code-debugging
/// for more information.
class WidgetTreeAttachment extends SentryAttachment {
  WidgetTreeAttachment()
      : super.fromLoader(
          loader: _widgetTree,
          filename: 'widget_tree.txt',
          contentType: 'text/plain',
        );
}

FutureOr<Uint8List> _widgetTree() async {
  const String mode = kDebugMode
      ? 'DEBUG MODE'
      : kReleaseMode
          ? 'RELEASE MODE'
          : 'PROFILE MODE';
  final StringBuffer buffer = StringBuffer();
  buffer.writeln('${WidgetsBinding.instance.runtimeType} - $mode');
  if (WidgetsBinding.instance.renderViewElement != null) {
    buffer.writeln(WidgetsBinding.instance.renderViewElement!.toStringDeep());
  } else {
    buffer.writeln('<no tree currently mounted>');
  }
  return Uint8List.fromList(utf8.encode(buffer.toString()));
}
