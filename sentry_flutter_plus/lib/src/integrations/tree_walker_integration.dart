import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class TreeWalkerIntegration extends Integration<SentryFlutterOptions> {
  @override
  FutureOr<void> call(Hub hub, SentryFlutterOptions options) {
    hub.configureScope((scope) {
      scope.addAttachment(TreeAttachment());
    });
    options.sdk.addIntegration('TreeWalkerIntegration');
  }
}

class TreeWalker {
  final Element? rootElement;

  TreeWalker(this.rootElement);

  Node? compute() {
    final root = rootElement;
    if (root == null) {
      return null;
    }
    final rootNode = Node(root.widgetTypeName, root.widget.key, root.position,
        root.size, root.info);
    root.visitChildElements(_visitor(rootNode));
    return rootNode;
  }

  ValueChanged<Element> _visitor(Node parentNode) {
    return (Element element) {
      final node = Node(
        element.widgetTypeName,
        element.widget.key,
        element.position,
        element.size,
        element.info,
      );
      parentNode.children.add(node);
      element.visitChildElements(_visitor(node));
    };
  }
}

class Node {
  Node(this.name, this.key, this.position, this.size, this.extraData);

  String name;
  Key? key;
  Offset position;
  Size? size;
  String? extraData;
  List<Node> children = [];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (key != null) 'key': key.toString(),
      'position': {
        'x': position.dx,
        'y': position.dy,
      },
      'size': {
        'height': size?.height,
        'width': size?.width,
      },
      'extraData': extraData,
      if (children.isNotEmpty)
        'children': children.map((e) => e.toMap()).toList(growable: false),
    };
  }

  String toJsonString() => jsonEncode(toMap());

  @override
  String toString() {
    //return jsonEncode(toMap());
    StringBuffer buffer = StringBuffer();
    _printAsTree(buffer, '', false);
    return buffer.toString();
  }

  void _printAsTree(StringBuffer buffer, String indent, bool last) {
    buffer.write(indent);
    if (last) {
      buffer.write("└╴");
      indent += "  ";
    } else {
      buffer.write("├╴");
      indent += "│ ";
    }
    buffer.writeln(name);
    if (key != null) {
      buffer.write(
          ' (Key: $key, position: $position, size: $size, extraData: $extraData)');
    }

    for (int i = 0; i < children.length; i++) {
      children[i]._printAsTree(buffer, indent, i == children.length - 1);
    }
  }
}

extension on Element {
  String get widgetTypeName => widget.runtimeType.toString();

  RenderBox get _asRenderBox => renderObject as RenderBox;

  Offset get position => _asRenderBox.localToGlobal(Offset.zero);

  String? get info {
    final w = widget;
    if (w is Text) {
      return w.data ?? w.textSpan?.toPlainText();
    }
    return null;
  }
}

class TreeAttachment extends SentryAttachment {
  TreeAttachment()
      : super.fromLoader(
          loader: _widgetTree,
          filename: 'widget_tree.txt',
          contentType: 'text/plain',
        );
}

FutureOr<Uint8List> _widgetTree() {
  final tree = TreeWalker(WidgetsBinding.instance.renderViewElement)
      .compute()
      ?.toString();
  if (tree == null) {
    return Uint8List.fromList([]);
  }
  return Uint8List.fromList(utf8.encode(tree));
}
