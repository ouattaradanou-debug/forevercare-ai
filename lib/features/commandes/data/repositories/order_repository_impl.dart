import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_item_local_datasource.dart';
import '../datasources/order_local_datasource.dart';
import '../mappers/order_item_mapper.dart';
import '../mappers/order_mapper.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required OrderLocalDataSource orderLocalDataSource,
    required OrderItemLocalDataSource orderItemLocalDataSource,
  })  : _orderLocalDataSource = orderLocalDataSource,
        _orderItemLocalDataSource = orderItemLocalDataSource;

  final OrderLocalDataSource _orderLocalDataSource;
  final OrderItemLocalDataSource _orderItemLocalDataSource;

  @override
  Future<void> createOrder(Order order) async {
    final orderModel = OrderMapper.toModel(order);

    await _orderLocalDataSource.insert(orderModel);

    if (order.items.isNotEmpty) {
      final itemModels = OrderItemMapper.toModels(order.items);

      await _orderItemLocalDataSource.insertAll(itemModels);
    }
  }

  @override
  Future<void> updateOrder(Order order) async {
    final orderModel = OrderMapper.toModel(order);

    await _orderLocalDataSource.update(orderModel);

    await _orderItemLocalDataSource.deleteByOrderId(order.id);

    if (order.items.isNotEmpty) {
      final itemModels = OrderItemMapper.toModels(order.items);

      await _orderItemLocalDataSource.insertAll(itemModels);
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    await _orderItemLocalDataSource.deleteByOrderId(id);

    await _orderLocalDataSource.delete(id);
  }

  @override
  Future<Order?> getOrderById(String id) async {
    final orderModel = await _orderLocalDataSource.findById(id);

    if (orderModel == null) {
      return null;
    }

    final itemModels =
        await _orderItemLocalDataSource.findByOrderId(id);

    final completeModel = orderModel.copyWith(
      items: itemModels,
    );

    return OrderMapper.toEntity(completeModel);
  }

  @override
  Future<List<Order>> getAllOrders() async {
    final orderModels = await _orderLocalDataSource.findAll();

    final orders = <Order>[];

    for (final model in orderModels) {
      final items =
          await _orderItemLocalDataSource.findByOrderId(
        model.id,
      );

      orders.add(
        OrderMapper.toEntity(
          model.copyWith(
            items: items,
          ),
        ),
      );
    }

    return orders;
  }

  @override
  Future<List<Order>> searchOrders(String query) async {
    final orderModels =
        await _orderLocalDataSource.search(query);

    final orders = <Order>[];

    for (final model in orderModels) {
      final items =
          await _orderItemLocalDataSource.findByOrderId(
        model.id,
      );

      orders.add(
        OrderMapper.toEntity(
          model.copyWith(
            items: items,
          ),
        ),
      );
    }

    return orders;
  }
}