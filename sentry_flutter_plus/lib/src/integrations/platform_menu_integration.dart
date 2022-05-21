import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// This [Integration] adds [Breadcrumb]s for clicks on [MenuItem]s.
/// It also starts automatic performance traces.
class PlatformMenuIntegration extends Integration<SentryFlutterOptions> {
  late PlatformMenuDelegate delegate;

  @override
  FutureOr<void> call(Hub hub, SentryFlutterOptions options) {
    try {
      // At this point the WidgetsBinding is probably already initialized.
      // Call it anyways, just to be sure. We need it to be initialized
      // after all.
      WidgetsFlutterBinding.ensureInitialized();

      delegate = WidgetsBinding.instance.platformMenuDelegate;

      WidgetsBinding.instance.platformMenuDelegate =
          SentryPlatformMenuDelegate(delegate, hub);

      options.sdk.addIntegration('PlatformMenuIntegration');
    } catch (exception, stacktrace) {
      options.logger(
        SentryLevel.debug,
        "Couldn't add PlatformMenuIntegration",
        exception: exception,
        stackTrace: stacktrace,
      );
    }
  }

  @override
  FutureOr<void> close() {
    WidgetsBinding.instance.platformMenuDelegate = delegate;
  }
}

class SentryPlatformMenuDelegate implements PlatformMenuDelegate {
  SentryPlatformMenuDelegate(this._delegate, this._hub);

  final PlatformMenuDelegate _delegate;
  final Hub _hub;

  @override
  void clearMenus() {
    _delegate.clearMenus();
  }

  @override
  bool debugLockDelegate(BuildContext context) {
    return _delegate.debugLockDelegate(context);
  }

  @override
  bool debugUnlockDelegate(BuildContext context) {
    return debugUnlockDelegate(context);
  }

  @override
  void setMenus(List<MenuItem> topLevelMenus) {
    // it would be cool to have a tree view of the menu
    _delegate.setMenus(topLevelMenus.map(_mapper).toList());
  }

  MenuItem _mapper(MenuItem item) {
    // known subtypes of MenuItem
    // - PlatformMenu
    // - PlatformMenuItemGroup
    // - PlatformMenuItem
    // - PlatformProvidedMenuItem
    if (item is PlatformProvidedMenuItem) {
      return _platformProvidedMenuItemMapper(item);
    } else if (item is PlatformMenuItem) {
      return _platformMenuItemMapper(item);
    } else if (item is PlatformMenuItemGroup) {
      return _platformMenuItemGroupMapper(item);
    } else if (item is PlatformMenu) {
      return _platformMenuMapper(item);
    }
    return item;
  }

  MenuItem _platformMenuMapper(PlatformMenu item) {
    var onOpen = item.onOpen;
    if (onOpen != null) {
      onOpen = () {
        _hub.addBreadcrumb(UiBreadcrumb.platformMenu(item, 'onOpen'));
        item.onOpen?.call();
      };
    }

    var onClose = item.onClose;
    if (onClose != null) {
      onClose = () {
        _hub.addBreadcrumb(UiBreadcrumb.platformMenu(item, 'onClose'));
        item.onClose?.call();
      };
    }
    return PlatformMenu(
      label: item.label,
      menus: item.menus.map(_mapper).toList(),
      onOpen: onOpen,
      onClose: onClose,
    );
  }

  MenuItem _platformProvidedMenuItemMapper(PlatformProvidedMenuItem item) {
    // nothing can be done for these :(
    return item;
  }

  MenuItem _platformMenuItemGroupMapper(PlatformMenuItemGroup item) {
    return PlatformMenuItemGroup(
      members: item.members.map(_mapper).toList(),
    );
  }

  MenuItem _platformMenuItemMapper(PlatformMenuItem item) {
    var onSelected = item.onSelected;
    if (onSelected != null) {
      onSelected = () {
        _hub.addBreadcrumb(UiBreadcrumb.platformMenuItem(item));
        item.onSelected?.call();
      };
    }
    return PlatformMenuItem(
      label: item.label,
      shortcut: item.shortcut,
      onSelected: onSelected,
    );
  }
}

// https://develop.sentry.dev/sdk/event-payloads/breadcrumbs/#breadcrumb-types
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
}
