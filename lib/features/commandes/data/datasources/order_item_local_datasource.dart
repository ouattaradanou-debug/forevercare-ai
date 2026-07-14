import 'package:sqflite/sqflite.dart';

import '../../../../core/database/base_local_datasource.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/constants/order_constants.dart';

import '../models/order_item_model.dart';

/// ============================================================================
/// ForeverCare AI
/// OrderItemLocalDataSource
/// ============================================================================
///
/// Responsable exclusif de la table :
///
/// order_items
///
/// Cette classe ne manipule jamais la table orders.
///
/// Toutes les opérations sont limitées aux lignes
/// d'une commande.
///
class OrderItemLocalDataSource extends BaseLocalDataSource {
  OrderItemLocalDataSource({
    AppDatabase? database,
  }) : super(database ?? AppDatabase.instance);

  //--------------------------------------------------------------------------
  // CREATE
  //--------------------------------------------------------------------------

  Future<void> insert(OrderItemModel item) async {
    final database = await db;

    await database.insert(
      OrderConstants.orderItemsTable,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertAll(
    List<OrderItemModel> items,
  ) async {
    if (items.isEmpty) {
      return;
    }

    await transaction((txn) async {
      final batch = txn.batch();

      for (final item in items) {
        batch.insert(
          OrderConstants.orderItemsTable,
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(
        noResult: true,
      );
    });
  }

  //--------------------------------------------------------------------------
  // READ
  //--------------------------------------------------------------------------

  Future<List<OrderItemModel>> findByOrderId(
    String orderId,
  ) async {
    final database = await db;

    final result = await database.query(
      OrderConstants.orderItemsTable,
      where: '${OrderConstants.orderId} = ?',
      whereArgs: [orderId],
      orderBy: OrderConstants.productName,
    );

    return result
        .map(OrderItemModel.fromMap)
        .toList();
  }

  //--------------------------------------------------------------------------
  // UPDATE
  //--------------------------------------------------------------------------

  Future<void> update(
    OrderItemModel item,
  ) async {
    final database = await db;

    await database.update(
      OrderConstants.orderItemsTable,
      item.toMap(),
      where: '${OrderConstants.id} = ?',
      whereArgs: [item.id],
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
      OrderConstants.orderItemsTable,
      where: '${OrderConstants.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteByOrderId(
    String orderId,
  ) async {
    final database = await db;

    await database.delete(
      OrderConstants.orderItemsTable,
      where: '${OrderConstants.orderId} = ?',
      whereArgs: [orderId],
    );
  }
}