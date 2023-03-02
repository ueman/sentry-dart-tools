import 'dart:io';

import 'package:graphql/client.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_link/sentry_link.dart';

const personalAccessToken = 'token';

Future<void> main() {
  return Sentry.init(
    (options) {
      options.dsn = 'sentry_dsn';
      options.tracesSampleRate = 1;
      options.beforeBreadcrumb = graphQlFilter();
      options.addGqlExtractors();
    },
    appRunner: example,
  );
}

Future<void> example() async {
  final link = Link.from([
    AuthLink(getToken: () async => 'Bearer $personalAccessToken'),
    SentryGql.link(
      shouldStartTransaction: true,
      graphQlErrorsMarkTransactionAsFailed: true,
    ),
    HttpLink(
      'https://api.github.com/graphql',
      httpClient: SentryHttpClient(),
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
