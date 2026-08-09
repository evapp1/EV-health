/// Stable route names used by the EV Health router.
abstract final class AppRouteNames {
  /// Welcome onboarding screen.
  static const onboardingWelcome = 'onboarding-welcome';

  /// How It Works onboarding screen.
  static const onboardingHowItWorks = 'onboarding-how-it-works';

  /// Privacy onboarding screen.
  static const onboardingPrivacy = 'onboarding-privacy';

  /// Bluetooth explanation onboarding screen.
  static const onboardingBluetooth = 'onboarding-bluetooth';

  /// Simulated adapter discovery setup screen.
  static const adapterDiscovery = 'adapter-discovery';

  /// Demo vehicle confirmation setup screen.
  static const vehicleConfirmation = 'vehicle-confirmation';

  /// Scan preparation shown after explicit vehicle confirmation.
  static const scanPreparation = 'scan-preparation';

  /// Typed demo scan progress shown after explicit preparation hand-off.
  static const scanProgress = 'scan-progress';

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
  /// Welcome onboarding path.
  static const onboardingWelcome = '/onboarding';

  /// How It Works onboarding path.
  static const onboardingHowItWorks = '/onboarding/how-it-works';

  /// Privacy onboarding path.
  static const onboardingPrivacy = '/onboarding/privacy';

  /// Bluetooth explanation onboarding path.
  static const onboardingBluetooth = '/onboarding/bluetooth';

  /// Simulated adapter discovery setup path.
  static const adapterDiscovery = '/setup/adapters';

  /// Demo vehicle confirmation setup path.
  static const vehicleConfirmation = '/setup/vehicle';

  /// Scan preparation path.
  static const scanPreparation = '/scan/prepare';

  /// Scan progress path.
  static const scanProgress = '/scan/progress';

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
