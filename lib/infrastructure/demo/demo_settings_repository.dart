import 'package:ev_health/domain/models/app_settings.dart';
import 'package:ev_health/domain/repositories/settings_repository.dart';
import 'package:ev_health/infrastructure/demo/demo_fixture.dart';
import 'package:ev_health/infrastructure/demo/demo_repository_write_exception.dart';

/// Read-only settings repository for the labelled fictional demo experience.
final class DemoSettingsRepository implements SettingsRepository {
  /// Creates deterministic demo-mode settings.
  const DemoSettingsRepository();

  @override
  Future<AppSettings> load() async => DemoFixture.settings;

  @override
  Future<void> save(AppSettings settings) =>
      Future<void>.error(const DemoRepositoryWriteException('save'));
}
