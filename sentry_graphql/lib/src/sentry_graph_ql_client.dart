import 'dart:async';

import 'package:graphql/client.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_graphql/src/sentry_query_result.dart';

class SentryGraphQLClient implements GraphQLClient {
  SentryGraphQLClient(this._innerClient, {Hub? hub})
      // ignore: invalid_use_of_internal_member
      : _hub = hub ?? HubAdapter();

  final GraphQLClient _innerClient;
  final Hub _hub;

  @override
  DefaultPolicies get defaultPolicies => _innerClient.defaultPolicies;

  @override
  set defaultPolicies(DefaultPolicies policies) =>
      _innerClient.defaultPolicies = policies;

  @override
  QueryManager get queryManager => _innerClient.queryManager;

  @override
  set queryManager(QueryManager manager) => _innerClient.queryManager = manager;

  @override
  GraphQLCache get cache => _innerClient.cache;

  @override
  GraphQLClient copyWith({
    Link? link,
    GraphQLCache? cache,
    DefaultPolicies? defaultPolicies,
    bool? alwaysRebroadcast,
  }) {
    return SentryGraphQLClient(_innerClient.copyWith(
      link: link,
      cache: cache,
      defaultPolicies: defaultPolicies,
      alwaysRebroadcast: alwaysRebroadcast,
    ));
  }

  @override
  Future<QueryResult<TParsed>> fetchMore<TParsed>(
    FetchMoreOptions fetchMoreOptions, {
    required QueryOptions<TParsed> originalOptions,
    required QueryResult<TParsed> previousResult,
  }) {
    return _innerClient.fetchMore(
      fetchMoreOptions,
      originalOptions: originalOptions,
      previousResult: previousResult,
    );
  }

  @override
  Link get link => _innerClient.link;

  @override
  Future<QueryResult<TParsed>> mutate<TParsed>(
    MutationOptions<TParsed> options,
  ) async {
    return SentryQueryResult<TParsed>(await _wrap(
      op: 'http.graphql.mutation',
      gqlOperationName: 'Mutation: ${options.operationName}, '
          'Serializes to ${(TParsed).toString()}',
      future: _innerClient.mutate(options),
    ));
  }

  @override
  Future<QueryResult<TParsed>> query<TParsed>(
    QueryOptions<TParsed> options,
  ) async {
    return SentryQueryResult<TParsed>(await _wrap(
      op: 'http.graphql.query',
      gqlOperationName: 'Query: ${options.operationName}, '
          'Serializes to ${(TParsed).toString()}',
      future: _innerClient.query(options),
    ));
  }

  @override
  Map<String, dynamic>? readFragment(
    FragmentRequest fragmentRequest, {
    bool? optimistic = true,
  }) =>
      _innerClient.readFragment(fragmentRequest, optimistic: optimistic);

  @override
  Map<String, dynamic>? readQuery(Request request, {bool? optimistic = true}) =>
      _innerClient.readQuery(request, optimistic: optimistic);

  @override
  Future<List<QueryResult<Object?>?>>? resetStore({
    bool refetchQueries = true,
  }) =>
      _innerClient.resetStore(refetchQueries: refetchQueries);

  @override
  Stream<QueryResult<TParsed>> subscribe<TParsed>(
    SubscriptionOptions<TParsed> options,
  ) =>
      _innerClient.subscribe(options);

  @override
  ObservableQuery<TParsed> watchMutation<TParsed>(
    WatchQueryOptions<TParsed> options,
  ) =>
      _innerClient.watchMutation(options);

  @override
  ObservableQuery<TParsed> watchQuery<TParsed>(
    WatchQueryOptions<TParsed> options,
  ) =>
      _innerClient.watchQuery(options);

  @override
  void writeFragment(
    FragmentRequest fragmentRequest, {
    bool? broadcast = true,
    required Map<String, dynamic> data,
  }) =>
      _innerClient.writeFragment(fragmentRequest, broadcast: true, data: data);

  @override
  void writeQuery(
    Request request, {
    required Map<String, dynamic> data,
    bool? broadcast = true,
  }) =>
      _innerClient.writeQuery(request, data: data, broadcast: broadcast);

  Future<QueryResult<TParsed>> _wrap<TParsed>({
    required String op,
    String? gqlOperationName,
    required Future<QueryResult<TParsed>> future,
  }) async {
    final span = _hub.getSpan()?.startChild(
          op,
          description: gqlOperationName,
        );
    QueryResult<TParsed> result;
    try {
      result = await future;
      if (result.hasException) {
        span?.throwable = result.exception;
        span?.status = const SpanStatus.internalError();
      } else {
        span?.status = const SpanStatus.ok();
      }
    } catch (e) {
      span?.status = const SpanStatus.internalError();
      span?.throwable = e;
      rethrow;
    } finally {
      unawaited(span?.finish());
    }
    return result;
  }
}
