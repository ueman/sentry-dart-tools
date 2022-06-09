import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_flutter_plus/src/breadcrumb.dart';
import 'package:sentry_flutter_plus/src/widgets/tapped_widget.dart';

const _tapDeltaArea = 20 * 20;
Element? _clickTrackerElement;

class ClickTracker extends StatefulWidget {
  Hub get _hub => hub ?? HubAdapter();

  final Hub? hub;

  final Widget child;

  const ClickTracker({
    Key? key,
    this.hub,
    required this.child,
  }) : super(key: key);

  @override
  StatefulElement createElement() {
    final e = super.createElement();
    _clickTrackerElement = e;
    return e;
  }

  @override
  State<ClickTracker> createState() => _ClickTrackerState();
}

class _ClickTrackerState extends State<ClickTracker> {
  int? _lastPointerId;
  Offset? _lastPointerDownLocation;
  Hub get hub => widget._hub;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: widget.child,
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    _lastPointerId = event.pointer;
    _lastPointerDownLocation = event.localPosition;
  }

  void _onPointerUp(PointerUpEvent event) {
    // Figure out if something was tapped
    final location = _lastPointerDownLocation;
    if (location == null || event.pointer != _lastPointerId) {
      return;
    }
    final delta = Offset(
      location.dx - event.localPosition.dx,
      location.dy - event.localPosition.dy,
    );

    if (delta.distanceSquared < _tapDeltaArea) {
      // Widget was tapped
      _onTappedAt(event.localPosition);
    }
  }

  void _onTappedAt(Offset position) {
    final tappedWidget = _getElementAt(position);
    if (tappedWidget == null) {
      return;
    }

    hub.addBreadcrumb(UiBreadcrumb.tappedWidget(tappedWidget));
  }

  String _findDescriptionOf(Element element, bool allowText) {
    var description = 'unknown';

    // traverse tree to find a suiting element
    void descriptionFinder(Element element) {
      bool foundDescription = false;

      final widget = element.widget;
      if (allowText && widget is Text) {
        final data = widget.data;
        if (data != null && data.isNotEmpty) {
          description = data;
          foundDescription = true;
        }
      } else if (widget is Semantics) {
        if (widget.properties.label?.isNotEmpty ?? false) {
          description = widget.properties.label!;
          foundDescription = true;
        }
      } else if (widget is Icon) {
        if (widget.semanticLabel?.isNotEmpty ?? false) {
          description = widget.semanticLabel!;
          foundDescription = true;
        }
      }

      if (!foundDescription) {
        element.visitChildren(descriptionFinder);
      }
    }

    element.visitChildren(descriptionFinder);

    return description;
  }

  TappedWidget? _getElementAt(Offset position) {
    // ignore: todo
    // TODO: figure out why it doesn't work with WidgetsBinding.instance.renderViewElement;
    var rootElement = _clickTrackerElement;
    if (rootElement == null || rootElement.widget != widget) {
      return null;
    }

    TappedWidget? tappedWidget;

    void elementFinder(Element element) {
      if (tappedWidget != null) {
        // element was found
        return;
      }

      final renderObject = element.renderObject;
      if (renderObject == null) {
        return;
      }

      final transform = renderObject.getTransformTo(rootElement.renderObject);
      final paintBounds =
          MatrixUtils.transformRect(transform, renderObject.paintBounds);

      if (!paintBounds.contains(position)) {
        return;
      }
      tappedWidget = _getDescriptionFrom(element);

      if (tappedWidget == null) {
        element.visitChildElements(elementFinder);
      }
    }

    rootElement.visitChildElements(elementFinder);

    return tappedWidget;
  }

  TappedWidget? _getDescriptionFrom(Element element) {
    final widget = element.widget;
    // Used by ElevatedButton, TextButton, OutlinedButton.
    if (widget is ButtonStyleButton) {
      if (widget.enabled) {
        return TappedWidget(
          element: element,
          description: _findDescriptionOf(element, true),
          type: 'ButtonStyleButton',
        );
      }
    } else if (widget is MaterialButton) {
      if (widget.enabled) {
        return TappedWidget(
          element: element,
          description: _findDescriptionOf(element, true),
          type: 'MaterialButton',
        );
      }
    } else if (widget is CupertinoButton) {
      if (widget.enabled) {
        return TappedWidget(
          element: element,
          description: _findDescriptionOf(element, true),
          type: 'CupertinoButton',
        );
      }
    } else if (widget is InkWell) {
      if (widget.onTap != null) {
        return TappedWidget(
          element: element,
          description: _findDescriptionOf(element, false),
          type: 'InkWell',
        );
      }
    } else if (widget is IconButton) {
      if (widget.onPressed != null) {
        return TappedWidget(
          element: element,
          description: _findDescriptionOf(element, false),
          type: 'IconButton',
        );
      }
    } else if (widget is GestureDetector) {
      if (widget.onTap != null) {
        return TappedWidget(
          element: element,
          description: '',
          type: 'GestureDetector',
        );
      }
    }

    return null;
  }
}
