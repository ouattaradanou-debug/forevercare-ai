import '../entities/order.dart';
import '../repositories/order_repository.dart';

class SearchOrdersUseCase {
  SearchOrdersUseCase(this._repository);

  final OrderRepository _repository;

  Future<List<Order>> call(String query) {
    return _repository.searchOrders(query);
  }
}