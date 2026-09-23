import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/profil.dart';
import '../../core/produits/produits_providers.dart';
import '../../core/utils/fcfa_formatter.dart';
import 'produit_detail_screen.dart';
import 'produit_form_screen.dart';

/// Catalogue produits (point 5 du cahier des charges). Une seule action
/// principale visible : "+" pour créer un produit, réservée au
/// Propriétaire/Propriétaire-Gérant/Gérant (`estResponsable`) — l'Agent de
/// vente consulte la liste mais ne peut pas créer de nouveau produit.
class ProduitsListScreen extends ConsumerWidget {
  const ProduitsListScreen({super.key, required this.profil});

  final Profil profil;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produitsAsync = ref.watch(produitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Produits')),
      floatingActionButton: profil.role.estResponsable
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProduitFormScreen(caveId: profil.caveId),
                ),
              ),
              tooltip: 'Nouveau produit',
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: produitsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Impossible de charger les produits : $e'),
            ),
          ),
          data: (produits) {
            if (produits.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Aucun produit pour le moment.'),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: produits.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final produit = produits[index];
                return ListTile(
                  title: Text(produit.nom),
                  subtitle: Text(
                      'Détail : ${formaterFcfa(produit.prixVenteDetail)}  ·  '
                      'Gros : ${formaterFcfa(produit.prixVenteGros)}'),
                  trailing: produit.actif
                      ? null
                      : const Chip(label: Text('Inactif')),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProduitDetailScreen(
                          produit: produit, profil: profil),
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
}
