import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ExcludeIntegration implements Integration<SentryFlutterOptions> {
  @override
  FutureOr<void> call(Hub hub, SentryFlutterOptions options) {
    // _addInAppExcludes can take a while, so we don't await it,
    // in order to no artificially increase the startup time.
    unawaited(_addInAppExcludes(options));
    options.sdk.addIntegration('ExcludeIntegration');
  }

  @override
  FutureOr<void> close() {}

  Future<void> _addInAppExcludes(SentryFlutterOptions options) async {
    final packages = await _getPackages();
    packages.forEach(options.addInAppExclude);
  }

  /// Packages are loaded from [LicenseRegistry].
  /// This is currently the only way to know which packages are used.
  /// This however has some drawbacks:
  /// - Only packages with licenses are known
  /// - Flutter's native dependencies are also included.
  Future<List<String>> _getPackages() async {
    // This can take some time.
    // Therefore we cache this after running
    var packages = <String>[];
    // The license registry has a list of licenses entries (MIT, Apache...).
    // Each license entry has a list of packages which licensed under this particular license.
    // Libraries can be dual licensed.
    //
    // We don't care about those license issues, we just want each package name once.
    // Therefore we add each name to a set to make sure we only add it once.
    await LicenseRegistry.licenses.forEach(
      (entry) => packages.addAll(
        entry.packages.toList(),
      ),
    );

    return packages;
  }
}
