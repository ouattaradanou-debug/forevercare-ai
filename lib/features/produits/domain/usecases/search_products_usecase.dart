import '../entities/product.dart';
import '../repositories/product_repository.dart';

class SearchProductsUseCase {
  SearchProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call(String query) {
    return _repository.searchProducts(query);
  }
}