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

  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) {
    // Should be kept in sync with https://github.com/dart-lang/sdk/blob/main/sdk/lib/_http/http_impl.dart
    const int hashMark = 0x23;
    const int questionMark = 0x3f;
    int fragmentStart = path.length;
    int queryStart = path.length;
    for (int i = path.length - 1; i >= 0; i--) {
      var char = path.codeUnitAt(i);
      if (char == hashMark) {
        fragmentStart = i;
        queryStart = i;
      } else if (char == questionMark) {
        queryStart = i;
      }
    }
    String? query;
    if (queryStart < fragmentStart) {
      query = path.substring(queryStart + 1, fragmentStart);
      path = path.substring(0, queryStart);
    }
    final uri =
        Uri(scheme: 'http', host: host, port: port, path: path, query: query);
    return _openUrl(method, uri);
  }

  Future<HttpClientRequest> _openUrl(String method, Uri url) async {
    // ignore: todo
    // TODO Don't track calls to Sentry itself
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
      final request = await _innerClient.openUrl(method, url);
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
  void close({bool force = false}) => _innerClient.close(force: force);

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      open('delete', host, port, path);

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => _openUrl('delete', url);

  @override
  set findProxy(String Function(Uri url)? f) => _innerClient.findProxy = f;

  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      open('get', host, port, path);

  @override
  Future<HttpClientRequest> getUrl(Uri url) => _openUrl('get', url);

  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      open('head', host, port, path);

  @override
  Future<HttpClientRequest> headUrl(Uri url) => _openUrl('head', url);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      _openUrl(method, url);

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      open('patch', host, port, path);

  @override
  Future<HttpClientRequest> patchUrl(Uri url) => _openUrl('patch', url);

  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      open('post', host, port, path);

  @override
  Future<HttpClientRequest> postUrl(Uri url) => _openUrl('post', url);

  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      open('put', host, port, path);

  @override
  Future<HttpClientRequest> putUrl(Uri url) => _openUrl('put', url);

  // coverage:ignore-end
}
