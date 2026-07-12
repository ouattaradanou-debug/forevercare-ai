/// ============================================================================
/// Table : products
/// ============================================================================
abstract final class ProductConstants {
  ProductConstants._();

  /// Table
  static const String table = 'products';

  /// Colonnes
  static const String id = 'id';

  static const String code = 'code';

  static const String name = 'name';

  static const String category = 'category';

  static const String description = 'description';

  static const String purchasePrice = 'purchase_price';

  static const String salePrice = 'sale_price';

  static const String stock = 'stock';

  static const String alertStock = 'alert_stock';

  static const String isActive = 'is_active';

  static const String createdAt = 'created_at';

  static const String updatedAt = 'updated_at';
}