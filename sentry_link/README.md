# Sentry Link (GraphQL)

[![pub package](https://img.shields.io/pub/v/sentry_link.svg)](https://pub.dev/packages/sentry_link) [![likes](https://img.shields.io/pub/likes/sentry_link)](https://pub.dev/packages/sentry_link/score) [![popularity](https://img.shields.io/pub/popularity/sentry_link)](https://pub.dev/packages/sentry_link/score) [![pub points](https://img.shields.io/pub/points/sentry_link)](https://pub.dev/packages/sentry_link/score)

Integration for the [`gql_link`](https://pub.dev/packages/gql_link) package to collect error reports for GraphQL requests.
This is used by a wide variety of GraphQL libraries like [`ferry`](https://pub.dev/packages/ferry), [`graphql`](https://pub.dev/packages/graphql) or [`artemis`](https://pub.dev/packages/artemis)

## Usage

Just add `SentryLink.link()` and/or `SentryTracingLink` to your links.
It will add error reporting and performance monitoring to your GraphQL operations.
```dart
final link = Link.from([
    AuthLink(getToken: () async => 'Bearer $personalAccessToken'),
    // SentryLink records exceptions
    SentryLink.link(),
    // SentryTracingLink adds performance tracing with Sentry
    SentryTracingLink(shouldStartTransaction: true),
    HttpLink('https://api.github.com/graphql'),
]);
```

In addition to that, you can add `GqlEventProcessor` to Sentry's event processor, to improve support for nested `LinkExceptions`. 

A GraphQL error will be reported like the following screenshot: 
<img src="https://raw.githubusercontent.com/ueman/sentry-dart-tools/main/sentry_link/screenshot.png" />


## `SentryResponseParser` and `SentryRequestSerializer` 

The `SentryResponseParser` and `SentryRequestSerializer` classes can be used to trace the serialization process. 
Both classes work with `HttpLink` and `DioLink`. 
When using the `HttpLink`, you can additionally use the `sentryResponseDecoder` function.

```dart
import 'package:sentry_link/sentry_link.dart';

final link = Link.from([
    SentryLink.link(),
    AuthLink(getToken: () async => 'Bearer $personalAccessToken'),
    SentryTracingLink(shouldStartTransaction: true),
    HttpLink(
      'https://api.github.com/graphql',
      httpClient: SentryHttpClient(networkTracing: true),
      serializer: SentryRequestSerializer(),
      parser: SentryResponseParser(),
    ),
  ]);

  final client = GraphQLClient(
    cache: GraphQLCache(),
    link: link,
  );
```

<details>
  <summary>HttpLink</summary>

# Bonus `HttpLink` tracing

```dart
import 'dart:async';
import 'dart:convert';

import 'package:sentry/sentry.dart';
import 'package:http/http.dart' as http;

import 'package:sentry_link/sentry_link.dart';

final link = Link.from([
  SentryLink.link(),
  AuthLink(getToken: () async => 'Bearer $personalAccessToken'),
  SentryTracingLink(shouldStartTransaction: true),
  HttpLink(
    'https://api.github.com/graphql',
    httpClient: SentryHttpClient(networkTracing: true),
    serializer: SentryRequestSerializer(),
    parser: SentryResponseParser(),
    httpResponseDecoder: sentryResponseDecoder,
  ),
]);

final client = GraphQLClient(
  cache: GraphQLCache(),
  link: link,
);

Map<String, dynamic>? sentryResponseDecoder(
  http.Response response, {
  Hub? hub,
}) {
  final currentHub = hub ?? HubAdapter();
  final span = currentHub.getSpan()?.startChild(
        'serialize.http.client',
        description: 'http response deserialization',
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
```

</details>

## 📣 About the author

- [![Twitter Follow](https://img.shields.io/twitter/follow/ue_man?style=social)](https://twitter.com/ue_man)
- [![GitHub followers](https://img.shields.io/github/followers/ueman?style=social)](https://github.com/ueman)
