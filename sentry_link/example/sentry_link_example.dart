import 'dart:io';

import 'package:graphql/client.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_link/sentry_link.dart';

const personalAccessToken = '<github personal access token>';

Future<void> main() {
  return Sentry.init(
    (options) {
      options.dsn =
          'https://c8f216b28d814d2ca83e52fb735da535@o266569.ingest.sentry.io/5558444';
    },
    appRunner: example,
  );
}

Future<void> example() async {
  final link = Link.from([
    SentryLink.link(),
    AuthLink(getToken: () async => 'Bearer $personalAccessToken'),
    HttpLink('https://api.github.com/graphql'),
  ]);

  final client = GraphQLClient(
    cache: GraphQLCache(),
    link: link,
  );

  final QueryOptions options = QueryOptions(
    document: gql(
      r'''
        query ReadRepositories($nRepositories: Int!) {
          viewer {
            repositories(last: $nRepositories) {
              nodes {
                __typename
                id
                name
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
  exit(0);
}
