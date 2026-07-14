import '../../../produits/domain/usecases/update_product_stock_usecase.dart';
import '../entities/order.dart';
import 'create_order_usecase.dart';

/// ============================================================================
/// ForeverCare AI
/// ValidateOrderUseCase
/// ============================================================================
///
/// Orchestre la validation complète d'une commande.
///
/// Responsabilités :
///
/// 1. Vérifier les règles métier.
/// 2. Enregistrer la commande.
/// 3. Mettre à jour les stocks.
///
/// Cette classe ne connaît ni SQLite,
/// ni Riverpod,
/// ni la couche Data.
///
class ValidateOrderUseCase {
  const ValidateOrderUseCase({
    required CreateOrderUseCase createOrderUseCase,
    required UpdateProductStockUseCase updateProductStockUseCase,
  })  : _createOrderUseCase = createOrderUseCase,
        _updateProductStockUseCase = updateProductStockUseCase;

  final CreateOrderUseCase _createOrderUseCase;

  final UpdateProductStockUseCase _updateProductStockUseCase;

  Future<void> call({
    required Order order,
    required Map<String, int> currentStocks,
  }) async {
    if (order.items.isEmpty) {
      throw StateError(
        'La commande ne contient aucun produit.',
      );
    }

    // Vérification des stocks
    for (final item in order.items) {
      final currentStock =
          currentStocks[item.productId];

      if (currentStock == null) {
        throw StateError(
          'Stock introuvable pour le produit ${item.productName}.',
        );
      }

      if (item.quantity > currentStock) {
        throw StateError(
          'Stock insuffisant pour ${item.productName}.',
        );
      }
    }

    // Création de la commande
    await _createOrderUseCase(order);

    // Mise à jour des stocks
    for (final item in order.items) {
      final currentStock =
          currentStocks[item.productId]!;

      final newStock =
          currentStock - item.quantity;

      await _updateProductStockUseCase(
        productId: item.productId,
        newStock: newStock,
      );
    }
  }
}