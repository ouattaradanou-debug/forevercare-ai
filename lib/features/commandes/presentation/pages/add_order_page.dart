import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/order_controller_provider.dart';
import '../widgets/client_selector_card.dart';
import '../widgets/order_items_card.dart';
import '../widgets/order_notes_card.dart';
import '../widgets/order_summary_card.dart';
import '../../../produits/presentation/pages/product_picker_page.dart';
import '../../../produits/domain/entities/product.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../clients/presentation/pages/client_picker_page.dart';




/// ============================================================================
/// ForeverCare AI
/// AddOrderPage
/// ============================================================================
///
/// Création d'une nouvelle commande.
///
/// Cette page assemble les widgets du module Commandes.
/// Toute la logique métier est déléguée au OrderController.
///
class AddOrderPage extends ConsumerWidget {
  const AddOrderPage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(
      orderControllerProvider,
    );

    final controller = ref.read(
      orderControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nouvelle commande',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 12,
            ),
            child: FilledButton.icon(
              onPressed: state.canSave
                  ? () {
                      if (!controller.validate()) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              state.errorMessage ??
                                  'Commande invalide.',
                            ),
                          ),
                        );
                        return;
                      }

                      final order =
                          controller.buildOrder();

                      // Sauvegarde (Sprint suivant)
                      debugPrint(order.toString());

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Commande prête à être enregistrée.',
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(
                Icons.save,
              ),
              label: const Text(
                'Enregistrer',
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            //------------------------------------------------------------------
            // Client
            //------------------------------------------------------------------

            ClientSelectorCard(
              clientName: state.clientName,
              clientPhone: state.clientPhone,
              onSelect: () async {
                final Client? client =
                    await Navigator.of(context).push<Client>(
                  MaterialPageRoute(
                    builder: (_) => const ClientPickerPage(),
                  ),
                );

                if (client == null || !context.mounted) {
                  return;
                }

                controller.selectClient(client);
              },
              onClear: controller.clearClient,
            ),

            const SizedBox(height: 16),

            //------------------------------------------------------------------
            // Produits
            //------------------------------------------------------------------

            OrderItemsCard(
              items: state.items,
              onAddProduct: () async {
                final Product? product =
                    await Navigator.of(context).push<Product>(
                    MaterialPageRoute(
                    builder: (_) => const ProductPickerPage(),
                    ),
                );

                if (product == null) {
                    return;
                }

                if (!context.mounted) {
                    return;
                }

                controller.addItem(
                    productId: product.id,
                    productCode: product.code,
                    productName: product.name,
                    unitPrice: product.salePrice,
                );
              },
              onRemoveItem: controller.removeItem,
              onQuantityChanged:
                  controller.updateQuantity,
            ),

            const SizedBox(height: 16),

                        //------------------------------------------------------------------
            // Résumé financier
            //------------------------------------------------------------------

            OrderSummaryCard(
              subtotal: state.subtotal,
              discount: state.discount,
              total: state.total,
              onDiscountChanged: controller.setDiscount,
            ),

            const SizedBox(height: 16),

            //------------------------------------------------------------------
            // Remarques
            //------------------------------------------------------------------

            OrderNotesCard(
              notes: state.notes,
              onChanged: controller.setNotes,
            ),

            const SizedBox(height: 24),

            //------------------------------------------------------------------
            // Message d'erreur
            //------------------------------------------------------------------

            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 16,
                ),
                child: Material(
                  color: Theme.of(context)
                      .colorScheme
                      .errorContainer,
                  borderRadius:
                      BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context)
                              .colorScheme
                              .error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            //------------------------------------------------------------------
            // Boutons d'action
            //------------------------------------------------------------------

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      controller.reset();
                    },
                    icon: const Icon(
                      Icons.refresh,
                    ),
                    label: const Text(
                      'Réinitialiser',
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: FilledButton.icon(
                    onPressed: state.canSave
                        ? () {
                            if (!controller.validate()) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    state.errorMessage ??
                                        'Commande invalide.',
                                  ),
                                ),
                              );
                              return;
                            }

                            final order =
                                controller.buildOrder();

                            debugPrint(
                              order.toString(),
                            );

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Commande prête à être enregistrée.',
                                ),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(
                      Icons.check_circle_outline,
                    ),
                    label: const Text(
                      'Valider',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

                        //------------------------------------------------------------------
            // Espace de fin
            //------------------------------------------------------------------

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}