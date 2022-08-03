import 'dart:async';

import 'package:gql_link/gql_link.dart';
import 'package:sentry/sentry.dart';
// ignore: implementation_imports
import 'package:sentry/src/sentry_exception_factory.dart';

class GqlEventProcessor extends EventProcessor {
  GqlEventProcessor(this._options);

  final SentryOptions _options;
  SentryExceptionFactory get _sentryExceptionFactory =>
      // ignore: invalid_use_of_internal_member
      _options.exceptionFactory;

  @override
  FutureOr<SentryEvent?> apply(SentryEvent event, {dynamic hint}) {
    final throwable = event.throwable;

    // Also usable for
    // - RequestFormatException
    // - ResponseFormatException
    // - ContextReadException
    // - ContextWriteException
    // - ServerException
    if (throwable is! LinkException) {
      return event;
    }

    final exceptions = <Object>[];
    _extractExceptions(throwable, exceptions);

    final sentryExceptions = <SentryException>[];

    for (final e in exceptions) {
      sentryExceptions.add(_sentryExceptionFactory.getSentryException(e));
    }

    return event.copyWith(
      exceptions: [
        ...?event.exceptions,
        ...sentryExceptions,
      ],
    );
  }
}

void _extractExceptions(Object exception, List<Object> exceptions) {
  // Also usable for
  // - RequestFormatException
  // - ResponseFormatException
  // - ContextReadException
  // - ContextWriteException
  // - ServerException
  if (exception is LinkException) {
    final innerException = exception.originalException;
    if (innerException is LinkException) {
      exceptions.add(innerException);
      return _extractExceptions(innerException, exceptions);
    }
  }
}
