import '../repositories/order_repository.dart';

class DeleteOrderUseCase {
  DeleteOrderUseCase(this._repository);

  final OrderRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteOrder(id);
  }
}