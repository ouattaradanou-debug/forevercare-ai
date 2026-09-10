import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import 'section_titre.dart';

/// Section "Finances" du formulaire client : uniquement le montant total
/// convenu pour la prestation (optionnel). Réservée au propriétaire — voir
/// FormulaireClientPage / ModifierClientPage, qui ne l'affichent que si
/// `estProprietaire` (un apprenti n'a jamais accès aux finances, même
/// visuellement, voir PermissionsApprenti et supabase/schema.sql).
///
/// L'enregistrement des paiements reçus se fait séparément, depuis la fiche
/// client (voir CarteFinancesClient) : ce n'est pas un champ de formulaire,
/// mais un geste ponctuel fait au moment où l'argent change de main.
class SectionFinances extends StatelessWidget {
  const SectionFinances({super.key, required this.montantConvenuCtrl});

  final TextEditingController montantConvenuCtrl;

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
        TextFormField(
          controller: montantConvenuCtrl,
          keyboardType: const TextInputType.numberWithOptions(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Montant total convenu (FCFA)',
            helperText:
                'Les paiements reçus se saisissent ensuite depuis la fiche '
                'du client.',
          ),
        ),
      ],
    );
  }
}
