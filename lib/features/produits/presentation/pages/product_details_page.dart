import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import '../widgets/product_header.dart';
import '../widgets/product_identity_card.dart';
import '../widgets/product_quick_actions.dart';

/// Dossier complet d'un produit.
///
/// Cette page orchestre les différentes sections
/// du dossier produit.
class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dossier produit'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProductHeader(
              product: product,
            ),

            const SizedBox(height: 16),

            ProductQuickActions(
              onEdit: () {
                // Sprint suivant :
                // ouverture de AddProductPage
                // en mode modification.
              },
              onStock: () {
                // Sprint Inventaire :
                // ajustement du stock.
              },
              onDuplicate: () {
                // Sprint Catalogue :
                // duplication du produit.
              },
              onShare: () {
                // Sprint suivant :
                // partage de la fiche produit.
              },
            ),

            const SizedBox(height: 16),

            ProductIdentityCard(
              product: product,
            ),
          ],
        ),
      ),
    );
  }
}