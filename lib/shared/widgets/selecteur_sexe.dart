import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

/// Grand sélecteur visuel homme/femme (deux boutons pleine largeur, icône +
/// texte) — pensé pour être compris d'un coup d'œil par un utilisateur ne
/// sachant ni lire ni écrire. Utilisé pour le sexe d'un client comme d'un
/// membre de groupe d'uniformes.
class SelecteurSexe extends StatelessWidget {
  const SelecteurSexe({
    super.key,
    required this.sexe,
    required this.onChange,
  });

  final String? sexe;
  final ValueChanged<String?> onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Bouton(
            icone: Icons.man,
            libelle: 'Homme',
            selectionne: sexe == 'Homme',
            onTap: () => onChange(sexe == 'Homme' ? null : 'Homme'),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: _Bouton(
            icone: Icons.woman,
            libelle: 'Femme',
            selectionne: sexe == 'Femme',
            onTap: () => onChange(sexe == 'Femme' ? null : 'Femme'),
          ),
        ),
      ],
    );
  }
}

class _Bouton extends StatelessWidget {
  const _Bouton({
    required this.icone,
    required this.libelle,
    required this.selectionne,
    required this.onTap,
  });

  final IconData icone;
  final String libelle;
  final bool selectionne;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.champ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        decoration: BoxDecoration(
          color: selectionne
              ? AppColors.indigo700.withValues(alpha: 0.12)
              : scheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.champ),
          border: Border.all(
            color: selectionne ? AppColors.indigo700 : scheme.outline,
            width: selectionne ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icone,
              size: 48,
              color: selectionne ? AppColors.indigo700 : scheme.onSurface,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              libelle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selectionne ? AppColors.indigo700 : scheme.onSurface,
                fontWeight: selectionne ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
