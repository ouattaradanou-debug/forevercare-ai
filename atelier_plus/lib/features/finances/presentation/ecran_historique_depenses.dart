import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../providers/finances_providers.dart';

/// Tableau de toutes les dépenses enregistrées (Date, Motif, Montant), la
/// plus récente en premier.
class EcranHistoriqueDepenses extends ConsumerWidget {
  const EcranHistoriqueDepenses({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depenses = ref.watch(depensesDeLAtelierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des dépenses')),
      body: SafeArea(
        child: depenses.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
          data: (liste) {
            if (liste.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Aucune dépense enregistrée pour le moment.'),
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
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
                      _Cellule('Motif', entete: true),
                      _Cellule('Montant', entete: true, alignDroite: true),
                    ]),
                    for (final depense in liste)
                      TableRow(children: [
                        _Cellule(Formatters.dateCourte(depense.date)),
                        _Cellule(
                          depense.description == null || depense.description!.isEmpty
                              ? '—'
                              : depense.description!,
                        ),
                        _Cellule(Formatters.nombre(depense.montant), alignDroite: true),
                      ]),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Cellule extends StatelessWidget {
  const _Cellule(this.texte, {this.entete = false, this.alignDroite = false});

  final String texte;
  final bool entete;
  final bool alignDroite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Text(
        texte,
        textAlign: alignDroite ? TextAlign.right : TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: entete ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xFF231A14),
        ),
      ),
    );
  }
}
