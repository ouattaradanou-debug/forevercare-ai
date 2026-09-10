import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/depense.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/finances_providers.dart';

final NumberFormat _formatMontant = NumberFormat.decimalPattern('fr_FR');

/// Suivi des dépenses de l'atelier : journalières, hebdomadaires,
/// mensuelles et annuelles, plus un récapitulatif mois par mois d'une
/// année choisie — construit exactement comme SuiviFinancesPage (voir ce
/// fichier pour le détail du raisonnement sur le "compteur annuel qui se
/// réinitialise" : rien n'est jamais supprimé, seule la période affichée
/// change, et l'année précédente reste consultable dans le récapitulatif).
///
/// Réservée au propriétaire (comme le reste des finances) — voir HomePage.
class SuiviDepensesPage extends ConsumerStatefulWidget {
  const SuiviDepensesPage({super.key});

  @override
  ConsumerState<SuiviDepensesPage> createState() => _SuiviDepensesPageState();
}

class _SuiviDepensesPageState extends ConsumerState<SuiviDepensesPage> {
  late int _anneeAffichee = DateTime.now().year;

  double _depense(
    List<Depense> depenses,
    DateTime depuis, [
    DateTime? avant,
  ]) {
    return depenses
        .where(
          (d) =>
              !d.dateDepense.isBefore(depuis) &&
              (avant == null || d.dateDepense.isBefore(avant)),
        )
        .fold(0.0, (total, d) => total + d.montant);
  }

  Future<void> _ouvrirDialogueAjout(String atelierId) async {
    final TextEditingController montantCtrl = TextEditingController();
    final TextEditingController descriptionCtrl = TextEditingController();

    final bool? confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une dépense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: montantCtrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Montant (FCFA)',
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (confirme != true) return;
    final double? montant = double.tryParse(
      montantCtrl.text.trim().replaceAll(',', '.'),
    );
    if (montant == null || montant <= 0) return;

    await ref.read(financesRepositoryProvider).ajouterDepense(
          atelierId: atelierId,
          montant: montant,
          description: descriptionCtrl.text.trim().isEmpty
              ? null
              : descriptionCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final String? atelierId =
        ref.watch(atelierCourantProvider).asData?.value?.id;
    final List<Depense> depenses =
        ref.watch(depensesAtelierProvider).asData?.value ?? const [];

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
      appBar: AppBar(title: const Text('Suivi des dépenses')),
      floatingActionButton: atelierId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _ouvrirDialogueAjout(atelierId),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une dépense'),
            ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.xxl,
        ),
        children: [
          _CarteDepense(
            titre: "Aujourd'hui",
            montant: _depense(depenses, debutJour),
            icone: Icons.today_outlined,
            couleur: AppColors.indigo700,
          ),
          const SizedBox(height: AppSpacing.m),
          _CarteDepense(
            titre: 'Cette semaine',
            montant: _depense(depenses, debutSemaine),
            icone: Icons.view_week_outlined,
            couleur: AppColors.terracotta600,
          ),
          const SizedBox(height: AppSpacing.m),
          _CarteDepense(
            titre: 'Ce mois-ci',
            montant: _depense(depenses, debutMois),
            icone: Icons.calendar_month_outlined,
            couleur: AppColors.or600,
          ),
          const SizedBox(height: AppSpacing.m),
          _CarteDepense(
            titre: 'Cette année',
            montant: _depense(depenses, debutAnnee),
            icone: Icons.event_note_outlined,
            couleur: AppColors.erreur,
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            "Le compteur de l'année repart automatiquement à zéro au 1er "
            "janvier — aucune dépense n'est supprimée, c'est seulement la "
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
                      montant: _depense(
                        depenses,
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
          if (depenses.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Historique', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.m),
            for (final Depense d in depenses)
              Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.s),
                child: ListTile(
                  leading: const Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.erreur,
                  ),
                  title: Text('${_formatMontant.format(d.montant)} FCFA'),
                  subtitle: Text(
                    [
                      DateFormat('d MMM yyyy', 'fr_FR').format(d.dateDepense),
                      if ((d.description ?? '').isNotEmpty) d.description!,
                    ].join(' — '),
                  ),
                ),
              ),
          ],
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

class _CarteDepense extends StatelessWidget {
  const _CarteDepense({
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
