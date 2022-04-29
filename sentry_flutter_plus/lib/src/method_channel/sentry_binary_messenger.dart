import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry/sentry.dart';

class SentryBinaryMessenger implements BinaryMessenger {
  SentryBinaryMessenger({Hub? hub, BinaryMessenger? binaryMessenger})
      : _hub = hub ?? HubAdapter(),
        _binaryMessenger = binaryMessenger ??
            WidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger;

  final Hub _hub;
  final BinaryMessenger _binaryMessenger;

  @override
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? data,
    PlatformMessageResponseCallback? callback,
  ) {
    return _binaryMessenger.handlePlatformMessage(channel, data, callback);
  }

  @override
  Future<ByteData?>? send(String channel, ByteData? message) async {
    _hub.addBreadcrumb(
      Breadcrumb(
        category: 'method_channel',
        message: 'Message on MethodChannel "$channel"',
      ),
    );
    ByteData? data;
    final span = _hub.getSpan()?.startChild('send-method-channel');
    try {
      data = await _binaryMessenger.send(channel, message);
      span?.status = const SpanStatus.ok();
    } catch (e) {
      span?.throwable = e;
      span?.status = const SpanStatus.internalError();
      rethrow;
    } finally {
      await span?.finish();
    }
    return data;
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    _binaryMessenger.setMessageHandler(channel, handler);
  }
}
