import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/order_providers.dart';

/// ============================================================================
/// ForeverCare AI
/// OrderDetailsPage
/// ============================================================================
///
/// Affiche les informations d'une commande.
///
/// Cette première version est volontairement en lecture seule.
/// Les fonctionnalités de modification seront ajoutées
/// dans un sprint ultérieur.
///
class OrderDetailsPage extends ConsumerWidget {
  const OrderDetailsPage({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final ordersAsync = ref.watch(
      ordersProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Détails de la commande',
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (orders) {
          final order = orders.cast().firstWhere(
            (element) => element.id == orderId,
            orElse: () => throw Exception(
              'Commande introuvable.',
            ),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 0,
                child: ListTile(
                  leading: const Icon(
                    Icons.receipt_long,
                  ),
                  title: Text(
                    order.orderNumber,
                  ),
                  subtitle: Text(
                    'Client : ${order.clientId}',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Produits',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      ...order.items.map(
                        (item) => ListTile(
                          contentPadding:
                              EdgeInsets.zero,
                          title: Text(
                            item.productName,
                          ),
                          subtitle: Text(
                            '${item.quantity} × ${item.unitPrice.toStringAsFixed(0)} FCFA',
                          ),
                          trailing: Text(
                            '${item.total.toStringAsFixed(0)} FCFA',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _AmountRow(
                        label: 'Sous-total',
                        value: order.subtotal,
                      ),
                      const SizedBox(height: 8),
                      _AmountRow(
                        label: 'Remise',
                        value: order.discount,
                      ),
                      const Divider(),
                      _AmountRow(
                        label: 'Total',
                        value: order.total,
                        highlight: true,
                      ),
                    ],
                  ),
                ),
              ),

              if (order.notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Remarques',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(order.notes),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final double value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final style = highlight
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  Theme.of(context).colorScheme.primary,
            )
        : Theme.of(context).textTheme.bodyLarge;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: style,
          ),
        ),
        Text(
          '${value.toStringAsFixed(0)} FCFA',
          style: style,
        ),
      ],
    );
  }
}