import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/constants/client_constants.dart';
import '../models/client_model.dart';

/// DataSource locale des clients.
///
/// Cette classe est la seule autorisée à communiquer
/// directement avec SQLite pour le module Clients.
class ClientLocalDataSource {
  ClientLocalDataSource({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<void> insert(ClientModel client) async {
    final db = await _database.database;

    await db.insert(
      ClientConstants.table,
      client.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(ClientModel client) async {
    final db = await _database.database;

    await db.update(
      ClientConstants.table,
      client.toMap(),
      where: '${ClientConstants.id} = ?',
      whereArgs: [client.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _database.database;

    await db.delete(
      ClientConstants.table,
      where: '${ClientConstants.id} = ?',
      whereArgs: [id],
    );
  }

  Future<ClientModel?> findById(String id) async {
    final db = await _database.database;

    final result = await db.query(
      ClientConstants.table,
      where: '${ClientConstants.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return ClientModel.fromMap(result.first);
  }

  Future<List<ClientModel>> findAll() async {
    final db = await _database.database;

    final result = await db.query(
      ClientConstants.table,
      orderBy: ClientConstants.firstName,
    );

    return result.map(ClientModel.fromMap).toList();
  }
}