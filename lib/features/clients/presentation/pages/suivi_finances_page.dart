import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/depense.dart';
import '../../../../data/models/paiement.dart';
import '../providers/finances_providers.dart';

final NumberFormat _formatMontant = NumberFormat.decimalPattern('fr_FR');

/// Suivi des finances de l'atelier, sous forme de tableau : pour chaque
/// période (jour, semaine, mois, année) puis pour chaque mois de l'année
/// choisie, les Recettes (paiements reçus), les Dépenses et le Solde
/// (Recettes − Dépenses).
///
/// Calculé à partir de l'historique complet des paiements et des dépenses
/// (jamais supprimé) filtré sur la période concernée — le tableau annuel
/// "se réinitialise" donc tout seul au 1er janvier, sans aucune action ni
/// perte de données : c'est simplement une nouvelle période qui commence,
/// et l'année précédente reste consultable via les flèches ci-dessous.
///
/// Réservée au propriétaire (comme le reste des finances, voir
/// CarteFinancesClient et PermissionsApprenti) — voir HomePage, qui ne
/// propose ce bouton que si `estProprietaire`. L'enregistrement d'une
/// dépense se fait depuis un raccourci séparé sur l'accueil ("Enregistrer
/// dépenses", voir EnregistrerDepensePage), pas depuis cet écran.
class SuiviFinancesPage extends ConsumerStatefulWidget {
  const SuiviFinancesPage({super.key});

  @override
  ConsumerState<SuiviFinancesPage> createState() => _SuiviFinancesPageState();
}

class _SuiviFinancesPageState extends ConsumerState<SuiviFinancesPage> {
  late int _anneeAffichee = DateTime.now().year;

  double _total<T>(
    List<T> lignes,
    DateTime Function(T) date,
    double Function(T) montant,
    DateTime depuis, [
    DateTime? avant,
  ]) {
    return lignes
        .where(
          (l) =>
              !date(l).isBefore(depuis) &&
              (avant == null || date(l).isBefore(avant)),
        )
        .fold(0.0, (total, l) => total + montant(l));
  }

  @override
  Widget build(BuildContext context) {
    final List<Paiement> paiements =
        ref.watch(paiementsAtelierProvider).asData?.value ?? const [];
    final List<Depense> depenses =
        ref.watch(depensesAtelierProvider).asData?.value ?? const [];

    double recette(DateTime depuis, [DateTime? avant]) => _total(
      paiements,
      (p) => p.datePaiement,
      (p) => p.montant,
      depuis,
      avant,
    );
    double depense(DateTime depuis, [DateTime? avant]) => _total(
      depenses,
      (d) => d.dateDepense,
      (d) => d.montant,
      depuis,
      avant,
    );

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
          _TableauFinances(
            lignes: [
              _LigneFinances('Jour', recette(debutJour), depense(debutJour)),
              _LigneFinances(
                'Semaine',
                recette(debutSemaine),
                depense(debutSemaine),
              ),
              _LigneFinances('Mois', recette(debutMois), depense(debutMois)),
              _LigneFinances(
                'Année',
                recette(debutAnnee),
                depense(debutAnnee),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            "Le compteur de l'année repart automatiquement à zéro au 1er "
            "janvier — aucun paiement ni aucune dépense n'est supprimé, "
            "c'est seulement la période affichée qui change. Le "
            "récapitulatif ci-dessous permet de revoir n'importe quelle "
            'année, mois par mois.',
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
          _TableauFinances(
            libelleColonne: 'Mois',
            lignes: [
              for (int mois = 1; mois <= 12; mois++)
                _LigneFinances(
                  _nomMoisCapitalise(_anneeAffichee, mois),
                  recette(
                    DateTime(_anneeAffichee, mois, 1),
                    DateTime(_anneeAffichee, mois + 1, 1),
                  ),
                  depense(
                    DateTime(_anneeAffichee, mois, 1),
                    DateTime(_anneeAffichee, mois + 1, 1),
                  ),
                  enEvidence:
                      _anneeAffichee == maintenant.year &&
                      mois == maintenant.month,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _nomMoisCapitalise(int annee, int mois) {
    final String nom = DateFormat('MMMM', 'fr_FR').format(DateTime(annee, mois));
    return nom[0].toUpperCase() + nom.substring(1);
  }
}

class _LigneFinances {
  _LigneFinances(
    this.libelle,
    this.recettes,
    this.depenses, {
    this.enEvidence = false,
  });

  final String libelle;
  final double recettes;
  final double depenses;
  final bool enEvidence;

  double get solde => recettes - depenses;
}

/// Tableau Recettes / Dépenses / Solde, une ligne par période — utilisé
/// aussi bien pour le résumé jour/semaine/mois/année que pour le
/// récapitulatif mensuel d'une année, qui suivent tous les deux le même
/// modèle.
class _TableauFinances extends StatelessWidget {
  const _TableauFinances({
    required this.lignes,
    this.libelleColonne = 'Période',
  });

  final List<_LigneFinances> lignes;
  final String libelleColonne;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: AppSpacing.l,
          horizontalMargin: AppSpacing.m,
          columns: [
            DataColumn(label: Text(libelleColonne)),
            const DataColumn(label: Text('Recettes'), numeric: true),
            const DataColumn(label: Text('Dépenses'), numeric: true),
            const DataColumn(label: Text('Solde'), numeric: true),
          ],
          rows: [
            for (final _LigneFinances ligne in lignes)
              DataRow(
                color: ligne.enEvidence
                    ? WidgetStateProperty.all(
                        AppColors.terracotta500.withValues(alpha: 0.1),
                      )
                    : null,
                cells: [
                  DataCell(
                    Text(
                      ligne.libelle,
                      style: TextStyle(
                        fontWeight: ligne.enEvidence
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  DataCell(Text(_formatMontant.format(ligne.recettes))),
                  DataCell(Text(_formatMontant.format(ligne.depenses))),
                  DataCell(
                    Text(
                      _formatMontant.format(ligne.solde),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ligne.solde >= 0
                            ? AppColors.succes
                            : AppColors.erreur,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
