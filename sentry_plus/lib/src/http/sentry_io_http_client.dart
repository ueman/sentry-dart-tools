import 'dart:async';
import 'dart:io';

import 'package:sentry/sentry.dart';

import 'sentry_http_request.dart';

// Should be kept in sync with https://github.com/dart-lang/sdk/blob/main/sdk/lib/_http/http_impl.dart
class SentryIoHttpClient implements HttpClient {
  final Hub _hub;
  // ignore: unused_field
  final SentryOptions _options;

  final HttpClient _innerClient;

  SentryIoHttpClient(this._options, this._hub, this._innerClient);

  Future<HttpClientRequest> _wrap(
    Future<HttpClientRequest> requestFuture,
    String method,
    Uri url,
  ) async {
    final currentSpan = _hub.getSpan();
    if (currentSpan == null) {
      // no wrapping if no span is active
      return _innerClient.openUrl(method, url);
    }

    final span = currentSpan.startChild(
      'http.client',
      description: '$method $url',
    );
    try {
      final request = await requestFuture;
      final traceHeader = span.toSentryTrace();
      request.headers.add(traceHeader.name, traceHeader.value);
      return SentryHttpRequest(span, request);
    } catch (e) {
      span.throwable = e;
      rethrow;
    } finally {
      await span.finish();
    }
  }

  // coverage:ignore-start

  @override
  bool get autoUncompress => _innerClient.autoUncompress;

  @override
  set autoUncompress(bool value) => _innerClient.autoUncompress = value;

  @override
  Duration? get connectionTimeout => _innerClient.connectionTimeout;

  @override
  set connectionTimeout(Duration? value) =>
      _innerClient.connectionTimeout = value;

  @override
  Duration get idleTimeout => _innerClient.idleTimeout;

  @override
  set idleTimeout(Duration value) => _innerClient.idleTimeout = value;

  @override
  int? get maxConnectionsPerHost => _innerClient.maxConnectionsPerHost;

  @override
  set maxConnectionsPerHost(int? value) =>
      _innerClient.maxConnectionsPerHost = value;

  @override
  String? get userAgent => _innerClient.userAgent;

  @override
  set userAgent(String? value) => _innerClient.userAgent = value;

  @override
  void addCredentials(
    Uri url,
    String realm,
    HttpClientCredentials credentials,
  ) =>
      _innerClient.addCredentials(url, realm, credentials);

  @override
  void addProxyCredentials(
    String host,
    int port,
    String realm,
    HttpClientCredentials credentials,
  ) =>
      _innerClient.addProxyCredentials(host, port, realm, credentials);

  @override
  set authenticate(
          Future<bool> Function(Uri url, String scheme, String? realm)? f) =>
      _innerClient.authenticate = f;

  @override
  set authenticateProxy(
          Future<bool> Function(
                  String host, int port, String scheme, String? realm)?
              f) =>
      _innerClient.authenticateProxy = f;

  @override
  set badCertificateCallback(
    bool Function(X509Certificate cert, String host, int port)? callback,
  ) =>
      _innerClient.badCertificateCallback = callback;

  @override
  set findProxy(String Function(Uri url)? f) => _innerClient.findProxy = f;

  @override
  void close({bool force = false}) => _innerClient.close(force: force);

  @override
  Future<HttpClientRequest> open(
          String method, String host, int port, String path) =>
      _wrap(
        _innerClient.open(method, host, port, path),
        method,
        Uri(host: host, port: port, path: path),
      );

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) => _wrap(
        _innerClient.delete(host, port, path),
        'delete',
        Uri(host: host, port: port, path: path),
      );

  @override
  Future<HttpClientRequest> get(String host, int port, String path) => _wrap(
        _innerClient.get(host, port, path),
        'get',
        Uri(host: host, port: port, path: path),
      );

  @override
  Future<HttpClientRequest> head(String host, int port, String path) => _wrap(
        _innerClient.head(host, port, path),
        'head',
        Uri(host: host, port: port, path: path),
      );

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) => _wrap(
        _innerClient.patch(host, port, path),
        'patch',
        Uri(host: host, port: port, path: path),
      );

  @override
  Future<HttpClientRequest> post(String host, int port, String path) => _wrap(
        _innerClient.post(host, port, path),
        'post',
        Uri(host: host, port: port, path: path),
      );

  @override
  Future<HttpClientRequest> put(String host, int port, String path) => _wrap(
        _innerClient.put(host, port, path),
        'put',
        Uri(host: host, port: port, path: path),
      );

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) =>
      _wrap(_innerClient.deleteUrl(url), 'delete', url);

  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      _wrap(_innerClient.getUrl(url), 'get', url);

  @override
  Future<HttpClientRequest> headUrl(Uri url) =>
      _wrap(_innerClient.headUrl(url), 'head', url);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      _wrap(_innerClient.openUrl(method, url), method, url);

  @override
  Future<HttpClientRequest> patchUrl(Uri url) =>
      _wrap(_innerClient.patchUrl(url), 'patch', url);

  @override
  Future<HttpClientRequest> postUrl(Uri url) =>
      _wrap(_innerClient.postUrl(url), 'post', url);

  @override
  Future<HttpClientRequest> putUrl(Uri url) =>
      _wrap(_innerClient.putUrl(url), 'put', url);

  // coverage:ignore-end

  @override
  // This is an override on Flutter 2.8 and later
  // ignore: override_on_non_overriding_member
  set connectionFactory(
      Future<ConnectionTask<Socket>> Function(
              Uri url, String? proxyHost, int? proxyPort)?
          f) {
    try {
      (_innerClient as dynamic).connectionFactory = f;
    } on NoSuchMethodError catch (_) {
      // The clear method exists as of Dart 2.17.0
      // Previous versions don't have it, but later versions do.
      // We can't use `extends` in order to provide this method because this is
      // a wrapper and thus the method call must be forwarded.
      // On Dart versions before 2.17 we can't forward this call and
      // just catch the error which is thrown. On later version the call gets
      // correctly forwarded.
    }
  }

  @override
  // This is an override on Flutter 2.8 and later
  // ignore: override_on_non_overriding_member
  set keyLog(Function(String line)? callback) {
    try {
      (_innerClient as dynamic).keyLog = callback;
    } on NoSuchMethodError catch (_) {
      // The clear method exists as of Dart 2.17.0
      // Previous versions don't have it, but later versions do.
      // We can't use `extends` in order to provide this method because this is
      // a wrapper and thus the method call must be forwarded.
      // On Dart versions before 2.17 we can't forward this call and
      // just catch the error which is thrown. On later version the call gets
      // correctly forwarded.
    }
  }
}
