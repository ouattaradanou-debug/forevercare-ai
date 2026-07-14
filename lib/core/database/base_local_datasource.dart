import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// ============================================================================
/// ForeverCare Framework
/// BaseLocalDataSource
/// ============================================================================
///
/// Classe de base de tous les DataSources SQLite.
///
/// Elle fournit un accès unique à la base de données
/// afin d'éviter la duplication du code.
///
/// Exemple :
///
/// class ProductLocalDataSource extends BaseLocalDataSource {
///   ProductLocalDataSource({
///     AppDatabase? database,
///   }) : super(database ?? AppDatabase.instance);
/// }
///
abstract class BaseLocalDataSource {
  const BaseLocalDataSource(this.database);

  /// Instance de la base de données.
  final AppDatabase database;

  /// Accès simplifié à SQLite.
  Future<Database> get db async => database.database;

  /// Exécute une transaction SQLite.
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action,
  ) async {
    final databaseInstance = await db;

    return databaseInstance.transaction(action);
  }

  /// Exécute un batch SQLite.
  Future<List<Object?>> batch(
    void Function(Batch batch) action,
  ) async {
    final databaseInstance = await db;

    final batch = databaseInstance.batch();

    action(batch);

    return batch.commit(
      noResult: false,
      continueOnError: false,
    );
  }
}