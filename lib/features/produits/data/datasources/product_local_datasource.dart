import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/constants/product_constants.dart';
import '../models/product_model.dart';

/// DataSource locale des produits.
///
/// Cette classe est la seule autorisée à communiquer
/// directement avec SQLite pour le module Produits.
class ProductLocalDataSource {
  ProductLocalDataSource({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<void> insert(ProductModel product) async {
    final db = await _database.database;

    await db.insert(
      ProductConstants.table,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(ProductModel product) async {
    final db = await _database.database;

    await db.update(
      ProductConstants.table,
      product.toMap(),
      where: '${ProductConstants.id} = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _database.database;

    await db.delete(
      ProductConstants.table,
      where: '${ProductConstants.id} = ?',
      whereArgs: [id],
    );
  }

  Future<ProductModel?> findById(String id) async {
    final db = await _database.database;

    final result = await db.query(
      ProductConstants.table,
      where: '${ProductConstants.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return ProductModel.fromMap(result.first);
  }

  Future<List<ProductModel>> findAll() async {
    final db = await _database.database;

    final result = await db.query(
      ProductConstants.table,
      orderBy: ProductConstants.name,
    );

    return result.map(ProductModel.fromMap).toList();
  }

  //--------------------------------------------------------------------------
  // UPDATE STOCK
  //--------------------------------------------------------------------------

  /// Met à jour uniquement le stock d'un produit.
  Future<void> updateStock(
    String productId,
    int newStock,
  ) async {
    final db = await _database.database;

    await db.update(
      ProductConstants.table,
      {
        ProductConstants.stock: newStock,
        ProductConstants.updatedAt:
            DateTime.now().toIso8601String(),
      },
      where: '${ProductConstants.id} = ?',
      whereArgs: [productId],
    );
  }
}