import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_flutter_plus/src/breadcrumb.dart';

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
  void setMenus(List<PlatformMenuItem> topLevelMenus) {
    // it would be cool to have a tree view of the menu
    _delegate.setMenus(topLevelMenus.map(_mapper).toList());
  }

  PlatformMenuItem _mapper(PlatformMenuItem item) {
    // known subtypes of MenuItem
    // - PlatformMenu
    // - PlatformMenuItemGroup
    // - PlatformMenuItem
    // - PlatformProvidedMenuItem
    if (item is PlatformProvidedMenuItem) {
      return _platformProvidedMenuItemMapper(item);
    } else if (item is PlatformMenuItemGroup) {
      return _platformMenuItemGroupMapper(item);
    } else if (item is PlatformMenu) {
      return _platformMenuMapper(item);
    }

    return _platformMenuItemMapper(item);
  }

  PlatformMenuItem _platformMenuMapper(PlatformMenu item) {
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

  PlatformMenuItem _platformProvidedMenuItemMapper(
      PlatformProvidedMenuItem item) {
    // nothing can be done for these :(
    return item;
  }

  PlatformMenuItem _platformMenuItemGroupMapper(PlatformMenuItemGroup item) {
    return PlatformMenuItemGroup(
      members: item.members.map(_mapper).toList(),
    );
  }

  PlatformMenuItem _platformMenuItemMapper(PlatformMenuItem item) {
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
