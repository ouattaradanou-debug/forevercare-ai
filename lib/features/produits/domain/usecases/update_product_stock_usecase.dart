import '../repositories/product_repository.dart';

/// ============================================================================
/// ForeverCare AI
/// UpdateProductStockUseCase
/// ============================================================================
///
/// Met à jour le stock d'un produit.
///
/// Cette classe ne connaît ni SQLite,
/// ni Riverpod,
/// ni la couche Data.
///
/// Toute la persistance est déléguée au repository.
///
class UpdateProductStockUseCase {
  const UpdateProductStockUseCase(
    this._repository,
  );

  final ProductRepository _repository;

  /// Met à jour le stock d'un produit.
  ///
  /// [productId] : identifiant du produit.
  /// [newStock] : nouvelle quantité en stock.
  Future<void> call({
    required String productId,
    required int newStock,
  }) {
    if (newStock < 0) {
      throw ArgumentError(
        'Le stock ne peut pas être négatif.',
      );
    }

    return _repository.updateStock(
      productId,
      newStock,
    );
  }
}