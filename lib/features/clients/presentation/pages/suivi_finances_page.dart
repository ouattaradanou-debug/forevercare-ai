import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/paiement.dart';
import '../providers/finances_providers.dart';

final NumberFormat _formatMontant = NumberFormat.decimalPattern('fr_FR');

/// Suivi des recettes de l'atelier : journalières, hebdomadaires,
/// mensuelles et annuelles, plus un récapitulatif mois par mois d'une
/// année choisie. Calculées à partir de l'historique des paiements
/// (jamais supprimé) filtré sur la période concernée — le compteur annuel
/// "se réinitialise" donc tout seul au 1er janvier, sans aucune action ni
/// perte de données : c'est simplement une nouvelle période qui commence,
/// et l'année précédente reste consultable dans le récapitulatif.
///
/// Réservée au propriétaire (comme le reste des finances, voir
/// CarteFinancesClient et PermissionsApprenti) — voir HomePage, qui ne
/// propose ce bouton que si `estProprietaire`.
class SuiviFinancesPage extends ConsumerStatefulWidget {
  const SuiviFinancesPage({super.key});

  @override
  ConsumerState<SuiviFinancesPage> createState() => _SuiviFinancesPageState();
}

class _SuiviFinancesPageState extends ConsumerState<SuiviFinancesPage> {
  late int _anneeAffichee = DateTime.now().year;

  double _recette(
    List<Paiement> paiements,
    DateTime depuis, [
    DateTime? avant,
  ]) {
    return paiements
        .where(
          (p) =>
              !p.datePaiement.isBefore(depuis) &&
              (avant == null || p.datePaiement.isBefore(avant)),
        )
        .fold(0.0, (total, p) => total + p.montant);
  }

  @override
  Widget build(BuildContext context) {
    final List<Paiement> paiements =
        ref.watch(paiementsAtelierProvider).asData?.value ?? const [];

    final DateTime maintenant = DateTime.now();
    final DateTime debutJour = DateTime(
      maintenant.year,
      maintenant.month,
      maintenant.day,
    );
    final DateTime debutSemaine = debutJour.subtract(
      Duration(days: maintenant.weekday - 1),
    );
    final DateTime debutMois = DateTime(maintenant.year, maintenant.month, 1);
    final DateTime debutAnnee = DateTime(maintenant.year, 1, 1);

    return Scaffold(
      appBar: AppBar(title: const Text('Suivi des finances')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          _CarteRecette(
            titre: "Aujourd'hui",
            montant: _recette(paiements, debutJour),
            icone: Icons.today_outlined,
            couleur: AppColors.indigo700,
          ),
          const SizedBox(height: AppSpacing.m),
          _CarteRecette(
            titre: 'Cette semaine',
            montant: _recette(paiements, debutSemaine),
            icone: Icons.view_week_outlined,
            couleur: AppColors.terracotta600,
          ),
          const SizedBox(height: AppSpacing.m),
          _CarteRecette(
            titre: 'Ce mois-ci',
            montant: _recette(paiements, debutMois),
            icone: Icons.calendar_month_outlined,
            couleur: AppColors.or600,
          ),
          const SizedBox(height: AppSpacing.m),
          _CarteRecette(
            titre: 'Cette année',
            montant: _recette(paiements, debutAnnee),
            icone: Icons.event_note_outlined,
            couleur: AppColors.succes,
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            "Le compteur de l'année repart automatiquement à zéro au 1er "
            "janvier — aucun paiement n'est supprimé, c'est seulement la "
            'période affichée qui change. Le récapitulatif ci-dessous '
            "permet de revoir n'importe quelle année, mois par mois.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => setState(() => _anneeAffichee--),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                'Récapitulatif $_anneeAffichee',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                onPressed: _anneeAffichee >= maintenant.year
                    ? null
                    : () => setState(() => _anneeAffichee++),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.s,
              ),
              child: Column(
                children: [
                  for (int mois = 1; mois <= 12; mois++)
                    _LigneMois(
                      annee: _anneeAffichee,
                      mois: mois,
                      montant: _recette(
                        paiements,
                        DateTime(_anneeAffichee, mois, 1),
                        DateTime(_anneeAffichee, mois + 1, 1),
                      ),
                      estMoisCourant:
                          _anneeAffichee == maintenant.year &&
                          mois == maintenant.month,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LigneMois extends StatelessWidget {
  const _LigneMois({
    required this.annee,
    required this.mois,
    required this.montant,
    required this.estMoisCourant,
  });

  final int annee;
  final int mois;
  final double montant;
  final bool estMoisCourant;

  @override
  Widget build(BuildContext context) {
    final String nomMois = DateFormat(
      'MMMM',
      'fr_FR',
    ).format(DateTime(annee, mois));
    final String nomMoisCapitalise =
        nomMois[0].toUpperCase() + nomMois.substring(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nomMoisCapitalise,
            style: TextStyle(
              fontWeight: estMoisCourant ? FontWeight.w700 : FontWeight.w400,
              color: estMoisCourant ? AppColors.terracotta600 : null,
            ),
          ),
          Text(
            '${_formatMontant.format(montant)} FCFA',
            style: TextStyle(
              fontWeight: estMoisCourant ? FontWeight.w700 : FontWeight.w400,
              color: estMoisCourant ? AppColors.terracotta600 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteRecette extends StatelessWidget {
  const _CarteRecette({
    required this.titre,
    required this.montant,
    required this.icone,
    required this.couleur,
  });

  final String titre;
  final double montant;
  final IconData icone;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icone, color: couleur, size: 32),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(titre, style: Theme.of(context).textTheme.titleMedium),
          ),
          Text(
            '${_formatMontant.format(montant)} FCFA',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
