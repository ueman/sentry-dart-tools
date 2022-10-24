# Sentry integration for `graphql`

Sentry integration for the [`graphql`](https://pub.dev/packages/graphql) and [`graphql_flutter`](https://pub.dev/packages/graphql_flutter) package to add performance monitoring. Use this with [`sentry_link`](https://pub.dev/packages/sentry_link) for even better insights.

## Usage

Just add the various classes from this package to your setup code.
Make sure to wrap the `GraphQLClient` with provided `SentryGraphQLClient` class.
```dart
import 'package:sentry_graphql/sentry_graphql.dart';
import 'package:sentry_link/sentry_link.dart';

final link = Link.from([
    SentryLink.link(), // when used together with `sentry_link`
    AuthLink(getToken: () async => 'Bearer $personalAccessToken'),
    HttpLink(
      'https://api.github.com/graphql',
      httpClient: SentryHttpClient(networkTracing: true),
      serializer: SentryRequestSerializer(),
      parser: SentryResponseParser(),
      httpResponseDecoder: sentryResponseDecoder,
    ),
  ]);

  final client = SentryGraphQLClient(GraphQLClient(
    cache: GraphQLCache(),
    link: link,
  ));
```