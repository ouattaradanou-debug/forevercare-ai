import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'constants/client_constants.dart';
import 'constants/database_constants.dart';
import 'constants/product_constants.dart';

/// ============================================================================
/// ForeverCare AI
/// Base de données SQLite
/// ============================================================================
///
/// Singleton responsable de :
///
/// • ouvrir la base
/// • créer les tables
/// • gérer les migrations
/// • fournir une instance unique
///
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  /// Retourne l'unique instance SQLite.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();

    return _database!;
  }

  Future<Database> _openDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();

    final path = join(
      documentsDirectory.path,
      DatabaseConstants.databaseName,
    );

    return openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Création de la base.
  Future<void> _onCreate(Database db, int version) async {
    await _createClientsTable(db);
    await _createProductsTable(db);
  }

  Future<void> _createClientsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${ClientConstants.table} (
        ${ClientConstants.id} TEXT PRIMARY KEY,
        ${ClientConstants.firstName} TEXT NOT NULL,
        ${ClientConstants.lastName} TEXT NOT NULL,
        ${ClientConstants.phone} TEXT NOT NULL,
        ${ClientConstants.email} TEXT,
        ${ClientConstants.gender} TEXT,
        ${ClientConstants.birthDate} TEXT,
        ${ClientConstants.createdAt} TEXT NOT NULL
      );
    ''');
  }

  Future<void> _createProductsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${ProductConstants.table} (
        ${ProductConstants.id} TEXT PRIMARY KEY,
        ${ProductConstants.code} TEXT NOT NULL,
        ${ProductConstants.name} TEXT NOT NULL,
        ${ProductConstants.category} TEXT NOT NULL,
        ${ProductConstants.description} TEXT,
        ${ProductConstants.purchasePrice} REAL NOT NULL,
        ${ProductConstants.salePrice} REAL NOT NULL,
        ${ProductConstants.stock} INTEGER NOT NULL,
        ${ProductConstants.alertStock} INTEGER NOT NULL,
        ${ProductConstants.isActive} INTEGER NOT NULL,
        ${ProductConstants.createdAt} TEXT NOT NULL,
        ${ProductConstants.updatedAt} TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE INDEX idx_products_name
      ON ${ProductConstants.table} (${ProductConstants.name});
    ''');

    await db.execute('''
      CREATE INDEX idx_products_code
      ON ${ProductConstants.table} (${ProductConstants.code});
    ''');
  }

  /// Futures migrations.
  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Version 2 : ajout du module Produits.
    if (oldVersion < 2) {
      await _createProductsTable(db);
    }
  }

  /// Fermeture propre.
  Future<void> close() async {
    final db = _database;

    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}