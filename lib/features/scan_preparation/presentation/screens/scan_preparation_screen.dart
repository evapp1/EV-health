import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:ev_health/application/scan_preparation/scan_preparation_configuration.dart';
import 'package:ev_health/application/scan_preparation/scan_preparation_controller.dart';
import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/vehicle.dart';
import 'package:ev_health/features/shared/presentation/widgets/error_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Explains safe preparation and waits for an explicit Start Scan intent.
class ScanPreparationScreen extends ConsumerWidget {
  /// Creates the focused scan-preparation route.
  const ScanPreparationScreen({this.onBack, super.key});

  /// Route-level back/cancel action to vehicle confirmation.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preparation = ref.watch(scanPreparationControllerProvider);
    final controller = ref.read(scanPreparationControllerProvider.notifier);
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
                tooltip: 'Back to vehicle confirmation',
                icon: const Icon(Icons.arrow_back),
              ),
        title: const Text('Prepare for battery scan'),
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
                  if (preparation.vehicle.source == DataSource.demo) ...[
                    const _DemoDisclosure(),
                    const SizedBox(height: AppSpacing.large),
                  ],
                  _VehicleSummary(vehicle: preparation.vehicle),
                  const SizedBox(height: AppSpacing.large),
                  switch (preparation) {
                    ScanPreparationReady(:final instructions) =>
                      _PreparationContent(
                        instructions: instructions,
                        onStart: controller.startScan,
                        onCancel: onBack,
                      ),
                    ScanPreparationStarting(:final instructions) =>
                      _PreparationContent(
                        instructions: instructions,
                        isStarting: true,
                        onStart: null,
                        onCancel: onBack,
                      ),
                    ScanPreparationStartRequested(:final instructions) =>
                      _StartRequested(
                        instructions: instructions,
                        onBack: onBack,
                      ),
                    ScanPreparationStartFailed(:final instructions) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PreparationGuidance(instructions: instructions),
                        const SizedBox(height: AppSpacing.large),
                        ErrorPanel(
                          severity: ErrorPanelSeverity.error,
                          title: 'The scan could not start',
                          body:
                              'The application hand-off did not complete. '
                              'No scan was started and no vehicle data was read.',
                          primaryActionLabel: 'Try Start Scan again',
                          onPrimaryAction: controller.retry,
                          secondaryActionLabel: onBack == null
                              ? null
                              : 'Cancel',
                          onSecondaryAction: onBack,
                        ),
                      ],
                    ),
                    ScanPreparationUnavailable() => ErrorPanel(
                      severity: ErrorPanelSeverity.warning,
                      title: 'Preparation instructions unavailable',
                      body:
                          'EV Health does not have preparation instructions '
                          'for this exact vehicle profile and version.',
                      dataStatus:
                          'Start Scan is disabled so the app cannot continue '
                          'without the required vehicle power-state guidance.',
                      primaryActionLabel: onBack == null
                          ? null
                          : 'Back to vehicle confirmation',
                      onPrimaryAction: onBack,
                    ),
                  },
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

class _PreparationContent extends StatelessWidget {
  const _PreparationContent({
    required this.instructions,
    required this.onStart,
    required this.onCancel,
    this.isStarting = false,
  });

  final VehiclePreparationInstructions instructions;
  final Future<void> Function()? onStart;
  final VoidCallback? onCancel;
  final bool isStarting;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PreparationGuidance(instructions: instructions),
        const SizedBox(height: AppSpacing.large),
        Semantics(
          button: true,
          enabled: onStart != null,
          label:
              'Start Scan. Explicitly continue from preparation. Opening '
              'this screen does not start a scan.',
          child: ExcludeSemantics(
            child: FilledButton(
              key: const Key('start-scan-action'),
              onPressed: onStart,
              child: isStarting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: AppSpacing.small),
                        Flexible(child: Text('Starting scan…')),
                      ],
                    )
                  : const Text('Start Scan'),
            ),
          ),
        ),
        if (onCancel != null) ...[
          const SizedBox(height: AppSpacing.small),
          OutlinedButton(onPressed: onCancel, child: const Text('Cancel')),
        ],
      ],
    );
  }
}

class _PreparationGuidance extends StatelessWidget {
  const _PreparationGuidance({required this.instructions});

  final VehiclePreparationInstructions instructions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Before you start',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        Semantics(
          container: true,
          label:
              'Safety and preparation guidance. Park safely before using EV '
              'Health and do not use the app while driving. Select Park and '
              'apply the parking brake. ${instructions.powerStateInstruction} '
              'Keep your phone near the adapter. Close other OBD apps.',
          child: ExcludeSemantics(
            child: Column(
              children: [
                const _PreparationStep(
                  text:
                      'Park safely before using EV Health. Do not use the app while driving.',
                ),
                const _PreparationStep(
                  text: 'Select Park and apply the parking brake.',
                ),
                _PreparationStep(
                  key: const Key('power-state-instruction'),
                  text: instructions.powerStateInstruction,
                ),
                const _PreparationStep(
                  text: 'Keep your phone near the adapter.',
                ),
                const _PreparationStep(text: 'Close other OBD apps.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        const _ReadOnlyNotice(),
        const SizedBox(height: AppSpacing.medium),
        _InstructionQualification(basis: instructions.basis),
      ],
    );
  }
}

class _PreparationStep extends StatelessWidget {
  const _PreparationStep({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.extraSmall),
            child: Icon(Icons.check_circle_outline, color: colors.positive),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyNotice extends StatelessWidget {
  const _ReadOnlyNotice();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;
    return Semantics(
      container: true,
      label:
          'Read-only scan guidance. The intended battery scan is read-only. '
          'EV Health will not change vehicle settings or clear faults.',
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
                Icon(Icons.info_outline, color: colors.info),
                const SizedBox(width: AppSpacing.mediumSmall),
                Expanded(
                  child: Text(
                    'The intended battery scan is read-only. EV Health will '
                    'not change vehicle settings or clear faults.',
                    style: Theme.of(context).textTheme.bodyLarge,
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

class _InstructionQualification extends StatelessWidget {
  const _InstructionQualification({required this.basis});

  final PreparationInstructionBasis basis;

  @override
  Widget build(BuildContext context) {
    final copy = switch (basis) {
      PreparationInstructionBasis.demoAssumption =>
        'Demo preparation only. This instruction has not been validated on a '
            'real vehicle and no vehicle connection is used.',
      PreparationInstructionBasis.unvalidatedProcedure =>
        'This preparation procedure has not yet been validated on the '
            'reference vehicle. Do not continue without approved guidance.',
      PreparationInstructionBasis.referenceVehicleValidated =>
        'This preparation procedure is backed by recorded reference-vehicle '
            'validation.',
    };
    return Semantics(container: true, label: copy, child: Text(copy));
  }
}

class _DemoDisclosure extends StatelessWidget {
  const _DemoDisclosure();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;
    return Semantics(
      container: true,
      label:
          'Demo Mode. Fictional preparation flow. No vehicle connection, '
          'vehicle instruction validation, or live scan is used.',
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
                        'DEMO MODE',
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: colors.info),
                      ),
                      const SizedBox(height: AppSpacing.extraSmall),
                      Text(
                        'Fictional preparation flow. No vehicle connection or '
                        'live scan is used.',
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

class _VehicleSummary extends StatelessWidget {
  const _VehicleSummary({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final displayName =
        '${vehicle.manufacturer} ${vehicle.model} ${vehicle.variant}';
    return Semantics(
      container: true,
      label:
          'Confirmed vehicle. $displayName. Profile version '
          '${vehicle.profile.version.value}.',
      child: ExcludeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirmed vehicle',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.extraSmall),
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.extraSmall),
                Text(
                  'Profile ${vehicle.profile.version.value}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StartRequested extends StatelessWidget {
  const _StartRequested({required this.instructions, required this.onBack});

  final VehiclePreparationInstructions instructions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PreparationGuidance(instructions: instructions),
        const SizedBox(height: AppSpacing.large),
        Semantics(
          container: true,
          liveRegion: true,
          label:
              'Start Scan requested explicitly. The application placeholder '
              'was invoked. No scan progress or live vehicle operation is '
              'implemented on this screen.',
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.positive.withValues(alpha: 0.10),
              borderRadius: AppSpacing.cardRadius,
              border: Border.all(color: colors.positive),
            ),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.cardPadding),
              child: Text(
                'Start Scan was requested. This preparation screen has handed '
                'off to the application placeholder; it does not implement '
                'scan progress or live vehicle access.',
              ),
            ),
          ),
        ),
        if (onBack != null) ...[
          const SizedBox(height: AppSpacing.small),
          OutlinedButton(
            onPressed: onBack,
            child: const Text('Back to vehicle confirmation'),
          ),
        ],
      ],
    );
  }
}
