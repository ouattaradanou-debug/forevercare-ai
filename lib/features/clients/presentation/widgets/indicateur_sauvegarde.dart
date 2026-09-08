import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

/// Indicateur discret "Enregistré automatiquement", affiché brièvement
/// après chaque sauvegarde du brouillon.
class IndicateurSauvegarde extends StatelessWidget {
  const IndicateurSauvegarde({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: AppColors.succes),
          SizedBox(width: AppSpacing.xs),
          Text(
            'Enregistré automatiquement',
            style: TextStyle(color: AppColors.succes, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
