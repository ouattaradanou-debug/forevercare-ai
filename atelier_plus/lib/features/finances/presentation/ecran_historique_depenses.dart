import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/depense.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/recapitulatif_finances.dart';
import '../providers/finances_providers.dart';

/// Bleu/orange du logo SEDA Tech, repris pour les écrans de dépenses.
const Color _bleuSeda = Color(0xFF1B4FA0);
const Color _orangeSeda = Color(0xFFF5821F);

enum _Periode { jour, semaine, mois, annee }

/// Tableau de toutes les dépenses enregistrées (Date, Motif, Montant), la
/// plus récente en premier, filtrable par Jour/Semaine/Mois/Année en cours.
///
/// Pour un apprenti, filtré au jour uniquement, sans sélecteur de période —
/// même principe que EcranHistoriqueVentes.
class EcranHistoriqueDepenses extends ConsumerStatefulWidget {
  const EcranHistoriqueDepenses({super.key});

  @override
  ConsumerState<EcranHistoriqueDepenses> createState() => _EcranHistoriqueDepensesState();
}

class _EcranHistoriqueDepensesState extends ConsumerState<EcranHistoriqueDepenses> {
  _Periode _periode = _Periode.mois;

  @override
  void initState() {
    super.initState();
    // Le cache local ne contient que les dépenses déjà rencontrées sur cet
    // appareil : on rapatrie celles du serveur (autres appareils, ou
    // ajoutées avant l'existence de cet écran) dès l'ouverture.
    Future.microtask(() async {
      final atelier = await ref.read(atelierCourantProvider.future);
      if (atelier != null) {
        await ref.read(financesRepositoryProvider).chargerRecapitulatifDepuisServeur(atelier.id);
      }
    });
  }

  (DateTime, DateTime) _bornesPeriode(_Periode periode) {
    final now = DateTime.now();
    switch (periode) {
      case _Periode.jour:
        return (debutDuJour(now), debutDuJour(now).add(const Duration(days: 1)));
      case _Periode.semaine:
        return (debutDeLaSemaine(now), debutDeLaSemaine(now).add(const Duration(days: 7)));
      case _Periode.mois:
        return (debutDuMois(now), DateTime(now.year, now.month + 1));
      case _Periode.annee:
        return (debutDeLAnnee(now), DateTime(now.year + 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final estProprietaire = ref.watch(estProprietaireProvider);
    final depenses = ref.watch(depensesDeLAtelierProvider);
    // Un apprenti ne voit que l'historique du jour, jamais semaine/mois/
    // année — le sélecteur de période lui-même est caché dans ce cas (un
    // seul choix possible ne justifie pas un sélecteur).
    final periodeEffective = estProprietaire ? _periode : _Periode.jour;
    final (debut, finExclusive) = _bornesPeriode(periodeEffective);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des dépenses'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (estProprietaire)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: SegmentedButton<_Periode>(
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: _orangeSeda,
                    selectedForegroundColor: Colors.white,
                    foregroundColor: _bleuSeda,
                  ),
                  segments: const [
                    ButtonSegment(value: _Periode.jour, label: Text('Jour')),
                    ButtonSegment(value: _Periode.semaine, label: Text('Semaine')),
                    ButtonSegment(value: _Periode.mois, label: Text('Mois')),
                    ButtonSegment(value: _Periode.annee, label: Text('Année')),
                  ],
                  selected: {_periode},
                  onSelectionChanged: (selection) => setState(() => _periode = selection.first),
                ),
              ),
            Expanded(
              child: depenses.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
                data: (liste) {
                  final filtrees = liste
                      .where((d) => !d.date.isBefore(debut) && d.date.isBefore(finExclusive))
                      .toList();

                  if (filtrees.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Aucune dépense sur cette période.'),
                      ),
                    );
                  }

                  final total = filtrees.fold<double>(0, (somme, d) => somme + d.montant);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 6)],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Table(
                            columnWidths: const {
                              0: FixedColumnWidth(90),
                              2: FlexColumnWidth(0.9),
                            },
                            children: [
                              TableRow(
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: _orangeSeda, width: 2)),
                                ),
                                children: const [
                                  _Cellule('Date', entete: true),
                                  _Cellule('Motif', entete: true, centre: true),
                                  _Cellule('Montant', entete: true, alignDroite: true),
                                ],
                              ),
                              for (final depense in filtrees) _ligne(depense),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: _bleuSeda,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: TextStyle(color: Colors.white)),
                              Text(
                                Formatters.montant(total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _orangeSeda,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _ligne(Depense depense) {
    return TableRow(children: [
      _Cellule(Formatters.dateCourte(depense.date)),
      _Cellule(
        depense.description == null || depense.description!.isEmpty
            ? '—'
            : depense.description!,
        centre: true,
        tronquer: false,
      ),
      _Cellule(Formatters.nombre(depense.montant), alignDroite: true),
    ]);
  }
}

class _Cellule extends StatelessWidget {
  const _Cellule(
    this.texte, {
    this.entete = false,
    this.alignDroite = false,
    this.centre = false,
    this.tronquer = true,
  });

  final String texte;
  final bool entete;
  final bool alignDroite;
  final bool centre;
  final bool tronquer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Text(
        texte,
        textAlign: centre
            ? TextAlign.center
            : (alignDroite ? TextAlign.right : TextAlign.left),
        maxLines: tronquer ? 1 : null,
        overflow: tronquer ? TextOverflow.ellipsis : TextOverflow.visible,
        style: TextStyle(
          fontWeight: entete ? FontWeight.bold : FontWeight.normal,
          color: entete ? _bleuSeda : const Color(0xFF231A14),
          fontSize: 13,
        ),
      ),
    );
  }
}
