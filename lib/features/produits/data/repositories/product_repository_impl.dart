import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required ProductLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final ProductLocalDataSource _localDataSource;

  @override
  Future<void> createProduct(Product product) async {
    final model = ProductModel.fromEntity(product);

    await _localDataSource.insert(model);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final model = ProductModel.fromEntity(product);

    await _localDataSource.update(model);
  }

  @override
  Future<void> updateStock(
    String productId,
    int newStock,
  ) async {
    if (newStock < 0) {
      throw ArgumentError(
        'Le stock ne peut pas être négatif.',
      );
    }

    await _localDataSource.updateStock(
      productId,
      newStock,
    );
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _localDataSource.delete(id);
  }

  @override
  Future<Product?> getProductById(String id) async {
    final model = await _localDataSource.findById(id);

    return model?.toEntity();
  }

  @override
  Future<List<Product>> getAllProducts() async {
    final models = await _localDataSource.findAll();

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final products = await getAllProducts();

    final q = query.toLowerCase();

    return products.where((product) {
      return product.name.toLowerCase().contains(q) ||
          product.code.toLowerCase().contains(q) ||
          product.category.toLowerCase().contains(q);
    }).toList();
  }
}