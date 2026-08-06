import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// A reusable empty state with one clear primary action.
class EmptyState extends StatelessWidget {
  /// Creates an empty state from caller-supplied copy and actions.
  const EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    super.key,
  }) : assert(
         (secondaryActionLabel == null) == (onSecondaryAction == null),
         'Secondary action label and callback must be supplied together.',
       );

  /// Governed Material icon that reinforces the state.
  final IconData icon;

  /// Concise empty-state title.
  final String title;

  /// Plain-language explanation of why the content is empty.
  final String body;

  /// Label for the single primary action.
  final String primaryActionLabel;

  /// Primary recovery or creation intent.
  final VoidCallback onPrimaryAction;

  /// Optional secondary educational action label.
  final String? secondaryActionLabel;

  /// Optional secondary educational intent.
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;

    return Semantics(
      container: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: Icon(
                icon,
                size: AppSpacing.extraExtraLarge,
                color: colors.info,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.large),
            FilledButton(
              onPressed: onPrimaryAction,
              child: Text(primaryActionLabel),
            ),
            if (onSecondaryAction != null) ...[
              const SizedBox(height: AppSpacing.small),
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(secondaryActionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
