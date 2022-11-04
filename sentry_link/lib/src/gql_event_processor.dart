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

    final exceptions = <_Container>[];
    _extractExceptions(throwable, exceptions);

    final sentryExceptions = <SentryException>[];

    for (final e in exceptions) {
      sentryExceptions.add(_sentryExceptionFactory
          .getSentryException(e.exception, stackTrace: e.stackTrace));
    }

    return event.copyWith(
      exceptions: [
        ...?event.exceptions,
        ...sentryExceptions,
      ],
    );
  }
}

void _extractExceptions(Object exception, List<_Container> exceptions) {
  // Also usable for
  // - RequestFormatException
  // - ResponseFormatException
  // - ContextReadException
  // - ContextWriteException
  // - ServerException
  if (exception is LinkException) {
    final innerException = exception.originalException;
    if (innerException != null) {
      exceptions.add(_Container(innerException, exception.originalStackTrace));
      return _extractExceptions(innerException, exceptions);
    }
  }
}

class _Container {
  _Container(this.exception, this.stackTrace);

  final Object? exception;
  final StackTrace? stackTrace;
}
