import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:ev_health/application/adapter_discovery/adapter_discovery_controller.dart';
import 'package:ev_health/features/shared/presentation/widgets/empty_state.dart';
import 'package:ev_health/features/shared/presentation/widgets/error_panel.dart';
import 'package:ev_health/features/shared/presentation/widgets/scan_step_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Focused adapter discovery route backed only by simulated application state.
class AdapterDiscoveryScreen extends ConsumerWidget {
  /// Creates the mock adapter discovery screen.
  const AdapterDiscoveryScreen({
    this.onBack,
    this.onSelectionComplete,
    super.key,
  });

  /// Optional route-level action used for predictable setup-flow back.
  final VoidCallback? onBack;

  /// Optional route-level action after fictional selection succeeds.
  final VoidCallback? onSelectionComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adapterDiscoveryControllerProvider);
    final controller = ref.read(adapterDiscoveryControllerProvider.notifier);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth >= 840
        ? AppSpacing.screenExpanded
        : screenWidth >= 600
        ? AppSpacing.screenMedium
        : AppSpacing.screenCompact;

    final scaffold = Scaffold(
      appBar: AppBar(
        leading: onBack == null
            ? null
            : IconButton(
                onPressed: onBack,
                tooltip: 'Back to Home',
                icon: const Icon(Icons.arrow_back),
              ),
        title: const Text('Choose your adapter'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            AppSpacing.medium,
            horizontalPadding,
            AppSpacing.extraLarge,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SimulationDisclosure(),
                  const SizedBox(height: AppSpacing.large),
                  _DiscoveryStateContent(
                    state: state,
                    onRetry: controller.retry,
                    onSelect: (adapter) async {
                      await controller.selectAdapter(adapter);
                      onSelectionComplete?.call();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final backAction = onBack;
    if (backAction == null) {
      return scaffold;
    }
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          backAction();
        }
      },
      child: scaffold,
    );
  }
}

class _SimulationDisclosure extends StatelessWidget {
  const _SimulationDisclosure();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;

    return Semantics(
      container: true,
      label:
          'Simulated discovery. No Bluetooth search, Android permission '
          'request, adapter connection, or vehicle communication occurs.',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.info.withValues(alpha: 0.10),
            borderRadius: AppSpacing.cardRadius,
            border: Border.all(color: colors.info),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.science_outlined, color: colors.info),
                const SizedBox(width: AppSpacing.mediumSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SIMULATED DISCOVERY',
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: colors.info),
                      ),
                      const SizedBox(height: AppSpacing.extraSmall),
                      Text(
                        'This mock experience does not search Bluetooth, '
                        'request Android permissions, connect to an adapter, '
                        'or communicate with a vehicle.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscoveryStateContent extends StatelessWidget {
  const _DiscoveryStateContent({
    required this.state,
    required this.onRetry,
    required this.onSelect,
  });

  final AdapterDiscoveryState state;
  final Future<void> Function() onRetry;
  final Future<void> Function(MockAdapterCandidate adapter) onSelect;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AdapterDiscoverySearching() => const _SearchingState(),
      AdapterDiscoveryDevicesFound(:final devices) => _DevicesFoundState(
        devices: devices,
        onSelect: onSelect,
      ),
      AdapterDiscoveryNoDevicesFound() => _StatusSemantics(
        label:
            'Simulated search complete. No mock adapters found. Search again '
            'is available.',
        child: EmptyState(
          icon: Icons.bluetooth_searching,
          title: 'No mock adapters found',
          body:
              'This simulated search returned no fictional devices. In a '
              'real setup, check that the adapter is plugged in, discoverable, '
              'and that Bluetooth is on.',
          primaryActionLabel: 'Search again',
          onPrimaryAction: onRetry,
        ),
      ),
      AdapterDiscoveryBluetoothDisabled() => _StatusSemantics(
        label: 'Simulated state. Bluetooth is off. Check again is available.',
        child: ErrorPanel(
          severity: ErrorPanelSeverity.warning,
          title: 'Bluetooth is off — simulated state',
          body:
              'A real adapter search needs Bluetooth turned on. This mock '
              'screen cannot change Android Bluetooth settings.',
          dataStatus: 'No Bluetooth setting was read or changed.',
          primaryActionLabel: 'Check again',
          onPrimaryAction: onRetry,
        ),
      ),
      AdapterDiscoveryPermissionDenied() => _StatusSemantics(
        label:
            'Simulated state. Bluetooth permission is denied. Check again is '
            'available.',
        child: ErrorPanel(
          severity: ErrorPanelSeverity.warning,
          title: 'Bluetooth access is off — simulated state',
          body:
              'For a future real scan, nearby-device access can be allowed in '
              'Android Settings. This mock flow does not request permission.',
          dataStatus: 'No Android permission API was called.',
          primaryActionLabel: 'Check again',
          onPrimaryAction: onRetry,
        ),
      ),
      AdapterDiscoveryRecoverableError(:final detail) => _StatusSemantics(
        label:
            'Simulated discovery error. The mock search could not finish. Try '
            'again is available.',
        child: ErrorPanel(
          severity: ErrorPanelSeverity.error,
          title: 'Mock search could not finish',
          body: detail,
          dataStatus: 'No Bluetooth, adapter, or vehicle data was accessed.',
          primaryActionLabel: 'Try again',
          onPrimaryAction: onRetry,
        ),
      ),
    };
  }
}

class _StatusSemantics extends StatelessWidget {
  const _StatusSemantics({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: label,
      child: child,
    );
  }
}

class _SearchingState extends StatelessWidget {
  const _SearchingState();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label:
          'Simulated adapter search in progress. Searching fictional nearby '
          'devices. No Bluetooth API is active.',
      child: ExcludeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Searching nearby…',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.medium),
                const ScanStepRow(
                  title: 'Mock adapter discovery',
                  state: ScanStepState.active,
                  detail:
                      'Cycling through a simulated state only; no hardware '
                      'search is running.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DevicesFoundState extends StatelessWidget {
  const _DevicesFoundState({required this.devices, required this.onSelect});

  final List<MockAdapterCandidate> devices;
  final Future<void> Function(MockAdapterCandidate adapter) onSelect;

  @override
  Widget build(BuildContext context) {
    final known = devices.where((device) => device.isKnownDevice).toList();
    final nearby = devices.where((device) => !device.isKnownDevice).toList();

    return Semantics(
      container: true,
      label:
          'Simulated search complete. ${devices.length} fictional mock '
          'adapters found. Compatibility has not been verified.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Representative mock devices',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'These fictional ELM327-style names are for interface testing. '
            'EV Health has not verified their compatibility.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (known.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.large),
            _DeviceGroup(
              title: 'Known mock devices',
              devices: known,
              onSelect: onSelect,
            ),
          ],
          if (nearby.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.large),
            _DeviceGroup(
              title: 'Other fictional nearby devices',
              devices: nearby,
              onSelect: onSelect,
            ),
          ],
        ],
      ),
    );
  }
}

class _DeviceGroup extends StatelessWidget {
  const _DeviceGroup({
    required this.title,
    required this.devices,
    required this.onSelect,
  });

  final String title;
  final List<MockAdapterCandidate> devices;
  final Future<void> Function(MockAdapterCandidate adapter) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: AppSpacing.small),
        for (final device in devices) ...[
          _MockAdapterRow(device: device, onSelect: () => onSelect(device)),
          if (device != devices.last) const SizedBox(height: AppSpacing.small),
        ],
      ],
    );
  }
}

class _MockAdapterRow extends StatelessWidget {
  const _MockAdapterRow({required this.device, required this.onSelect});

  final MockAdapterCandidate device;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;

    return Semantics(
      button: true,
      label:
          '${device.displayName}. ${device.description}. Mock reference '
          '${device.mockId}. Select fictional adapter. Compatibility has not '
          'been verified.',
      child: ExcludeSemantics(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: Key('mock-adapter-${device.mockId}'),
            onTap: onSelect,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minimumTouchTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.extraSmall,
                      ),
                      child: Icon(Icons.bluetooth, color: colors.primary),
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.displayName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.extraSmall),
                          Text(
                            device.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.extraSmall),
                          Text(
                            'Mock reference: ${device.mockId}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.small),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
