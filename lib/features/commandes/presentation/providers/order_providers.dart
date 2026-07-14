import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../produits/presentation/providers/product_providers.dart';

import '../../data/datasources/order_item_local_datasource.dart';
import '../../data/datasources/order_local_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';

import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/delete_order_usecase.dart';
import '../../domain/usecases/get_all_orders_usecase.dart';
import '../../domain/usecases/get_order_by_id_usecase.dart';
import '../../domain/usecases/search_orders_usecase.dart';
import '../../domain/usecases/update_order_usecase.dart';
import '../../domain/usecases/validate_order_usecase.dart';

/// ============================================================================
/// ForeverCare AI
/// Providers - Module Commandes
/// ============================================================================

/// DataSource : Orders
final orderLocalDataSourceProvider =
    Provider<OrderLocalDataSource>(
  (ref) => OrderLocalDataSource(),
);

/// DataSource : Order Items
final orderItemLocalDataSourceProvider =
    Provider<OrderItemLocalDataSource>(
  (ref) => OrderItemLocalDataSource(),
);

/// Repository
final orderRepositoryProvider =
    Provider<OrderRepository>(
  (ref) => OrderRepositoryImpl(
    orderLocalDataSource:
        ref.read(orderLocalDataSourceProvider),
    orderItemLocalDataSource:
        ref.read(orderItemLocalDataSourceProvider),
  ),
);

/// UseCase : création
final createOrderUseCaseProvider =
    Provider<CreateOrderUseCase>(
  (ref) => CreateOrderUseCase(
    ref.read(orderRepositoryProvider),
  ),
);

/// UseCase : modification
final updateOrderUseCaseProvider =
    Provider<UpdateOrderUseCase>(
  (ref) => UpdateOrderUseCase(
    ref.read(orderRepositoryProvider),
  ),
);

/// UseCase : suppression
final deleteOrderUseCaseProvider =
    Provider<DeleteOrderUseCase>(
  (ref) => DeleteOrderUseCase(
    ref.read(orderRepositoryProvider),
  ),
);

/// UseCase : lecture
final getAllOrdersUseCaseProvider =
    Provider<GetAllOrdersUseCase>(
  (ref) => GetAllOrdersUseCase(
    ref.read(orderRepositoryProvider),
  ),
);

/// UseCase : recherche
final searchOrdersUseCaseProvider =
    Provider<SearchOrdersUseCase>(
  (ref) => SearchOrdersUseCase(
    ref.read(orderRepositoryProvider),
  ),
);

/// UseCase : lecture par identifiant
final getOrderByIdUseCaseProvider =
    Provider<GetOrderByIdUseCase>(
  (ref) => GetOrderByIdUseCase(
    ref.read(orderRepositoryProvider),
  ),
);

/// ============================================================================
/// UseCase : Validation complète d'une commande
/// ============================================================================

final validateOrderUseCaseProvider =
    Provider<ValidateOrderUseCase>(
  (ref) => ValidateOrderUseCase(
    createOrderUseCase:
        ref.read(createOrderUseCaseProvider),
    updateProductStockUseCase:
        ref.read(updateProductStockUseCaseProvider),
  ),
);

/// Liste des commandes
final ordersProvider =
    FutureProvider<List<Order>>(
  (ref) async {
    final useCase =
        ref.read(getAllOrdersUseCaseProvider);

    return useCase();
  },
);

final validateOrderUseCaseProvider =
    Provider<ValidateOrderUseCase>(
  (ref) => ValidateOrderUseCase(
    createOrderUseCase:
        ref.read(createOrderUseCaseProvider),
    updateProductStockUseCase:
        ref.read(updateProductStockUseCaseProvider),
  ),
);

final getProductByIdUseCaseProvider =
    Provider<GetProductByIdUseCase>(
  (ref) => GetProductByIdUseCase(
    ref.read(productRepositoryProvider),
  ),
);