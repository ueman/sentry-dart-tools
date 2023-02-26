import 'package:gql_link/gql_link.dart';
import 'package:sentry/sentry.dart';

// Unfortunately, because extractors are looked up via `Type`, each exception
// needs its own extractor.
// That are quite a bit, so we make it easy by exposing a method which
// adds all of them.
extension GqlExctractors on SentryOptions {
  void addGqlExtractors() {
    addExceptionCauseExtractor(RequestFormatExceptionExtractor());
    addExceptionCauseExtractor(ResponseFormatExceptionExtractor());
    addExceptionCauseExtractor(ContextReadExceptionExtractor());
    addExceptionCauseExtractor(ContextWriteExceptionExtractor());
    addExceptionCauseExtractor(ServerExceptionExtractor());
  }
}

class LinkExceptionExtractor<T extends LinkException>
    extends ExceptionCauseExtractor<T> {
  @override
  ExceptionCause? cause(T error) {
    return ExceptionCause(error.originalException, error.originalStackTrace);
  }
}

class RequestFormatExceptionExtractor
    extends LinkExceptionExtractor<RequestFormatException> {}

class ResponseFormatExceptionExtractor
    extends LinkExceptionExtractor<ResponseFormatException> {}

class ContextReadExceptionExtractor
    extends LinkExceptionExtractor<ContextReadException> {}

class ContextWriteExceptionExtractor
    extends LinkExceptionExtractor<ContextWriteException> {}

class ServerExceptionExtractor extends LinkExceptionExtractor<ServerException> {
}
