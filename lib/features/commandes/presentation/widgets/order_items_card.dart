import 'package:flutter/material.dart';

import '../../domain/entities/order_item.dart';

/// ============================================================================
/// ForeverCare AI
/// OrderItemsCard
/// ============================================================================
///
/// Affiche les lignes de la commande.
///
/// Ce widget est purement visuel.
/// Toute la logique est déléguée au OrderController.
///
class OrderItemsCard extends StatelessWidget {
  const OrderItemsCard({
    super.key,
    required this.items,
    this.onAddProduct,
    this.onRemoveItem,
    this.onQuantityChanged,
  });

  final List<OrderItem> items;

  final VoidCallback? onAddProduct;

  final ValueChanged<String>? onRemoveItem;

  final void Function(
    String itemId,
    int quantity,
  )? onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //----------------------------------------------------------------
            // En-tête
            //----------------------------------------------------------------

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Produits',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                FilledButton.icon(
                  onPressed: onAddProduct,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Ajouter',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            //----------------------------------------------------------------
            // Aucun produit
            //----------------------------------------------------------------

            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 24,
                ),
                child: Text(
                  'Aucun produit ajouté.',
                ),
              ),

            //----------------------------------------------------------------
            // Liste
            //----------------------------------------------------------------

            if (items.isNotEmpty)
              ...items.map(
                (item) => Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            item.productName,
                          ),
                          subtitle: Text(
                            item.productCode,
                          ),
                          trailing: IconButton(
                            tooltip: 'Supprimer',
                            onPressed: () =>
                                onRemoveItem?.call(item.id),
                            icon: const Icon(
                              Icons.delete_outline,
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                final quantity =
                                    item.quantity - 1;

                                onQuantityChanged?.call(
                                  item.id,
                                  quantity,
                                );
                              },
                              icon: const Icon(
                                Icons.remove_circle_outline,
                              ),
                            ),

                            SizedBox(
                              width: 50,
                              child: Center(
                                child: Text(
                                  '${item.quantity}',
                                  style: theme
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                final quantity =
                                    item.quantity + 1;

                                onQuantityChanged?.call(
                                  item.id,
                                  quantity,
                                );
                              },
                              icon: const Icon(
                                Icons.add_circle_outline,
                              ),
                            ),

                            const Spacer(),

                            Text(
                              '${item.total.toStringAsFixed(0)} FCFA',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}