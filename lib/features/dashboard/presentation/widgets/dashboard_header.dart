import 'package:flutter/material.dart';

import 'package:forevercare_ai/design_system/design_system.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: AppSpacing.defaultCardPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: AppRadius.card,
        boxShadow: AppElevation.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour Danouma 👋',
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Bienvenue sur ForeverCare AI',
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.90),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Votre assistant intelligent pour le suivi de vos clients, protocoles et cures Forever.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.80),
            ),
          ),
        ],
      ),
    );
  }
}
