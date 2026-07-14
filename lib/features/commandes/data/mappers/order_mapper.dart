import '../../domain/entities/order.dart';
import '../models/order_model.dart';
import 'order_item_mapper.dart';

/// ============================================================================
/// ForeverCare Framework
/// Order Mapper
/// ============================================================================
///
/// Conversion entre :
///
/// Domain <-> Data
///
/// Ce mapper est le seul endroit autorisé à convertir
/// Order vers OrderModel et inversement.
abstract final class OrderMapper {
  OrderMapper._();

  /// Domain -> Data
  static OrderModel toModel(Order entity) {
    return OrderModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      clientId: entity.clientId,
      orderDate: entity.orderDate,
      status: entity.status.name,
      discount: entity.discount,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      items: OrderItemMapper.toModels(entity.items),
    );
  }

  /// Data -> Domain
  static Order toEntity(OrderModel model) {
    return Order(
      id: model.id,
      orderNumber: model.orderNumber,
      clientId: model.clientId,
      orderDate: model.orderDate,
      status: OrderStatus.values.firstWhere(
        (value) => value.name == model.status,
        orElse: () => OrderStatus.draft,
      ),
      items: OrderItemMapper.toEntities(model.items),
      discount: model.discount,
      notes: model.notes,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Liste Domain -> Data
  static List<OrderModel> toModels(
    List<Order> entities,
  ) {
    return entities.map(toModel).toList();
  }

  /// Liste Data -> Domain
  static List<Order> toEntities(
    List<OrderModel> models,
  ) {
    return models.map(toEntity).toList();
  }
}