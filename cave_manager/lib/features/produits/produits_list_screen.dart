import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/profil.dart';
import '../../core/produits/categorie_produit.dart';
import '../../core/produits/produit.dart';
import '../../core/produits/produits_providers.dart';
import '../../core/utils/fcfa_formatter.dart';
import 'categories_produits_screen.dart';
import 'produit_detail_screen.dart';
import 'produit_form_screen.dart';

/// Catalogue produits (point 5 du cahier des charges), regroupé par
/// catégorie (Bières, Vins rouges, ...). Une seule action principale
/// visible : "+" pour créer un produit, réservée au Propriétaire/
/// Propriétaire-Gérant/Gérant (`estResponsable`) — l'Agent de vente
/// consulte la liste mais ne peut ni créer de produit ni gérer les
/// catégories. Une catégorie masquée n'apparaît que pour `estResponsable`
/// (avec un repère visuel), jamais pour l'Agent.
class ProduitsListScreen extends ConsumerWidget {
  const ProduitsListScreen({super.key, required this.profil});

  final Profil profil;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produitsAsync = ref.watch(produitsProvider);
    final categoriesAsync = ref.watch(categoriesProduitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        actions: [
          if (profil.role.estResponsable)
            IconButton(
              icon: const Icon(Icons.category_outlined),
              tooltip: 'Gérer les catégories',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      CategoriesProduitsScreen(caveId: profil.caveId),
                ),
              ),
            ),
        ],
      ),
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
            return categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Impossible de charger les catégories : $e')),
              data: (categories) => _listeGroupee(context, categories, produits),
            );
          },
        ),
      ),
    );
  }

  Widget _listeGroupee(BuildContext context, List<CategorieProduit> categories,
      List<Produit> produits) {
    final produitsParCategorie = <String, List<Produit>>{};
    for (final produit in produits) {
      produitsParCategorie.putIfAbsent(produit.categorieId, () => []).add(produit);
    }

    final categoriesAffichees = categories.where((c) {
      final aDesProduits = produitsParCategorie[c.id]?.isNotEmpty ?? false;
      if (!aDesProduits) return false;
      return c.visible || profil.role.estResponsable;
    }).toList()
      ..sort((a, b) => a.ordre.compareTo(b.ordre));

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final categorie in categoriesAffichees) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
            child: Row(
              children: [
                Text(categorie.nom, style: Theme.of(context).textTheme.titleMedium),
                if (!categorie.visible) ...[
                  const SizedBox(width: 8),
                  const Chip(
                    label: Text('Masquée', style: TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
          ),
          for (final produit in produitsParCategorie[categorie.id]!) ...[
            ListTile(
              title: Text(produit.nom),
              subtitle: Text(
                  'Détail : ${formaterFcfa(produit.prixVenteDetail)}  ·  '
                  'Gros : ${formaterFcfa(produit.prixVenteGros)}'),
              trailing: produit.actif ? null : const Chip(label: Text('Inactif')),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ProduitDetailScreen(produit: produit, profil: profil),
                ),
              ),
            ),
            const Divider(height: 1),
          ],
        ],
      ],
    );
  }
}
