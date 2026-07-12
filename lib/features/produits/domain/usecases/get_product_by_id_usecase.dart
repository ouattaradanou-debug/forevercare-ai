import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductByIdUseCase {
  GetProductByIdUseCase(this._repository);

  final ProductRepository _repository;

  Future<Product?> call(String id) {
    return _repository.getProductById(id);
  }
}