import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

typedef ErrorCallback = bool Function(Object exception, StackTrace stackTrace);

/// Integration which captures `PlatformDispatcher.onError`
/// See:
/// - https://master-api.flutter.dev/flutter/dart-ui/PlatformDispatcher/onError.html
///
/// Remarks: 
/// - Not existing on Flutter smaller or equal to 3.0.0
// I believe this integration can replaces the https://github.com/getsentry/sentry-dart/blob/912b9205691837abdd546c62844bc9568b908495/dart/lib/src/default_integrations.dart#L15
// partially, because we don't need the runZoneGuarded anymore. Though, that Zone is still used for print() call recording which means there's some advanced logic needed.
// If the Zone and the print() call recording is not needed, the RunZonedGuardedIntegration should be disabled because that improves the app start performance.
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
