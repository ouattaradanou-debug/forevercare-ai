import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(include: {'tables.drift'})
class AppDatabase extends _$AppDatabase {
  new(super.e);

  /// Base de l'application sur le téléphone.
  factory open() => AppDatabase(driftDatabase(name: 'ecoleplus'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Phase 1 (compléments) : téléphones, journal, verrouillage.
        await m.createTable(devices);
        await m.createTable(auditLog);
        await m.createTable(appLock);
        await m.addColumn(deviceIdentity, deviceIdentity.notice);
        await m.addColumn(localSession, localSession.journalSeenAt);
      }
    },
  );

  /// Efface toutes les données de l'école sur ce téléphone (changement de
  /// compte). Seule l'identité du téléphone est conservée.
  Future<void> clearAll() => transaction(() async {
    for (final table in allTables) {
      if (table.actualTableName != 'device_identity') {
        // Le verrou appartient à la personne : effacé avec ses données.
        await delete(table).go();
      }
    }
  });
}
