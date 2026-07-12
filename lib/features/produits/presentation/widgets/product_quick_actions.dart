import 'package:flutter/material.dart';

/// Barre d'actions rapides du dossier produit.
///
/// Ce widget ne contient aucune logique métier.
/// Toutes les actions sont déléguées au parent.
class ProductQuickActions extends StatelessWidget {
  const ProductQuickActions({
    super.key,
    this.onEdit,
    this.onStock,
    this.onDuplicate,
    this.onShare,
  });

  final VoidCallback? onEdit;

  final VoidCallback? onStock;

  final VoidCallback? onDuplicate;

  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              label: const Text('Modifier'),
            ),

            FilledButton.tonalIcon(
              onPressed: onStock,
              icon: const Icon(Icons.inventory),
              label: const Text('Stock'),
            ),

            FilledButton.tonalIcon(
              onPressed: onDuplicate,
              icon: const Icon(Icons.copy),
              label: const Text('Dupliquer'),
            ),

            OutlinedButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share),
              label: const Text('Partager'),
            ),
          ],
        ),
      ),
    );
  }
}