import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import 'section_titre.dart';

/// Section "Finances" : emplacement réservé dans la fiche client, en
/// attendant la construction du suivi des paiements (Phase 3). Aucune
/// donnée n'est encore enregistrée ici.
class SectionFinances extends StatelessWidget {
  const SectionFinances({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitre(
          icone: Icons.savings_outlined,
          titre: 'Finances',
          couleur: AppColors.succes,
        ),
        const SizedBox(height: AppSpacing.m),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.l),
          decoration: BoxDecoration(
            color: AppColors.succes.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Text(
            'Le suivi des paiements de ce client arrive bientôt.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
