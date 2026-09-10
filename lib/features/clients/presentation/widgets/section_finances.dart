import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import 'section_titre.dart';

final NumberFormat _formatMontant = NumberFormat.decimalPattern('fr_FR');

/// Section "Finances" du formulaire client : montant total convenu pour la
/// prestation, et (à la création uniquement, voir `avanceInitialeCtrl`)
/// l'avance déjà versée par le client — le reste à payer s'affiche alors
/// automatiquement. Réservée au propriétaire — voir FormulaireClientPage /
/// ModifierClientPage, qui ne l'affichent que si `estProprietaire` (un
/// apprenti n'a jamais accès aux finances, même visuellement, voir
/// PermissionsApprenti et supabase/schema.sql).
///
/// Au-delà de cette avance initiale, l'enregistrement des paiements reçus
/// se fait séparément, depuis la fiche client (voir CarteFinancesClient) :
/// un geste ponctuel fait au moment où l'argent change de main, pas un
/// champ de formulaire.
class SectionFinances extends StatelessWidget {
  const SectionFinances({
    super.key,
    required this.montantConvenuCtrl,
    this.avanceInitialeCtrl,
  });

  final TextEditingController montantConvenuCtrl;
  final TextEditingController? avanceInitialeCtrl;

  double _valeur(TextEditingController controleur) =>
      double.tryParse(controleur.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final TextEditingController? avanceCtrl = avanceInitialeCtrl;

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
          decoration: InputDecoration(
            labelText: 'Montant total convenu (FCFA)',
            helperText: avanceCtrl == null
                ? 'Les paiements reçus se saisissent ensuite depuis la '
                      'fiche du client.'
                : null,
          ),
        ),
        if (avanceCtrl != null) ...[
          const SizedBox(height: AppSpacing.m),
          TextFormField(
            controller: avanceCtrl,
            keyboardType: const TextInputType.numberWithOptions(),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Avance déjà payée par le client (FCFA)',
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          ListenableBuilder(
            listenable: Listenable.merge([montantConvenuCtrl, avanceCtrl]),
            builder: (context, _) {
              final double reste =
                  (_valeur(montantConvenuCtrl) - _valeur(avanceCtrl)).clamp(
                    0,
                    double.infinity,
                  );
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.succes.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Reste à payer'),
                    Text(
                      '${_formatMontant.format(reste)} FCFA',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
