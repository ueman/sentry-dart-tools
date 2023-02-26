# Sentry Link (GraphQL)

[![pub package](https://img.shields.io/pub/v/sentry_link.svg)](https://pub.dev/packages/sentry_link) [![likes](https://img.shields.io/pub/likes/sentry_link)](https://pub.dev/packages/sentry_link/score) [![popularity](https://img.shields.io/pub/popularity/sentry_link)](https://pub.dev/packages/sentry_link/score) [![pub points](https://img.shields.io/pub/points/sentry_link)](https://pub.dev/packages/sentry_link/score)

## Compatibility list

This integration is compatible with the following packages. It's also compatible with other packages which are build on `gql` suite of packages.

| package | stats |
|---------|-------|
| [`gql_link`](https://pub.dev/packages/gql_link) | <a href="https://pub.dev/packages/graphql/score"><img src="https://img.shields.io/pub/likes/gql_link" alt="likes"></a> <a href="https://pub.dev/packages/gql_link/score"><img src="https://img.shields.io/pub/popularity/gql_link" alt="popularity"></a> <a href="https://pub.dev/packages/gql_link/score"><img src="https://img.shields.io/pub/points/gql_link" alt="pub points"></a> |
| [`graphql`](https://pub.dev/packages/graphql) | <a href="https://pub.dev/packages/graphql/score"><img src="https://img.shields.io/pub/likes/graphql" alt="likes"></a> <a href="https://pub.dev/packages/graphql/score"><img src="https://img.shields.io/pub/popularity/graphql" alt="popularity"></a> <a href="https://pub.dev/packages/graphql/score"><img src="https://img.shields.io/pub/points/graphql" alt="pub points"></a> |
| [`ferry`](https://pub.dev/packages/ferry) | <a href="https://pub.dev/packages/ferry/score"><img src="https://img.shields.io/pub/likes/ferry" alt="likes"></a> <a href="https://pub.dev/packages/ferry/score"><img src="https://img.shields.io/pub/popularity/ferry" alt="popularity"></a> <a href="https://pub.dev/packages/ferry/score"><img src="https://img.shields.io/pub/points/ferry" alt="pub points"></a> |
| [`artemis`](https://pub.dev/packages/artemis) | <a href="https://pub.dev/packages/artemis/score"><img src="https://img.shields.io/pub/likes/artemis" alt="likes"></a> <a href="https://pub.dev/packages/artemis/score"><img src="https://img.shields.io/pub/popularity/artemis" alt="popularity"></a> <a href="https://pub.dev/packages/artemis/score"><img src="https://img.shields.io/pub/points/artemis" alt="pub points"></a> |

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

In addition to that, you can add `GqlEventProcessor` to Sentry's event processor, to improve support for nested [`LinkException`](https://pub.dev/documentation/gql_link/latest/link/LinkException-class.html)s and its subclasses.

A GraphQL error will be reported like the following screenshot: 
<img src="https://raw.githubusercontent.com/ueman/sentry-dart-tools/main/sentry_link/screenshot.png" />

## `SentryBreadcrumbLink`

The `SentryBreadcrumbLink` adds breadcrumbs for every succesful GraphQL operation. Failed operations can be added as breadcrumbs via `SentryLink.link()`.

## `SentryResponseParser` and `SentryRequestSerializer` 

The `SentryResponseParser` and `SentryRequestSerializer` classes can be used to trace the serialization process. 
Both classes work with [`HttpLink`](https://pub.dev/packages/gql_http_link) and [`DioLink`](https://pub.dev/packages/gql_dio_link). 
When using the `HttpLink`, you can additionally use the `sentryResponseDecoder` function.

### `HttpLink` example

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
```

### `DioLink` example

This example also uses the [`sentry_dio`](https://pub.dev/packages/sentry_dio) integration.

```dart
import 'package:sentry_link/sentry_link.dart';
import 'package:sentry_dio/sentry_dio.dart';

final link = Link.from([
    SentryLink.link(),
    AuthLink(getToken: () async => 'Bearer $personalAccessToken'),
    SentryTracingLink(shouldStartTransaction: true),
    DioLink(
      'https://api.github.com/graphql',
      client: Dio()..addSentry(networkTracing: true),
      serializer: SentryRequestSerializer(),
      parser: SentryResponseParser(),
    ),
  ]);
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
  SentryTracingLink(shouldStartTransaction: true),
  AuthLink(getToken: () async => 'Bearer $personalAccessToken'),
  HttpLink(
    'https://api.github.com/graphql',
    httpClient: SentryHttpClient(networkTracing: true),
    serializer: SentryRequestSerializer(),
    parser: SentryResponseParser(),
    httpResponseDecoder: sentryResponseDecoder,
  ),
]);

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

# Filter redundant HTTP breadcrumbs

If you use the [`sentry_dio`](https://pub.dev/packages/sentry_dio) or [`http`](https://pub.dev/documentation/sentry/latest/sentry_io/SentryHttpClient-class.html) you will have breadcrumbs attached for every HTTP request. In order to not have duplicated breadcrumbs from the HTTP integrations and this GraphQL integration,
you should filter those breadcrumbs.

That can be achieved in two ways:

1. Disable all HTTP breadcrumbs.
2. Use [`beforeBreadcrumb`](https://pub.dev/documentation/sentry/latest/sentry_io/SentryOptions/beforeBreadcrumb.html).

## 📣 About the author

- [![Twitter Follow](https://img.shields.io/twitter/follow/ue_man?style=social)](https://twitter.com/ue_man)
- [![GitHub followers](https://img.shields.io/github/followers/ueman?style=social)](https://github.com/ueman)
