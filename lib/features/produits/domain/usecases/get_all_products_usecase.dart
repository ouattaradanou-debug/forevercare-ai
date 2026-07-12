import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetAllProductsUseCase {
  GetAllProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call() {
    return _repository.getAllProducts();
  }
}