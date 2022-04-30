import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

typedef ErrorCallback = bool Function(Object exception, StackTrace stackTrace);

/// Integration which captures `PlatformDispatcher.onError`
/// See:
/// - https://master-api.flutter.dev/flutter/dart-ui/PlatformDispatcher/onError.html
///
/// Remarks: Not existing on Flutter smaller or equal to 2.13.0-0
class OnErrorIntegration implements Integration<SentryFlutterOptions> {
  ErrorCallback? _defaultOnError;
  ErrorCallback? _integrationOnError;

  ErrorCallback? get _platformDispatcherOnError =>
      (_dispatcher as dynamic).onError as ErrorCallback?;

  set _platformDispatcherOnError(ErrorCallback? callback) {
    (_dispatcher as dynamic).onError = callback;
  }

  PlatformDispatcher get _dispatcher => _binding!.platformDispatcher;

  WidgetsBinding? get _binding => WidgetsBinding.instance;

  @override
  FutureOr<void> call(Hub hub, SentryFlutterOptions options) {
    try {
      _defaultOnError = _platformDispatcherOnError;

      _integrationOnError = (Object exception, StackTrace stackTrace) {
        final handled = _defaultOnError?.call(exception, stackTrace);

        // As per docs, the app might crash on some platforms
        // after this is called.
        // https://master-api.flutter.dev/flutter/dart-ui/PlatformDispatcher/onError.html
        final mechanism = Mechanism(
          type: 'PlatformDispatcher.onError',
          handled: handled ?? false,
        );
        final throwableMechanism = ThrowableMechanism(mechanism, exception);

        var event = SentryEvent(
          throwable: throwableMechanism,
          level: SentryLevel.fatal,
        );

        hub.captureEvent(event, stackTrace: stackTrace);

        return handled ?? false;
      };

      _platformDispatcherOnError = _integrationOnError;

      options.sdk.addIntegration('PlatformDispatcher.onError');
    } on NoSuchMethodError catch (_) {
      options.logger(
        SentryLevel.info,
        'PlatformDispatcher.onError is not supported on this Flutter version',
      );
    }
  }

  @override
  FutureOr<void> close() async {
    /// Restore default if the integration error is still set.
    if (_platformDispatcherOnError == _integrationOnError) {
      _platformDispatcherOnError = _defaultOnError;
      _defaultOnError = null;
      _integrationOnError = null;
    }
  }
}
