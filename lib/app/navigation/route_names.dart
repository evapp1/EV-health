/// Stable route names used by the EV Health router.
abstract final class AppRouteNames {
  /// Home root destination.
  static const home = 'home';

  /// Scan history root destination.
  static const history = 'history';

  /// Saved reports root destination.
  static const reports = 'reports';

  /// Settings root destination.
  static const settings = 'settings';

  /// About and legal placeholder nested under Settings.
  static const settingsAbout = 'settings-about';
}

/// Stable route paths used by the EV Health router.
abstract final class AppRoutePaths {
  /// Home root path.
  static const home = '/home';

  /// Scan history root path.
  static const history = '/history';

  /// Saved reports root path.
  static const reports = '/reports';

  /// Settings root path.
  static const settings = '/settings';

  /// About and legal path nested under Settings.
  static const settingsAbout = '/settings/about';

  /// Paths that represent the root of a shell branch.
  static const rootDestinations = <String>{home, history, reports, settings};
}
