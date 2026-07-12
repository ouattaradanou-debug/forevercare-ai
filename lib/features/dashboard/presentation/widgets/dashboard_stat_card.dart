import 'package:flutter/material.dart';

import 'package:forevercare_ai/design_system/design_system.dart';
import 'package:forevercare_ai/shared/presentation/widgets/cards/fc_card.dart';

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FCCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),

          const SizedBox(height: AppSpacing.md),

          Text(value, style: AppTypography.textTheme.headlineMedium),

          const SizedBox(height: AppSpacing.xs),

          Text(
            title,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
