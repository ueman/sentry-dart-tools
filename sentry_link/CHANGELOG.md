## 0.3.0

- Proper support for GraphQL in Sentry. Sentry added proper support for GraphQL errors in with [#33723](https://github.com/getsentry/sentry/issues/33723) and this library now sends it as per spec.

## 0.2.1

- fix readme

## 0.2.0

This version contains breaking changes

- Require Sentry v7
- Instead of multiple `Link`s, there's now just a single one. See the readme for usage instructions
- Add exception extractors for unwrapping of nested `LinkException`
- Add a filter to remove duplicated http breadcrumbs. See readme for usage instructions

## 0.1.3

- Added filter for http breadcrumbs.

## 0.1.2

- Add ability to add breadcrumbs for GraphQL operations

## 0.1.2

- Update `gql` dependencies
- Add inner exceptions for event processor

## 0.1.0

- Add `SentryTracingLink` which creates performance traces 
- Add `SentryResponseParser`, `SentryRequestSerializer` and `sentryResponseDecoder` which create spans for (de)serialization operations

## 0.0.3

- Fix an invalid usage of Sentry's context
- Add event processor for nested LinkExceptions

## 0.0.2

- Update dependencies and add some docs

## 0.0.1

- Initial version.
