import 'dart:async';
import 'dart:io';

import 'package:sentry/sentry.dart';

class SentryHttpResponse extends Stream<List<int>>
    implements HttpClientResponse {
  final HttpClientResponse _innerResponse;
  final ISentrySpan _span;

  Object? lastError;

  SentryHttpResponse(
    this._span,
    this._innerResponse,
  );

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _innerResponse.listen(
      onData,
      cancelOnError: cancelOnError,
      onError: (e, st) {
        _onError(e, st);
        if (onError == null) {
          return;
        }
        if (onError is void Function(Object, StackTrace)) {
          onError(e, st);
        } else {
          assert(onError is void Function(Object));
          onError(e);
        }
      },
      onDone: () {
        _onFinish();
        if (onDone != null) {
          onDone();
        }
      },
    );
  }

  // Set an error if one occurs during the stream. Note that only the last
  // error will be sent.
  void _onError(Object error, StackTrace? stackTrace) {
    lastError = error;
    _span.throwable = error;
  }

  void _onFinish() {
    final statusCode = _innerResponse.statusCode;
    unawaited(_span.finish(status: SpanStatus.fromHttpStatusCode(statusCode)));
  }

  // coverage:ignore-start

  @override
  X509Certificate? get certificate => _innerResponse.certificate;

  @override
  HttpClientResponseCompressionState get compressionState =>
      _innerResponse.compressionState;

  @override
  HttpConnectionInfo? get connectionInfo => _innerResponse.connectionInfo;

  @override
  int get contentLength => _innerResponse.contentLength;

  @override
  List<Cookie> get cookies => _innerResponse.cookies;

  @override
  Future<Socket> detachSocket() => _innerResponse.detachSocket();

  @override
  HttpHeaders get headers => _innerResponse.headers;

  @override
  bool get isRedirect => _innerResponse.isRedirect;

  @override
  bool get persistentConnection => _innerResponse.persistentConnection;

  @override
  String get reasonPhrase => _innerResponse.reasonPhrase;

  @override
  Future<HttpClientResponse> redirect([
    String? method,
    Uri? url,
    bool? followLoops,
  ]) =>
      _innerResponse.redirect(method, url, followLoops);

  @override
  List<RedirectInfo> get redirects => _innerResponse.redirects;

  @override
  int get statusCode => _innerResponse.statusCode;

  // coverage:ignore-end
}
