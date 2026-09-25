import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/profil.dart';
import '../../core/utils/fcfa_formatter.dart';
import '../../core/ventes/commande.dart';
import '../../core/ventes/statut_commande.dart';
import '../../core/ventes/ventes_providers.dart';
import 'commande_detail_screen.dart';
import 'nouvelle_commande_screen.dart';

/// Historique des commandes (point 5, Phase 3). Un Agent de vente ne voit
/// que les siennes (déjà filtré côté RLS, `commandes_select`) ; les
/// responsables voient toutes les commandes de la cave.
class CommandesListScreen extends ConsumerWidget {
  const CommandesListScreen({super.key, required this.profil});

  final Profil profil;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandesAsync = ref.watch(commandesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Commandes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NouvelleCommandeScreen(profil: profil),
            ),
          );
          ref.invalidate(commandesProvider);
        },
        tooltip: 'Nouvelle vente',
        child: const Icon(Icons.add_shopping_cart),
      ),
      body: SafeArea(
        child: commandesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Impossible de charger les commandes : $e'),
            ),
          ),
          data: (toutesLesCommandes) {
            // Une commande validée ET intégralement payée n'a plus besoin
            // d'attention : elle disparaît de cette liste (demandé
            // explicitement) — elle reste en base, juste pas affichée ici.
            final commandes = toutesLesCommandes
                .where((c) => !c.estTerminee)
                .toList();
            if (commandes.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Aucune commande pour le moment.'),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: commandes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final commande = commandes[index];
                return ListTile(
                  title: Text(formaterFcfa(commande.total)),
                  subtitle: Text(_formaterDate(commande.createdAt)),
                  trailing: Chip(
                    label: Text(commande.statut.libelle),
                    backgroundColor: _couleurStatut(context, commande.statut),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CommandeDetailScreen(
                          commande: commande, profil: profil),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formaterDate(DateTime dateUtc) {
    final d = dateUtc.toLocal();
    String deuxChiffres(int n) => n.toString().padLeft(2, '0');
    return '${deuxChiffres(d.day)}/${deuxChiffres(d.month)}/${d.year} '
        '${deuxChiffres(d.hour)}:${deuxChiffres(d.minute)}';
  }

  Color? _couleurStatut(BuildContext context, StatutCommande statut) {
    switch (statut) {
      case StatutCommande.annulee:
        return Theme.of(context).colorScheme.errorContainer;
      case StatutCommande.validee:
        return Theme.of(context).colorScheme.secondaryContainer;
      case StatutCommande.enAttente:
        return null;
    }
  }
}
