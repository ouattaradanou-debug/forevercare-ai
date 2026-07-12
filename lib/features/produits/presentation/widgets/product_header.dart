import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';

/// En-tête du dossier produit.
///
/// Ce widget affiche les principales informations
/// d'un produit.
///
/// Il ne contient aucune logique métier.
class ProductHeader extends StatelessWidget {
  const ProductHeader({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.inventory_2,
                size: 42,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              product.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Chip(
              avatar: const Icon(
                Icons.category,
                size: 18,
              ),
              label: Text(product.category),
            ),

            const SizedBox(height: 20),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.qr_code),
              title: const Text('Code produit'),
              subtitle: Text(product.code),
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.inventory),
              title: const Text('Stock disponible'),
              subtitle: Text(
                '${product.stock}',
              ),
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
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
          ],
        ),
      ),
    );
  }
}