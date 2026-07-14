import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrderByIdUseCase {
  GetOrderByIdUseCase(this._repository);

  final OrderRepository _repository;

  Future<Order?> call(String id) {
    return _repository.getOrderById(id);
  }
}