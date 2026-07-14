import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/product_providers.dart';

/// ============================================================================
/// ForeverCare AI
/// ProductPickerPage
/// ============================================================================
///
/// Permet de sélectionner un produit depuis le catalogue.
///
/// Retourne un produit sélectionné.
///
class ProductPickerPage extends ConsumerStatefulWidget {
  const ProductPickerPage({
    super.key,
  });

  @override
  ConsumerState<ProductPickerPage> createState() =>
      _ProductPickerPageState();
}

class _ProductPickerPageState
    extends ConsumerState<ProductPickerPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un produit'),
      ),
      body: Column(
        children: [
          //------------------------------------------------------------------
          // Recherche
          //------------------------------------------------------------------

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _query = '';
                          });
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value.trim().toLowerCase();
                });
              },
            ),
          ),

          //------------------------------------------------------------------
          // Liste des produits
          //------------------------------------------------------------------

          Expanded(
            child: productsAsync.when(
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
              data: (products) {
                final filtered = _query.isEmpty
                    ? products
                    : products.where((product) {
                        return product.name
                                .toLowerCase()
                                .contains(_query) ||
                            product.code
                                .toLowerCase()
                                .contains(_query) ||
                            product.category
                                .toLowerCase()
                                .contains(_query);
                      }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun produit trouvé.',
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
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final product = filtered[index];

                    final bool outOfStock =
                        product.stock <= 0;

                    final bool lowStock =
                        !outOfStock &&
                        product.isLowStock;

                    final Color iconColor =
                        outOfStock
                            ? Colors.red
                            : lowStock
                                ? Colors.orange
                                : Colors.green;

                    final Color backgroundColor =
                        outOfStock
                            ? Colors.red.shade100
                            : lowStock
                                ? Colors.orange.shade100
                                : Colors.green.shade100;

                    final IconData statusIcon =
                        outOfStock
                            ? Icons.block
                            : lowStock
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle;

                    final String statusText =
                        outOfStock
                            ? 'Rupture de stock'
                            : lowStock
                                ? 'Stock faible'
                                : 'Disponible';

                    return Card(
                      elevation: 0,
                      child: ListTile(
                        enabled:
                            product.isActive &&
                            !outOfStock,

                        leading: CircleAvatar(
                          backgroundColor:
                              backgroundColor,
                          child: Icon(
                            statusIcon,
                            color: iconColor,
                          ),
                        ),

                        title: Text(product.name),

                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(product.code),
                            Text(product.category),

                            const SizedBox(height: 4),

                            Row(
                              children: [
                                Icon(
                                  statusIcon,
                                  size: 16,
                                  color: iconColor,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    statusText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        trailing: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${product.salePrice.toStringAsFixed(0)} FCFA',
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Stock : ${product.stock}',
                            ),
                          ],
                        ),

                        onTap: product.isActive &&
                                !outOfStock
                            ? () {
                                Navigator.of(
                                  context,
                                ).pop(product);
                              }
                            : null,
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