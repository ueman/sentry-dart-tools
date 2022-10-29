import 'dart:async';
import 'dart:convert';

import 'package:sentry/sentry.dart';
import 'package:http/http.dart' as http;

Map<String, dynamic>? sentryResponseDecoder(
  http.Response response, {
  Hub? hub,
}) {
  final currentHub = hub ?? HubAdapter();
  final span = currentHub.getSpan()?.startChild(
        'serialize.http.client',
        description: 'response-deserialization',
      );
  Map<String, dynamic>? result;
  try {
    result = _defaultHttpResponseDecoder(response);
    span?.status = const SpanStatus.ok();
  } catch (e) {
    span?.status = const SpanStatus.unknownError();
    span?.throwable = e;
    rethrow;
  } finally {
    unawaited(span?.finish());
  }
  return result;
}

Map<String, dynamic>? _defaultHttpResponseDecoder(http.Response httpResponse) {
  return json.decode(utf8.decode(httpResponse.bodyBytes))
      as Map<String, dynamic>?;
}
