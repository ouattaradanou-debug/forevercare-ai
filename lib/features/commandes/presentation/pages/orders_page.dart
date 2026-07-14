import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/order_providers.dart';
import 'add_order_page.dart';
import 'order_details_page.dart';

/// ============================================================================
/// ForeverCare AI
/// OrdersPage
/// ============================================================================
///
/// Affiche la liste des commandes.
///
/// Cette page permet :
///
/// • de consulter toutes les commandes
/// • de rechercher une commande
/// • d'ouvrir une commande
/// • de créer une nouvelle commande
///
class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({
    super.key,
  });

  @override
  ConsumerState<OrdersPage> createState() =>
      _OrdersPageState();
}

class _OrdersPageState
    extends ConsumerState<OrdersPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync =
        ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Commandes',
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        heroTag: 'add_order',
        icon: const Icon(Icons.add),
        label: const Text(
          'Nouvelle',
        ),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  const AddOrderPage(),
            ),
          );

          ref.invalidate(
            ordersProvider,
          );
        },
      ),

      body: Column(
        children: [
          //------------------------------------------------------------
          // Recherche
          //------------------------------------------------------------

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    'Rechercher une commande...',
                prefixIcon:
                    const Icon(Icons.search),
                suffixIcon: _search.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _search = '';
                          });
                        },
                        icon: const Icon(
                          Icons.clear,
                        ),
                      ),
                border:
                    const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _search = value.trim();
                });
              },
            ),
          ),

          //------------------------------------------------------------
          // Liste
          //------------------------------------------------------------

          Expanded(
            child: ordersAsync.when(
              loading: () {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              },

              error: (error, stackTrace) {
                return Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      24,
                    ),
                    child: Text(
                      error.toString(),
                      textAlign:
                          TextAlign.center,
                    ),
                  ),
                );
              },

              data: (orders) {
                final filtered = _search.isEmpty
                    ? orders
                    : orders.where(
                        (order) {
                                                      final query =
                              _search.toLowerCase();

                          return order.orderNumber
                                  .toLowerCase()
                                  .contains(query) ||
                              order.clientId
                                  .toLowerCase()
                                  .contains(query);
                        },
                      ).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Aucune commande trouvée.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    16,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = filtered[index];

                    return Card(
                      elevation: 0,
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            '${index + 1}',
                          ),
                        ),
                        title: Text(
                          order.orderNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Client : ${order.clientId}',
                            ),
                            Text(
                              '${order.items.length} article(s)',
                            ),
                            Text(
                              'Total : ${order.total.toStringAsFixed(0)} FCFA',
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  OrderDetailsPage(
                                orderId: order.id,
                              ),
                            ),
                          );

                          ref.invalidate(
                            ordersProvider,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}