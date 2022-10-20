import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Some channels create a lot of noise.
/// Exclude some of the noisy channels by default.
//
// ignore: todo
// TODO:
// - It probably makes sense to include all of flutters channels by default
// - Should be expandable by options
const _defaultExcludes = [
  // Sentry method channel
  'sentry_flutter',

  // Flutter default method channel
  'flutter/mousecursor',
  'flutter/platform',
  'flutter/navigation',
  'flutter/textinput',

  // Assets seem like a candidate which shouldn't be excluded,
  // since those are most likely bigger, and thus more expensive.
  // 'flutter/assets',
];

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
    if (_defaultExcludes.contains(channel)) {
      return _binaryMessenger.send(channel, message);
    }

    int? bytes;
    int? resultBytes;
    var errored = false;

    ByteData? data;
    final span = _hub.getSpan()?.startChild(
          'method-channel',
          description: channel,
        );
    span?.setData('message_bytes', bytes);

    final watch = Stopwatch()..start();
    try {
      data = await _binaryMessenger.send(channel, message);
      watch.stop();
      span?.status = const SpanStatus.ok();

      if (data != null) {
        resultBytes = data.lengthInBytes;
        span?.setData('result_bytes', bytes);
      }
    } catch (e) {
      watch.stop();
      errored = true;
      span?.throwable = e;
      span?.status = const SpanStatus.internalError();
      rethrow;
    } finally {
      // This is intentionally not awaited, in order to not slow down
      // the channel communication.
      // ignore: unawaited_futures
      span?.finish(status: const SpanStatus.ok());
      _hub.addBreadcrumb(
        Breadcrumb(
          level: errored ? SentryLevel.error : null,
          category: 'method_channel',
          message: 'Message on MethodChannel "$channel"',
          data: {
            if (bytes != null) 'message_bytes': bytes,
            if (resultBytes != null) 'result_bytes': resultBytes,
            'duration': watch.elapsed.toString(),
          },
        ),
      );
    }

    return data;
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    _binaryMessenger.setMessageHandler(channel, handler);
  }
}
