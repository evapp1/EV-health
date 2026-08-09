import 'package:ev_health/app/app.dart';
import 'package:ev_health/bootstrap.dart';
import 'package:ev_health/infrastructure/demo/demo_scan_progress_coordinator.dart';

/// Starts the development EV Health application.
void main() {
  const initialRoute = String.fromEnvironment('EV_HEALTH_INITIAL_ROUTE');
  const scenarioName = String.fromEnvironment(
    'EV_HEALTH_DEMO_SCAN_SCENARIO',
    defaultValue: 'complete',
  );
  if (initialRoute.isNotEmpty && initialRoute != '/setup/vehicle') {
    throw StateError(
      'EV_HEALTH_INITIAL_ROUTE supports only /setup/vehicle in development.',
    );
  }
  bootstrap(
    EvHealthApp(
      initialLocation: initialRoute.isEmpty ? null : initialRoute,
      demoScanScenario: _scenarioFromName(scenarioName),
    ),
  );
}

DemoScanScenario _scenarioFromName(String value) => switch (value) {
  'complete' => DemoScanScenario.complete,
  'partial' => DemoScanScenario.partial,
  'failed' => DemoScanScenario.failed,
  'cancelled' => DemoScanScenario.cancelled,
  'long-running' => DemoScanScenario.longRunningComplete,
  _ => throw StateError('Unsupported demo scan scenario: $value'),
};
