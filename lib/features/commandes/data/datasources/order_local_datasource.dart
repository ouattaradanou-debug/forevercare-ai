import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/base_local_datasource.dart';
import '../../../../core/database/constants/order_constants.dart';
import '../models/order_model.dart';

/// ============================================================================
/// ForeverCare AI
/// OrderLocalDataSource
/// ============================================================================
///
/// Responsable exclusif de la table :
///
/// orders
///
/// Cette classe ne manipule jamais la table
/// order_items.
///
class OrderLocalDataSource extends BaseLocalDataSource {
  OrderLocalDataSource({
    AppDatabase? database,
  }) : super(database ?? AppDatabase.instance);

  //--------------------------------------------------------------------------
  // CREATE
  //--------------------------------------------------------------------------

  Future<void> insert(OrderModel order) async {
    final database = await db;

    await database.insert(
      OrderConstants.ordersTable,
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //--------------------------------------------------------------------------
  // READ
  //--------------------------------------------------------------------------

  Future<OrderModel?> findById(
    String id,
  ) async {
    final database = await db;

    final result = await database.query(
      OrderConstants.ordersTable,
      where: '${OrderConstants.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return OrderModel.fromMap(result.first);
  }

  Future<List<OrderModel>> findAll() async {
    final database = await db;

    final result = await database.query(
      OrderConstants.ordersTable,
      orderBy: '${OrderConstants.orderDate} DESC',
    );

    return result
        .map(OrderModel.fromMap)
        .toList();
  }

  //--------------------------------------------------------------------------
  // UPDATE
  //--------------------------------------------------------------------------

  Future<void> update(
    OrderModel order,
  ) async {
    final database = await db;

    await database.update(
      OrderConstants.ordersTable,
      order.toMap(),
      where: '${OrderConstants.id} = ?',
      whereArgs: [order.id],
    );
  }

  //--------------------------------------------------------------------------
  // DELETE
  //--------------------------------------------------------------------------

  Future<void> delete(
    String id,
  ) async {
    final database = await db;

    await database.delete(
      OrderConstants.ordersTable,
      where: '${OrderConstants.id} = ?',
      whereArgs: [id],
    );
  }

  //--------------------------------------------------------------------------
  // SEARCH
  //--------------------------------------------------------------------------

  Future<List<OrderModel>> search(
    String query,
  ) async {
    final database = await db;

    final result = await database.query(
      OrderConstants.ordersTable,
      where: '''
        ${OrderConstants.orderNumber} LIKE ?
        OR ${OrderConstants.clientId} LIKE ?
      ''',
      whereArgs: [
        '%$query%',
        '%$query%',
      ],
      orderBy: '${OrderConstants.orderDate} DESC',
    );

    return result
        .map(OrderModel.fromMap)
        .toList();
  }
}