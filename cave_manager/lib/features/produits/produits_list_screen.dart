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

/// Catalogue produits (point 5 du cahier des charges), organisé en une
/// fiche déroulante par catégorie (Bières, Vins rouges, ...), chacune
/// contenant un tableau des boissons qu'elle contient. Une seule action
/// principale visible : "+" pour créer un produit, réservée au
/// Propriétaire/Propriétaire-Gérant/Gérant (`estResponsable`) — l'Agent de
/// vente consulte la liste mais ne peut ni créer de produit ni gérer les
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
        for (final categorie in categoriesAffichees)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ExpansionTile(
              key: PageStorageKey(categorie.id),
              title: Row(
                children: [
                  Flexible(
                    child: Text(categorie.nom,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Text('(${produitsParCategorie[categorie.id]!.length})',
                      style: Theme.of(context).textTheme.bodySmall),
                  if (!categorie.visible) ...[
                    const SizedBox(width: 8),
                    const Chip(
                      label: Text('Masquée', style: TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
              children: [
                _tableauProduits(context, produitsParCategorie[categorie.id]!),
              ],
            ),
          ),
      ],
    );
  }

  /// Volontairement un `Table` (widget de layout de base) plutôt que le
  /// `DataTable` de Material : ce dernier plante sur l'appareil réel testé
  /// ("type 'bool' is not a subtype of type 'double?'", bug connu du
  /// widget lié à sa colonne de sélection interne) même sans
  /// `onSelectChanged`. `Table` offre le même rendu en grille sans ce
  /// risque.
  Widget _tableauProduits(BuildContext context, List<Produit> produits) {
    final bordure = BorderSide(color: Theme.of(context).dividerColor);
    final couleurNomBoisson = Theme.of(context).colorScheme.primary;
    return Table(
      border: TableBorder(horizontalInside: bordure, verticalInside: bordure),
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1.2),
      },
      children: [
        TableRow(
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surface),
          children: const [
            _CelluleEntete('Boisson'),
            _CelluleEntete('Détail (FCFA)'),
            _CelluleEntete('Gros (FCFA)'),
            _CelluleEntete('Statut'),
          ],
        ),
        for (final produit in produits)
          TableRow(
            children: [
              _celluleTappable(
                context,
                produit,
                Text(produit.nom,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: couleurNomBoisson)),
              ),
              _celluleTappable(context, produit,
                  Text(formaterMontantSansDevise(produit.prixVenteDetail))),
              _celluleTappable(context, produit,
                  Text(formaterMontantSansDevise(produit.prixVenteGros))),
              _celluleTappable(
                context,
                produit,
                produit.actif
                    ? const SizedBox.shrink()
                    : const Chip(
                        label:
                            Text('Inactif', style: TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                      ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _celluleTappable(BuildContext context, Produit produit, Widget enfant) {
    return TableRowInkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProduitDetailScreen(produit: produit, profil: profil),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: enfant,
      ),
    );
  }
}

class _CelluleEntete extends StatelessWidget {
  const _CelluleEntete(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(texte,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }
}
