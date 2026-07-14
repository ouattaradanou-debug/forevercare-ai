import '../entities/order.dart';
import '../repositories/order_repository.dart';

class CreateOrderUseCase {
  CreateOrderUseCase(this._repository);

  final OrderRepository _repository;

  Future<void> call(Order order) {
    return _repository.createOrder(order);
  }
}