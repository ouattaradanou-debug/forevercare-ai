/// ============================================================================
/// ForeverCare Framework
/// SQLite - Module Commandes
/// ============================================================================
///
/// Toutes les constantes SQLite du module Commandes.
///
/// Aucune chaîne de caractères SQL ne doit être écrite
/// directement dans les DataSources.
///
abstract final class OrderConstants {
  OrderConstants._();

  //==========================================================================
  // Tables
  //==========================================================================

  static const String ordersTable = 'orders';

  static const String orderItemsTable = 'order_items';

  //==========================================================================
  // Orders
  //==========================================================================

  static const String id = 'id';

  static const String orderNumber = 'order_number';

  static const String clientId = 'client_id';

  static const String orderDate = 'order_date';

  static const String status = 'status';

  static const String discount = 'discount';

  static const String notes = 'notes';

  static const String createdAt = 'created_at';

  static const String updatedAt = 'updated_at';

  //==========================================================================
  // Order Items
  //==========================================================================

  static const String orderId = 'order_id';

  static const String productId = 'product_id';

  static const String productCode = 'product_code';

  static const String productName = 'product_name';

  static const String unitPrice = 'unit_price';

  static const String quantity = 'quantity';
}