import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/product_local_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_all_products_usecase.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../domain/usecases/update_product_stock_usecase.dart';


/// DataSource locale
final productLocalDataSourceProvider =
    Provider<ProductLocalDataSource>(
  (ref) => ProductLocalDataSource(),
);

/// Repository
final productRepositoryProvider =
    Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(
    localDataSource: ref.read(productLocalDataSourceProvider),
  ),
);

/// UseCase : création
final createProductUseCaseProvider =
    Provider<CreateProductUseCase>(
  (ref) => CreateProductUseCase(
    ref.read(productRepositoryProvider),
  ),
);

/// UseCase : modification
final updateProductUseCaseProvider =
    Provider<UpdateProductUseCase>(
  (ref) => UpdateProductUseCase(
    ref.read(productRepositoryProvider),
  ),
);

/// UseCase : suppression
final deleteProductUseCaseProvider =
    Provider<DeleteProductUseCase>(
  (ref) => DeleteProductUseCase(
    ref.read(productRepositoryProvider),
  ),
);

/// UseCase : lecture
final getAllProductsUseCaseProvider =
    Provider<GetAllProductsUseCase>(
  (ref) => GetAllProductsUseCase(
    ref.read(productRepositoryProvider),
  ),
);

/// UseCase : recherche
final searchProductsUseCaseProvider =
    Provider<SearchProductsUseCase>(
  (ref) => SearchProductsUseCase(
    ref.read(productRepositoryProvider),
  ),
);

/// UseCase : lecture par id
final getProductByIdUseCaseProvider =
    Provider<GetProductByIdUseCase>(
  (ref) => GetProductByIdUseCase(
    ref.read(productRepositoryProvider),
  ),
);

/// UseCase : mise à jour du stock
final updateProductStockUseCaseProvider =
    Provider<UpdateProductStockUseCase>(
  (ref) => UpdateProductStockUseCase(
    ref.read(productRepositoryProvider),
  ),
);

/// Liste des produits
final productsProvider =
    FutureProvider<List<Product>>((ref) async {
  final useCase = ref.read(
    getAllProductsUseCaseProvider,
  );

  return useCase();
});