import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../data/recapitulatif_finances.dart';
import '../providers/finances_providers.dart';

const List<String> _nomsMois = [
  'Janvier',
  'Février',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Août',
  'Septembre',
  'Octobre',
  'Novembre',
  'Décembre',
];

/// Récapitulatif financier global de l'atelier (tous clients confondus) :
/// recettes/dépenses du jour, de la semaine, du mois et de l'année en cours,
/// puis un détail mois par mois pour l'année choisie.
class EcranSuiviFinances extends ConsumerStatefulWidget {
  const EcranSuiviFinances({super.key});

  @override
  ConsumerState<EcranSuiviFinances> createState() => _EcranSuiviFinancesState();
}

class _EcranSuiviFinancesState extends ConsumerState<EcranSuiviFinances> {
  late int _annee = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final recapGlobal = ref.watch(recapitulatifGlobalProvider);
    final recapMensuel = ref.watch(recapitulatifMensuelProvider(_annee));
    final maintenant = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Suivi des finances')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            recapGlobal.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const Text('Impossible de charger le récapitulatif.'),
              data: (recap) => _TableauPeriodes(recap: recap),
            ),
            const SizedBox(height: 16),
            const Text(
              'Le compteur de l\'année repart automatiquement à zéro au 1er '
              'janvier — aucun paiement ni aucune dépense n\'est supprimé, '
              'c\'est seulement la période affichée qui change. Le récapitulatif '
              'ci-dessous permet de revoir n\'importe quelle année, mois par mois.',
              style: TextStyle(color: Color(0xFF6F6259)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _annee -= 1),
                ),
                Text(
                  'Récapitulatif $_annee',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontFamily: 'serif', fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => _annee += 1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            recapMensuel.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const Text('Impossible de charger le récapitulatif.'),
              data: (mois) => _TableauMensuel(
                annee: _annee,
                moisParPeriode: mois,
                moisCourantSurligne:
                    _annee == maintenant.year ? maintenant.month : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableauPeriodes extends StatelessWidget {
  const _TableauPeriodes({required this.recap});

  final RecapitulatifGlobal recap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 6)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(1.2)},
        children: [
          const TableRow(children: [
            _Cellule('Période', entete: true),
            _Cellule('Recettes', entete: true, alignDroite: true),
            _Cellule('Dépenses', entete: true, alignDroite: true),
            _Cellule('Solde', entete: true, alignDroite: true),
          ]),
          _ligne('Jour', recap.jour),
          _ligne('Semaine', recap.semaine),
          _ligne('Mois', recap.mois),
          _ligne('Année', recap.annee),
        ],
      ),
    );
  }

  TableRow _ligne(String libelle, RecapitulatifPeriode periode) {
    return TableRow(children: [
      _Cellule(libelle),
      _Cellule(Formatters.nombre(periode.recettes), alignDroite: true),
      _Cellule(Formatters.nombre(periode.depenses), alignDroite: true),
      _Cellule(
        Formatters.nombre(periode.solde),
        alignDroite: true,
        couleur: periode.solde < 0 ? const Color(0xFFB3261E) : const Color(0xFF2E7D32),
      ),
    ]);
  }
}

class _TableauMensuel extends StatelessWidget {
  const _TableauMensuel({
    required this.annee,
    required this.moisParPeriode,
    required this.moisCourantSurligne,
  });

  final int annee;
  final List<RecapitulatifPeriode> moisParPeriode;
  final int? moisCourantSurligne;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 6)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Table(
        children: [
          const TableRow(children: [
            _Cellule('Mois', entete: true),
            _Cellule('Recettes', entete: true, alignDroite: true),
            _Cellule('Dépenses', entete: true, alignDroite: true),
          ]),
          for (var i = 0; i < 12; i++)
            TableRow(
              decoration: moisCourantSurligne == i + 1
                  ? const BoxDecoration(color: Color(0xFFF5E3E3))
                  : null,
              children: [
                _Cellule(_nomsMois[i], gras: moisCourantSurligne == i + 1),
                _Cellule(Formatters.nombre(moisParPeriode[i].recettes), alignDroite: true),
                _Cellule(Formatters.nombre(moisParPeriode[i].depenses), alignDroite: true),
              ],
            ),
        ],
      ),
    );
  }
}

class _Cellule extends StatelessWidget {
  const _Cellule(
    this.texte, {
    this.entete = false,
    this.alignDroite = false,
    this.gras = false,
    this.couleur,
  });

  final String texte;
  final bool entete;
  final bool alignDroite;
  final bool gras;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        texte,
        textAlign: alignDroite ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontWeight: entete || gras ? FontWeight.bold : FontWeight.normal,
          color: couleur ?? const Color(0xFF231A14),
        ),
      ),
    );
  }
}
