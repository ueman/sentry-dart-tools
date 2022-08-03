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

In addition to that, you can add `GqlEventProcessor` to Sentry's event processor, to improve support for nested `LinkExceptions`. 

A GraphQL error will be reported like the following screenshot: 
<img src="https://raw.githubusercontent.com/ueman/sentry-dart-tools/main/sentry_link/screenshot.png" />
