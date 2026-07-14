import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/navigation/app_drawer.dart';
import '../providers/product_providers.dart';
import 'add_product_page.dart';

/// Liste des produits.
class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le produit'),
          content: const Text(
            'Voulez-vous vraiment supprimer ce produit ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Produits'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => const AddProductPage(),
            ),
          );

          if (result == true) {
            ref.invalidate(productsProvider);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau produit'),
      ),
      body: productsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Erreur lors du chargement des produits.\n\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 72,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Aucun produit enregistré.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Cliquez sur "Nouveau produit" pour créer votre premier produit.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // La liste sera ajoutée dans la livraison C2.
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      product.name.substring(0, 1).toUpperCase(),
                    ),
                  ),

                  title: Text(product.name),

                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(product.code),
                      Text(product.category),
                      Text('Stock : ${product.stock}'),
                    ],
                  ),

                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'edit':
                          final result =
                              await Navigator.of(context)
                                  .push<bool>(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddProductPage(
                                product: product,
                              ),
                            ),
                          );

                          if (result == true) {
                            ref.invalidate(
                              productsProvider,
                            );
                          }

                          break;

                        case 'delete':
                          final confirmed = await _confirmDelete(context);

                          if (!confirmed) {
                            break;
                          }

                          final deleteProduct =
                              ref.read(deleteProductUseCaseProvider);

                          await deleteProduct(product.id);

                          ref.invalidate(productsProvider);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${product.name} a été supprimé.',
                                ),
                              ),
                            );
                          }

                          break;
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Modifier'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Supprimer'),
                        ),
                      ),
                    ],
                  ),

                  onTap: () async {
                    final result =
                        await Navigator.of(context)
                            .push<bool>(
                      MaterialPageRoute(
                        builder: (_) =>
                            AddProductPage(
                          product: product,
                        ),
                      ),
                    );

                    if (result == true) {
                      ref.invalidate(
                        productsProvider,
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}