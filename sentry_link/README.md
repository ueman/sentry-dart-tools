# Sentry Link (GraphQL)

Integration for the [`gql_link`](https://pub.dev/packages/gql_link) package to collect error reports for GraphQL requests. This is used by a wide variety of GraphQL libraries like [`ferry`](https://pub.dev/packages/ferry) or [`graphql`](https://pub.dev/packages/graphql).


## Usage

Just add `SentryLink.link()` to your links.
```dart
final link = Link.from([
    SentryLink.link(),
    AuthLink(getToken: () async => 'Bearer $personalAccessToken'),
    HttpLink('https://api.github.com/graphql'),
]);
```