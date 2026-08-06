import 'package:ev_health/domain/models/app_settings.dart';

/// Persistence-agnostic access to application settings.
abstract interface class SettingsRepository {
  /// Loads the current settings snapshot.
  Future<AppSettings> load();

  /// Saves [settings] when the implementation supports mutation.
  Future<void> save(AppSettings settings);
}
