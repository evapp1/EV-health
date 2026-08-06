import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:ev_health/application/vehicle_confirmation/vehicle_confirmation_controller.dart';
import 'package:ev_health/features/shared/presentation/widgets/error_panel.dart';
import 'package:ev_health/features/vehicle_confirmation/presentation/models/vehicle_confirmation_view_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Confirms the repository-backed demo profile before any scan preparation.
class VehicleConfirmationScreen extends ConsumerWidget {
  /// Creates the focused vehicle-confirmation route.
  const VehicleConfirmationScreen({
    this.onBack,
    this.onSafeExitComplete,
    super.key,
  });

  /// Route-level Android and app-bar back action.
  final VoidCallback? onBack;

  /// Route-level navigation after the application safe-exit callback succeeds.
  final VoidCallback? onSafeExitComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final confirmation = ref.watch(vehicleConfirmationControllerProvider);
    final controller = ref.read(vehicleConfirmationControllerProvider.notifier);
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
                tooltip: 'Back to adapter discovery',
                icon: const Icon(Icons.arrow_back),
              ),
        title: const Text('Confirm the vehicle'),
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
                  const _MockDisclosure(),
                  const SizedBox(height: AppSpacing.large),
                  confirmation.when(
                    loading: () => const _LoadingState(),
                    error: (error, stackTrace) => _LoadError(onBack: onBack),
                    data: (state) => switch (state) {
                      SupportedVehicleConfirmation(:final vehicle) =>
                        _SupportedState(
                          viewData: VehicleConfirmationViewData.from(vehicle),
                          onConfirm: controller.confirm,
                          onReject: controller.reject,
                        ),
                      ConfirmedVehicleConfirmation(:final vehicle) =>
                        _ConfirmedState(
                          viewData: VehicleConfirmationViewData.from(vehicle),
                        ),
                      UnsupportedVehicleConfirmation() => _UnsupportedState(
                        onSafeExit: () async {
                          await controller.exitUnsupported();
                          onSafeExitComplete?.call();
                        },
                      ),
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

class _SupportedState extends StatelessWidget {
  const _SupportedState({
    required this.viewData,
    required this.onConfirm,
    required this.onReject,
  });

  final VehicleConfirmationViewData viewData;
  final Future<void> Function() onConfirm;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          label: _vehicleSemantics(viewData),
          child: ExcludeSemantics(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Supported demo profile',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).extension<EvHealthColors>()!.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.extraSmall),
                    Text(
                      viewData.displayName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    for (final detail in viewData.details) ...[
                      _ProfileDetailRow(detail: detail),
                      if (detail != viewData.details.last)
                        const Divider(height: AppSpacing.large),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        Text(
          'Is this the vehicle you want to use for this demo flow?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          'EV Health is not detecting a vehicle or checking compatibility '
          'live. Confirm only that this fictional profile matches the demo '
          'you intend to view.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.large),
        Semantics(
          button: true,
          label:
              'Yes, confirm BYD Dolphin Premium demo profile. Does not start '
              'a scan.',
          child: ExcludeSemantics(
            child: FilledButton(
              key: const Key('confirm-supported-vehicle'),
              onPressed: onConfirm,
              child: const Text('Yes, confirm demo vehicle'),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        OutlinedButton(
          key: const Key('reject-supported-vehicle'),
          onPressed: onReject,
          child: const Text("No, this isn't my vehicle"),
        ),
        const SizedBox(height: AppSpacing.large),
        const _WhyConfirmationMatters(),
      ],
    );
  }

  static String _vehicleSemantics(VehicleConfirmationViewData data) {
    final details = data.details
        .map((detail) => '${detail.label}: ${detail.value}')
        .join('. ');
    return 'Supported demo profile. ${data.displayName}. $details.';
  }
}

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({required this.detail});

  final VehicleProfileDetail detail;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack =
            constraints.maxWidth < 400 ||
            MediaQuery.textScalerOf(context).scale(16) >= 24;
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detail.label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.extraSmall),
              Text(detail.value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                detail.label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Flexible(
              child: Text(
                detail.value,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MockDisclosure extends StatelessWidget {
  const _MockDisclosure();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;
    return Semantics(
      container: true,
      label:
          'Demo mock profile. No live vehicle detection, compatibility '
          'verification, vehicle identifier, or scan is used.',
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
                        'DEMO / MOCK PROFILE',
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: colors.info),
                      ),
                      const SizedBox(height: AppSpacing.extraSmall),
                      Text(
                        'No live vehicle detection or compatibility check is '
                        'running. No VIN or other vehicle identifier is read.',
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

class _WhyConfirmationMatters extends StatelessWidget {
  const _WhyConfirmationMatters();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Why confirmation matters. EV battery data uses vehicle-specific '
          'definitions. The wrong profile could produce incorrect results.',
      child: ExcludeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why confirmation matters',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  'EV battery data uses vehicle-specific definitions. Using '
                  'the wrong profile could produce incorrect results.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnsupportedState extends StatelessWidget {
  const _UnsupportedState({required this.onSafeExit});

  final Future<void> Function() onSafeExit;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Vehicle not supported. Only the BYD Dolphin Premium demo profile '
          'is available. Return to adapter discovery. No scan can continue.',
      child: ErrorPanel(
        severity: ErrorPanelSeverity.warning,
        title: 'Vehicle not supported',
        body:
            'This MVP demo flow supports only the BYD Dolphin Premium '
            'profile. EV Health will not continue to scan preparation or '
            'offer generic scanning.',
        dataStatus:
            'No live vehicle data or identifier was read, and no scan was '
            'started.',
        primaryActionLabel: 'Back to adapter discovery',
        onPrimaryAction: onSafeExit,
      ),
    );
  }
}

class _ConfirmedState extends StatelessWidget {
  const _ConfirmedState({required this.viewData});

  final VehicleConfirmationViewData viewData;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;
    return Semantics(
      container: true,
      liveRegion: true,
      label:
          '${viewData.displayName} demo profile confirmed. No scan has '
          'started. Scan preparation is not available yet.',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.positive.withValues(alpha: 0.10),
          borderRadius: AppSpacing.cardRadius,
          border: Border.all(color: colors.positive),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, color: colors.positive),
                  const SizedBox(width: AppSpacing.mediumSmall),
                  Expanded(
                    child: Text(
                      'Demo vehicle confirmed',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                '${viewData.displayName} is selected for this mock flow. No '
                'scan has started.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Scan preparation is not part of this screen. Use Back to '
                'return to adapter discovery.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Loading demo vehicle profile',
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return ErrorPanel(
      severity: ErrorPanelSeverity.error,
      title: 'Demo vehicle profile unavailable',
      body:
          'EV Health could not load the supported demo profile. No vehicle '
          'check or scan was attempted.',
      dataStatus: 'No live vehicle data was accessed.',
      primaryActionLabel: onBack == null ? null : 'Back to adapter discovery',
      onPrimaryAction: onBack,
    );
  }
}
