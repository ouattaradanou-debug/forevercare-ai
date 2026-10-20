import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(include: {'tables.drift'})
class AppDatabase extends _$AppDatabase {
  new(super.e);

  /// Base de l'application sur le téléphone.
  factory open() => AppDatabase(driftDatabase(name: 'ecoleplus'));

  @override
  int get schemaVersion => 1;

  /// Efface toutes les données de l'école sur ce téléphone (changement de
  /// compte). Seule l'identité du téléphone est conservée.
  Future<void> clearAll() => transaction(() async {
    for (final table in allTables) {
      if (table.actualTableName != 'device_identity') {
        await delete(table).go();
      }
    }
  });
}
