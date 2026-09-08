import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

/// Titre de section avec icône, utilisé pour repérer facilement chaque
/// bloc du formulaire client continu en scrollant.
class SectionTitre extends StatelessWidget {
  const SectionTitre({
    super.key,
    required this.icone,
    required this.titre,
    this.couleur = AppColors.indigo700,
  });

  final IconData icone;
  final String titre;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: couleur.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icone, color: couleur, size: 20),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(titre, style: Theme.of(context).textTheme.headlineMedium),
        ),
      ],
    );
  }
}
