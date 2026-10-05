import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/depense.dart';
import '../data/recapitulatif_finances.dart';
import '../providers/finances_providers.dart';

enum _Periode { jour, semaine, mois, annee }

/// Tableau de toutes les dépenses enregistrées (Date, Motif, Montant), la
/// plus récente en premier, filtrable par Jour/Semaine/Mois/Année en cours.
class EcranHistoriqueDepenses extends ConsumerStatefulWidget {
  const EcranHistoriqueDepenses({super.key});

  @override
  ConsumerState<EcranHistoriqueDepenses> createState() => _EcranHistoriqueDepensesState();
}

class _EcranHistoriqueDepensesState extends ConsumerState<EcranHistoriqueDepenses> {
  _Periode _periode = _Periode.mois;

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
    final depenses = ref.watch(depensesDeLAtelierProvider);
    final (debut, finExclusive) = _bornesPeriode(_periode);

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des dépenses')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SegmentedButton<_Periode>(
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
                              const TableRow(children: [
                                _Cellule('Date', entete: true),
                                _Cellule('Motif', entete: true, centre: true),
                                _Cellule('Montant', entete: true, alignDroite: true),
                              ]),
                              for (final depense in filtrees) _ligne(depense),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEAE4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total'),
                              Text(
                                Formatters.montant(total),
                                style: const TextStyle(fontWeight: FontWeight.bold),
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
  });

  final String texte;
  final bool entete;
  final bool alignDroite;
  final bool centre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Text(
        texte,
        textAlign: centre
            ? TextAlign.center
            : (alignDroite ? TextAlign.right : TextAlign.left),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: entete ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xFF231A14),
          fontSize: 13,
        ),
      ),
    );
  }
}
