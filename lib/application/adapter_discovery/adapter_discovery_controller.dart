import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Injectable placeholder invoked when mock adapter discovery is retried.
typedef AdapterDiscoveryRetryAction = FutureOr<void> Function();

/// Injectable placeholder invoked when a fictional adapter is selected.
typedef MockAdapterSelectionAction =
    FutureOr<void> Function(MockAdapterCandidate adapter);

/// Supplies the state shown when the mock discovery flow is opened.
final adapterDiscoveryInitialStateProvider = Provider<AdapterDiscoveryState>(
  (ref) => const AdapterDiscoverySearching(),
);

/// Supplies the placeholder retry behaviour for the mock discovery flow.
final adapterDiscoveryRetryActionProvider =
    Provider<AdapterDiscoveryRetryAction>((ref) => () {});

/// Supplies the placeholder selection behaviour for fictional adapters.
final mockAdapterSelectionActionProvider = Provider<MockAdapterSelectionAction>(
  (ref) => (adapter) {},
);

/// Coordinates typed mock discovery state and user intents outside widgets.
final adapterDiscoveryControllerProvider =
    NotifierProvider<AdapterDiscoveryController, AdapterDiscoveryState>(
      AdapterDiscoveryController.new,
    );

/// Application controller for the simulated adapter discovery experience.
final class AdapterDiscoveryController extends Notifier<AdapterDiscoveryState> {
  bool _isRetrying = false;
  bool _isSelecting = false;

  @override
  AdapterDiscoveryState build() {
    return ref.watch(adapterDiscoveryInitialStateProvider);
  }

  /// Restarts the simulated search and invokes the injected placeholder.
  Future<void> retry() async {
    if (_isRetrying) {
      return;
    }

    _isRetrying = true;
    state = const AdapterDiscoverySearching();
    try {
      await ref.read(adapterDiscoveryRetryActionProvider)();
    } finally {
      _isRetrying = false;
    }
  }

  /// Dispatches selection of a listed fictional adapter without connecting.
  Future<void> selectAdapter(MockAdapterCandidate adapter) async {
    final currentState = state;
    if (currentState is! AdapterDiscoveryDevicesFound ||
        !currentState.devices.contains(adapter)) {
      throw StateError('Only a listed mock adapter can be selected.');
    }
    if (_isSelecting) {
      return;
    }

    _isSelecting = true;
    try {
      await ref.read(mockAdapterSelectionActionProvider)(adapter);
    } finally {
      _isSelecting = false;
    }
  }
}

/// A privacy-safe, explicitly fictional adapter candidate for UI simulation.
final class MockAdapterCandidate {
  /// Creates a mock candidate with no platform or hardware identifier.
  const MockAdapterCandidate({
    required this.mockId,
    required this.displayName,
    required this.description,
    required this.isKnownDevice,
  });

  /// A fictional, app-local reference used only by tests and mock UI.
  final String mockId;

  /// An explicitly fictional user-visible device name.
  final String displayName;

  /// Plain-language mock context; it must not claim verified compatibility.
  final String description;

  /// Whether the candidate appears in the mock known-devices group.
  final bool isKnownDevice;
}

/// Base type for every state in simulated adapter discovery.
sealed class AdapterDiscoveryState {
  const AdapterDiscoveryState();
}

/// Simulated discovery is currently searching for fictional devices.
final class AdapterDiscoverySearching extends AdapterDiscoveryState {
  /// Creates the searching state.
  const AdapterDiscoverySearching();
}

/// Simulated discovery returned one or more fictional devices.
final class AdapterDiscoveryDevicesFound extends AdapterDiscoveryState {
  /// Creates an immutable mock result state.
  AdapterDiscoveryDevicesFound(Iterable<MockAdapterCandidate> devices)
    : assert(devices.isNotEmpty, 'Devices-found state cannot be empty.'),
      devices = List.unmodifiable(devices);

  /// Fictional devices available for placeholder selection.
  final List<MockAdapterCandidate> devices;
}

/// Simulated discovery completed without fictional results.
final class AdapterDiscoveryNoDevicesFound extends AdapterDiscoveryState {
  /// Creates the no-devices state.
  const AdapterDiscoveryNoDevicesFound();
}

/// Simulates the Android device having Bluetooth switched off.
final class AdapterDiscoveryBluetoothDisabled extends AdapterDiscoveryState {
  /// Creates the Bluetooth-disabled state.
  const AdapterDiscoveryBluetoothDisabled();
}

/// Simulates nearby-device permission having been denied.
final class AdapterDiscoveryPermissionDenied extends AdapterDiscoveryState {
  /// Creates the permission-denied state.
  const AdapterDiscoveryPermissionDenied();
}

/// Simulates an unexpected but recoverable discovery failure.
final class AdapterDiscoveryRecoverableError extends AdapterDiscoveryState {
  /// Creates a recoverable error with consumer-safe supporting detail.
  const AdapterDiscoveryRecoverableError({
    this.detail =
        'The fictional discovery result is temporarily unavailable. '
        'No adapter or vehicle data was accessed.',
  });

  /// Plain-language failure detail suitable for direct presentation.
  final String detail;
}

/// Representative fictional devices used by the default mock result state.
abstract final class AdapterDiscoveryMockFixtures {
  /// A stable fictional result list with no real hardware identifiers.
  static const devices = <MockAdapterCandidate>[
    MockAdapterCandidate(
      mockId: 'MOCK-AURORA-01',
      displayName: 'Fictional ELM Aurora',
      description: 'Known mock device • compatibility not verified',
      isKnownDevice: true,
    ),
    MockAdapterCandidate(
      mockId: 'MOCK-CIRCUIT-02',
      displayName: 'Mock OBD Circuit',
      description: 'Known mock device • compatibility not verified',
      isKnownDevice: true,
    ),
    MockAdapterCandidate(
      mockId: 'MOCK-NEARBY-03',
      displayName: 'Fictional Nearby Adapter',
      description: 'Nearby mock device • compatibility not verified',
      isKnownDevice: false,
    ),
  ];
}
