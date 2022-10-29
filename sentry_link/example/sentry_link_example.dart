import 'dart:io';

import 'package:graphql/client.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_link/sentry_link.dart';

const personalAccessToken = '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';

Future<void> main() {
  return Sentry.init(
    (options) {
      options.dsn =
          'https://c8f216b28d814d2ca83e52fb735da535@o266569.ingest.sentry.io/5558444';
      options.addEventProcessor(GqlEventProcessor(options));
      options.tracesSampleRate = 1;
    },
    appRunner: example,
  );
}

Future<void> example() async {
  final link = Link.from([
    SentryLink.link(),
    AuthLink(getToken: () async => 'Bearer $personalAccessToken'),
    SentryTracingLink(shouldStartTransaction: true),
    HttpLink(
      'https://api.github.com/graphql',
      httpClient: SentryHttpClient(networkTracing: true),
      parser: SentryResponseParser(),
      serializer: SentryRequestSerializer(),
    ),
  ]);

  final client = GraphQLClient(
    cache: GraphQLCache(),
    link: link,
  );

  final QueryOptions options = QueryOptions(
    operationName: 'ReadRepositories',
    document: gql(
      r'''
        query ReadRepositories($nRepositories: Int!) {
          viewer {
            repositories(last: $nRepositories) {
              nodes {
                id
                # this one is intentionally wrong, the last char 'e' is missing
                nam
                # this one is intentionally wrong, the last char 'd' is missing
                viewerHasStarre
              }
            }
          }
        }
      ''',
    ),
    variables: {
      'nRepositories': 50,
    },
  );

  final result = await client.query(options);
  print(result.toString());
  await Future<void>.delayed(Duration(seconds: 2));
  exit(0);
}
