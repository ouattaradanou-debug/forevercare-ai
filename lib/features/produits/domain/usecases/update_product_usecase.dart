import '../entities/product.dart';
import '../repositories/product_repository.dart';

class UpdateProductUseCase {
  UpdateProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<void> call(Product product) {
    return _repository.updateProduct(product);
  }
}