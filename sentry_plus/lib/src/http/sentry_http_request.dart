import 'dart:convert';
import 'dart:io';

import 'package:sentry/sentry.dart';

import 'sentry_http_response.dart';

class SentryHttpRequest implements HttpClientRequest {
  final HttpClientRequest _innerRequest;
  final ISentrySpan _span;

  SentryHttpRequest(
    this._span,
    this._innerRequest,
  );

  @override
  Future<HttpClientResponse> get done async {
    try {
      final innerFuture = await _innerRequest.done;
      return SentryHttpResponse(_span, innerFuture);
    } catch (e) {
      _span.throwable = e;
      rethrow;
    } finally {
      //  ???
    }
  }

  @override
  Future<HttpClientResponse> close() async {
    try {
      final response = await _innerRequest.close();
      return SentryHttpResponse(_span, response);
    } catch (e) {
      _span.throwable = e;
      rethrow;
    } finally {
      //  ???
    }
  }

  // coverage:ignore-start

  @override
  bool get bufferOutput => _innerRequest.bufferOutput;

  @override
  set bufferOutput(bool value) => _innerRequest.bufferOutput = value;

  @override
  int get contentLength => _innerRequest.contentLength;

  @override
  set contentLength(int value) => _innerRequest.contentLength = value;

  @override
  Encoding get encoding => _innerRequest.encoding;

  @override
  set encoding(Encoding value) => _innerRequest.encoding = value;

  @override
  bool get followRedirects => _innerRequest.followRedirects;

  @override
  set followRedirects(bool value) => _innerRequest.followRedirects = value;

  @override
  int get maxRedirects => _innerRequest.maxRedirects;

  @override
  set maxRedirects(int value) => _innerRequest.maxRedirects = value;

  @override
  bool get persistentConnection => _innerRequest.persistentConnection;

  @override
  set persistentConnection(bool value) =>
      _innerRequest.persistentConnection = value;

  @override
  void abort([Object? exception, StackTrace? stackTrace]) =>
      _innerRequest.abort(exception, stackTrace);

  @override
  void add(List<int> data) => _innerRequest.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _innerRequest.addError(error, stackTrace);

  @override
  Future addStream(Stream<List<int>> stream) => _innerRequest.addStream(stream);

  @override
  HttpConnectionInfo? get connectionInfo => _innerRequest.connectionInfo;

  @override
  List<Cookie> get cookies => _innerRequest.cookies;

  @override
  Future flush() => _innerRequest.flush();

  @override
  HttpHeaders get headers => _innerRequest.headers;

  @override
  String get method => _innerRequest.method;

  @override
  Uri get uri => _innerRequest.uri;

  @override
  void write(Object? object) => _innerRequest.write(object);

  @override
  void writeAll(Iterable objects, [String separator = '']) =>
      _innerRequest.writeAll(objects, separator);

  @override
  void writeCharCode(int charCode) => _innerRequest.writeCharCode(charCode);

  @override
  void writeln([Object? object = '']) => _innerRequest.writeln(object);

  // coverage:ignore-end
}
