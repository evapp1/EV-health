import 'package:ev_health/application/adapter_discovery/adapter_discovery_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exposes the injected typed initial mock state', () {
    final expected = AdapterDiscoveryDevicesFound(
      AdapterDiscoveryMockFixtures.devices,
    );
    final container = ProviderContainer(
      overrides: [
        adapterDiscoveryInitialStateProvider.overrideWithValue(expected),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(adapterDiscoveryControllerProvider), same(expected));
  });

  test(
    'retry invokes the injected callback and returns to searching',
    () async {
      var retryCalls = 0;
      final container = ProviderContainer(
        overrides: [
          adapterDiscoveryInitialStateProvider.overrideWithValue(
            const AdapterDiscoveryNoDevicesFound(),
          ),
          adapterDiscoveryRetryActionProvider.overrideWithValue(
            () => retryCalls += 1,
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(adapterDiscoveryControllerProvider.notifier).retry();

      expect(retryCalls, 1);
      expect(
        container.read(adapterDiscoveryControllerProvider),
        isA<AdapterDiscoverySearching>(),
      );
    },
  );

  test(
    'selection invokes the injected callback without changing state',
    () async {
      MockAdapterCandidate? selected;
      final initial = AdapterDiscoveryDevicesFound(
        AdapterDiscoveryMockFixtures.devices,
      );
      final container = ProviderContainer(
        overrides: [
          adapterDiscoveryInitialStateProvider.overrideWithValue(initial),
          mockAdapterSelectionActionProvider.overrideWithValue(
            (adapter) => selected = adapter,
          ),
        ],
      );
      addTearDown(container.dispose);

      final candidate = AdapterDiscoveryMockFixtures.devices.first;
      await container
          .read(adapterDiscoveryControllerProvider.notifier)
          .selectAdapter(candidate);

      expect(selected, same(candidate));
      expect(container.read(adapterDiscoveryControllerProvider), same(initial));
    },
  );

  test('selection rejects a candidate that is not in the current results', () {
    final container = ProviderContainer(
      overrides: [
        adapterDiscoveryInitialStateProvider.overrideWithValue(
          const AdapterDiscoveryNoDevicesFound(),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      () => container
          .read(adapterDiscoveryControllerProvider.notifier)
          .selectAdapter(AdapterDiscoveryMockFixtures.devices.first),
      throwsStateError,
    );
  });
}
