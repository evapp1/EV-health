import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// Shared layout for the four focused onboarding screens.
class OnboardingPage extends StatelessWidget {
  /// Creates an onboarding page that displays content and dispatches intents.
  const OnboardingPage({
    required this.step,
    required this.title,
    required this.body,
    required this.icon,
    required this.items,
    required this.primaryLabel,
    required this.onPrimary,
    this.onBack,
    super.key,
  });

  /// One-based step number shown to the user.
  final int step;

  /// Screen heading.
  final String title;

  /// Introductory screen copy.
  final String body;

  /// Governed Material icon for the screen.
  final IconData icon;

  /// Supporting facts shown beneath the introduction.
  final List<OnboardingItem> items;

  /// Primary action label.
  final String primaryLabel;

  /// Primary user intent callback.
  final VoidCallback onPrimary;

  /// Optional back user intent callback.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: onBack == null
            ? null
            : IconButton(
                tooltip: 'Back',
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
              ),
        title: const Text('EV Health'),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenCompact,
                AppSpacing.medium,
                AppSpacing.screenCompact,
                AppSpacing.large,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppSpacing.large,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      label: 'Onboarding step $step of 4',
                      child: LinearProgressIndicator(value: step / 4),
                    ),
                    const SizedBox(height: AppSpacing.extraLarge),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: AppSpacing.cardRadius,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.medium),
                          child: Icon(
                            icon,
                            size: AppSpacing.extraLarge,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(body, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: AppSpacing.large),
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.medium,
                        ),
                        child: _OnboardingItemRow(item: item),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    FilledButton(
                      onPressed: onPrimary,
                      child: Text(primaryLabel),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// One supporting onboarding fact.
class OnboardingItem {
  /// Creates a supporting fact with an icon, title, and explanation.
  const OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  /// Material icon reinforcing the fact.
  final IconData icon;

  /// Short fact title.
  final String title;

  /// Plain-language explanation.
  final String description;
}

class _OnboardingItemRow extends StatelessWidget {
  const _OnboardingItemRow({required this.item});

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(item.icon, color: colors.info),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.extraSmall),
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
