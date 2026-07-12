import '../entities/product.dart';
import '../repositories/product_repository.dart';

class CreateProductUseCase {
  CreateProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<void> call(Product product) {
    return _repository.createProduct(product);
  }
}