import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ExceptionEventProcessor implements EventProcessor {
  ExceptionEventProcessor(this._options);

  final SentryFlutterOptions _options;

  @override
  SentryEvent? apply(SentryEvent event, {dynamic hint}) {
    final exception = event.throwable;
    if (exception is NetworkImageLoadException) {
      return _applyNetworkImageLoadException(event, exception);
    }
    if (exception is PictureRasterizationException) {
      return _applyPictureRasterizationException(event, exception);
    }
    return event;
  }

  /// https://api.flutter.dev/flutter/painting/NetworkImageLoadException-class.html
  SentryEvent _applyNetworkImageLoadException(
    SentryEvent event,
    NetworkImageLoadException exception,
  ) {
    return event.copyWith(
      request: event.request ?? _fromUri(uri: exception.uri),
      contexts: event.contexts.copyWith(
        response: event.contexts.response ??
            SentryResponse(statusCode: exception.statusCode),
      ),
    );
  }

  /// https://api.flutter.dev/flutter/dart-ui/PictureRasterizationException-class.html
  SentryEvent _applyPictureRasterizationException(
    SentryEvent event,
    PictureRasterizationException exception,
  ) {
    final stackTrace = exception.stack;
    if (stackTrace == null) {
      return event;
    }
    return event.copyWith(
      exceptions: [
        ...?event.exceptions,
        SentryException(
          type: 'Picture.toImageSync',
          value: 'The stack trace at the time Picture.toImageSync was called. '
              'This is not an exception, just an additional stacktrace.',
          stackTrace: SentryStackTrace(
            // ignore: invalid_use_of_internal_member
            frames: _options.stackTraceFactory.getStackFrames(stackTrace),
          ),
        )
      ],
    );
  }
}

SentryRequest _fromUri({
  required Uri uri,
  String? method,
  String? cookies,
  dynamic data,
  Map<String, String>? headers,
  Map<String, String>? env,
}) {
  // As far as I can tell there's no way to get the uri without the query part
  // so we replace it with an empty string.
  final urlWithoutQuery = uri
      .replace(query: '', fragment: '')
      .toString()
      .replaceAll('?', '')
      .replaceAll('#', '');

  final query = uri.query.isEmpty ? null : uri.query;
  final fragment = uri.fragment.isEmpty ? null : uri.fragment;

  return SentryRequest(
    url: urlWithoutQuery,
    fragment: fragment,
    queryString: query,
    method: method,
    cookies: cookies,
    data: data,
    headers: headers,
    env: env,
  );
}
