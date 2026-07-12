import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';

/// Carte des informations générales d'un produit.
///
/// Ce widget affiche les informations détaillées
/// du produit sans contenir de logique métier.
class ProductIdentityCard extends StatelessWidget {
  const ProductIdentityCard({
    super.key,
    required this.product,
  });

  final Product product;

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatPrice(double value) {
    return '${value.toStringAsFixed(0)} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final lowStock = product.isLowStock;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const ListTile(
              leading: Icon(Icons.inventory_2),
              title: Text(
                'Informations générales',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Code produit'),
              subtitle: Text(product.code),
            ),

            ListTile(
              leading: const Icon(Icons.label_outline),
              title: const Text('Nom'),
              subtitle: Text(product.name),
            ),

            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Catégorie'),
              subtitle: Text(product.category),
            ),

            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Description'),
              subtitle: Text(
                product.description.isEmpty
                    ? 'Non renseignée'
                    : product.description,
              ),
            ),

            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Prix d\'achat'),
              subtitle: Text(
                _formatPrice(product.purchasePrice),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.sell),
              title: const Text('Prix de vente'),
              subtitle: Text(
                _formatPrice(product.salePrice),
              ),
            ),

            ListTile(
              leading: Icon(
                lowStock
                    ? Icons.warning_amber_rounded
                    : Icons.inventory,
                color: lowStock
                    ? Colors.orange
                    : null,
              ),
              title: const Text('Stock'),
              subtitle: Text(
                '${product.stock} unité(s)',
              ),
            ),

            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: const Text('Seuil d\'alerte'),
              subtitle: Text(
                '${product.alertStock} unité(s)',
              ),
            ),

            ListTile(
              leading: Icon(
                product.isActive
                    ? Icons.check_circle
                    : Icons.cancel,
                color: product.isActive
                    ? Colors.green
                    : Colors.red,
              ),
              title: const Text('Statut'),
              subtitle: Text(
                product.isActive
                    ? 'Actif'
                    : 'Inactif',
              ),
            ),

            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Créé le'),
              subtitle: Text(
                _formatDate(product.createdAt),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Dernière mise à jour'),
              subtitle: Text(
                _formatDate(product.updatedAt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}