import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../shared/widgets/press_scale.dart';

/// Grande tuile d'action de l'écran d'accueil (ex : "Nouveau client").
///
/// Zone de tap large, icône explicite et libellé court : pensée pour être
/// comprise et actionnée en un coup d'œil par un utilisateur peu technophile.
class HomeActionCard extends StatelessWidget {
  const HomeActionCard({
    super.key,
    required this.icone,
    required this.libelle,
    required this.couleurAccent,
    required this.onTap,
  });

  final IconData icone;
  final String libelle;
  final Color couleurAccent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return PressScale(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppTapTarget.min + 40),
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: couleurAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: couleurAccent, size: 24),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              libelle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
