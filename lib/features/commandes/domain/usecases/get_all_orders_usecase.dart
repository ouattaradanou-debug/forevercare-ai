import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetAllOrdersUseCase {
  GetAllOrdersUseCase(this._repository);

  final OrderRepository _repository;

  Future<List<Order>> call() {
    return _repository.getAllOrders();
  }
}