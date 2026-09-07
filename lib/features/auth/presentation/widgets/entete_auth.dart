import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

/// En-tête commun aux écrans de connexion et de création de compte.
class EnteteAuth extends StatelessWidget {
  const EnteteAuth({super.key, required this.titre, required this.sousTitre});

  final String titre;
  final String sousTitre;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.xxl,
        AppSpacing.l,
        AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.indigo900, AppColors.indigo700],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atelier+',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppColors.or500,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            titre,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppColors.ecru50,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            sousTitre,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.ecru50.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
