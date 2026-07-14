import '../../domain/entities/order_item.dart';
import '../models/order_item_model.dart';

/// ============================================================================
/// ForeverCare AI
/// OrderItemMapper
/// ============================================================================
///
/// Responsable des conversions entre :
///
/// Domain <-> Data
///
/// Ce mapper est le seul endroit où les conversions
/// entre OrderItem et OrderItemModel sont autorisées.
///
abstract final class OrderItemMapper {
  OrderItemMapper._();

  /// Convertit une entité Domain vers un Model Data.
  static OrderItemModel toModel(OrderItem entity) {
    return OrderItemModel(
      id: entity.id,
      orderId: entity.orderId,
      productId: entity.productId,
      productCode: entity.productCode,
      productName: entity.productName,
      unitPrice: entity.unitPrice,
      quantity: entity.quantity,
    );
  }

  /// Convertit un Model Data vers une entité Domain.
  static OrderItem toEntity(OrderItemModel model) {
    return OrderItem(
      id: model.id,
      orderId: model.orderId,
      productId: model.productId,
      productCode: model.productCode,
      productName: model.productName,
      unitPrice: model.unitPrice,
      quantity: model.quantity,
    );
  }

  /// Convertit une liste d'entités vers une liste de modèles.
  static List<OrderItemModel> toModels(
    List<OrderItem> entities,
  ) {
    return entities.map(toModel).toList();
  }

  /// Convertit une liste de modèles vers une liste d'entités.
  static List<OrderItem> toEntities(
    List<OrderItemModel> models,
  ) {
    return models.map(toEntity).toList();
  }
}