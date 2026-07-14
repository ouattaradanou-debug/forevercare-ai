import '../entities/product.dart';

abstract class ProductRepository {
  /// Retourne tous les produits.
  Future<List<Product>> getAllProducts();

  /// Recherche un produit par son identifiant.
  Future<Product?> getProductById(String id);

  /// Ajoute un nouveau produit.
  Future<void> createProduct(Product product);

  /// Met à jour un produit existant.
  Future<void> updateProduct(Product product);

  /// Supprime un produit.
  Future<void> deleteProduct(String id);

  /// Recherche des produits par nom, code ou catégorie.
  Future<List<Product>> searchProducts(String query);
  
  /// Met à jour uniquement le stock d'un produit.
  ///
  /// [productId] : identifiant du produit.
  /// [newStock] : nouvelle quantité en stock.
  Future<void> updateStock(
    String productId,
    int newStock,
  );
}