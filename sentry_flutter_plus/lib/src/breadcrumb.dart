// https://develop.sentry.dev/sdk/event-payloads/breadcrumbs/#breadcrumb-types
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_flutter_plus/src/widgets/tapped_widget.dart';

class UiBreadcrumb extends Breadcrumb {
  UiBreadcrumb({
    String? message,
    DateTime? timestamp,
    Map<String, dynamic>? data,
    SentryLevel? level,
  }) : super(
          category: 'ui.click',
          type: 'user',
          message: message,
          timestamp: timestamp,
          data: data,
          level: level,
        );

  factory UiBreadcrumb.platformMenuItem(PlatformMenuItem item) {
    return UiBreadcrumb(
      message: 'PlatformMenuItem pressed',
      data: {
        'label': item.label,
        'hasOnSelected': item.onSelected != null,
        if (item.shortcut != null)
          'shortcut':
              item.shortcut?.serializeForMenu().toChannelRepresentation()
      },
    );
  }

  factory UiBreadcrumb.platformMenu(PlatformMenu menu, String action) {
    return UiBreadcrumb(
      message: 'PlatformMenu $action pressed',
      data: {
        'label': menu.label,
        'hasOnOpen': menu.onOpen != null,
        'hasOnClose': menu.onClose != null,
        'menuCount': menu.menus.length,
      },
    );
  }

  factory UiBreadcrumb.tappedWidget(TappedWidget widget) {
    final key = widget.keyValue;
    return UiBreadcrumb(
      message: 'clicked on "${widget.type}" '
          'with content "${widget.description}"',
      data: {
        'widget_type': widget.element.widget.runtimeType,
        if (key != null) 'widget_key': key,
      },
    );
  }
}
