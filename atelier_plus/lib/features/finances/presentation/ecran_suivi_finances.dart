import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../data/recapitulatif_finances.dart';
import '../providers/finances_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _vertBenefice = Color(0xFF2E7D32);
const _rougeDeficit = Color(0xFFB3261E);

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
/// puis un détail mois par mois pour l'année choisie. "Recettes" regroupe
/// aussi bien les paiements de commande que les ventes directes
/// (prêt-à-porter/tissu/article de couture) : toute entrée d'argent
/// enregistrée dans l'application, quel que soit l'écran, est comptabilisée
/// ici (voir FinancesRepository.recapitulatifBrut).
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
      appBar: AppBar(
        title: const Text('Suivi des finances'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
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
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _bleuSeda, width: 1.5),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: _bleuSeda),
                    onPressed: () => setState(() => _annee -= 1),
                  ),
                  Expanded(
                    child: Text(
                      'Récapitulatif $_annee',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _bleuSeda,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: _bleuSeda),
                    onPressed: () => setState(() => _annee += 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _bleuSeda, width: 2),
          boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 10)],
        ),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {0: FlexColumnWidth(1.1)},
          children: [
            TableRow(
              decoration: const BoxDecoration(color: _bleuSeda),
              children: const [
                _Cellule('Période', entete: true),
                _Cellule('Recettes', entete: true),
                _Cellule('Dépenses', entete: true),
                _Cellule('Bénéfice', entete: true),
              ],
            ),
            _ligne('Jour', recap.jour, 0),
            _ligne('Semaine', recap.semaine, 1),
            _ligne('Mois', recap.mois, 2),
            _ligne('Année', recap.annee, 3),
          ],
        ),
      ),
    );
  }

  TableRow _ligne(String libelle, RecapitulatifPeriode periode, int index) {
    return TableRow(
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xFFF6F3EE),
      ),
      children: [
        _Cellule(libelle, gras: true),
        _Cellule(Formatters.nombre(periode.recettes)),
        _Cellule(Formatters.nombre(periode.depenses)),
        _Cellule(
          Formatters.nombre(periode.solde),
          gras: true,
          couleur: periode.solde < 0 ? _rougeDeficit : _vertBenefice,
        ),
      ],
    );
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _bleuSeda, width: 2),
          boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 10)],
        ),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {0: FlexColumnWidth(1.1)},
          children: [
            TableRow(
              decoration: const BoxDecoration(color: _bleuSeda),
              children: const [
                _Cellule('Mois', entete: true),
                _Cellule('Recettes', entete: true),
                _Cellule('Dépenses', entete: true),
                _Cellule('Bénéfice', entete: true),
              ],
            ),
            for (var i = 0; i < 12; i++)
              TableRow(
                decoration: BoxDecoration(
                  color: moisCourantSurligne == i + 1
                      ? const Color(0xFFFCE4CC)
                      : (i.isEven ? Colors.white : const Color(0xFFF6F3EE)),
                ),
                children: [
                  _Cellule(_nomsMois[i], gras: moisCourantSurligne == i + 1),
                  _Cellule(Formatters.nombre(moisParPeriode[i].recettes)),
                  _Cellule(Formatters.nombre(moisParPeriode[i].depenses)),
                  _Cellule(
                    Formatters.nombre(moisParPeriode[i].solde),
                    gras: true,
                    couleur:
                        moisParPeriode[i].solde < 0 ? _rougeDeficit : _vertBenefice,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Cellule extends StatelessWidget {
  const _Cellule(
    this.texte, {
    this.entete = false,
    this.gras = false,
    this.couleur,
  });

  final String texte;
  final bool entete;
  final bool gras;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Text(
        texte,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: entete || gras ? FontWeight.bold : FontWeight.normal,
          color: entete ? Colors.white : (couleur ?? const Color(0xFF231A14)),
          fontSize: entete ? 13 : 13.5,
        ),
      ),
    );
  }
}
