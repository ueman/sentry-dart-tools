// @dart = 2.15

import 'dart:async';
import 'dart:io';

import 'package:graphql/client.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_graphql/sentry_graphql.dart';

const personalAccessToken = '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';

Future<void> main() {
  return Sentry.init(
    (options) {
      options.dsn =
          'https://c8f216b28d814d2ca83e52fb735da535@o266569.ingest.sentry.io/5558444';
      options.tracesSampleRate = 1;
      options.debug = true;
    },
    appRunner: example,
  );
}

Future<void> example() async {
  final trx = Sentry.startTransaction('load', 'load', bindToScope: true);

  final link = Link.from([
    AuthLink(getToken: () async => 'Bearer $personalAccessToken'),
    HttpLink(
      'https://api.github.com/graphql',
      httpClient: SentryHttpClient(networkTracing: true),
    ),
  ]);

  final client = SentryGraphQLClient(GraphQLClient(
    cache: GraphQLCache(),
    link: link,
  ));

  final QueryOptions options = QueryOptions<List<Repository>>(
    operationName: 'ReadRepositories',
    document: gql(
      r'''
        query ReadRepositories($nRepositories: Int!) {
          viewer {
            repositories(last: $nRepositories) {
              nodes {
                id
                name
                viewerHasStarred
              }
            }
          }
        }
      ''',
    ),
    variables: {
      'nRepositories': 50,
    },
    parserFn: (data) {
      final repos = data['viewer']['repositories']['nodes'] as List;
      return repos
          .map((e) => e as Map<String, dynamic>)
          .map(Repository.fromJson)
          .toList();
    },
  );

  final result = await client.query(options);
  print(result.parsedData);

  //=========================================

  final QueryOptions failureOptions = QueryOptions(
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

  final failureResult = await client.query(failureOptions);

  print(failureResult.data.toString());

  await trx.finish();
  exit(0);
}

class Repository {
  Repository(this.id, this.name, this.viewerHasStarred);

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      json['id']?.toString(),
      json['name']?.toString(),
      json['viewerHasStarred']?.toString(),
    );
  }

  final String? id;
  final String? name;
  final String? viewerHasStarred;
}
