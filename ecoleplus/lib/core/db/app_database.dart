import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:ecoleplus/core/db/chiffrement_base.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

part 'app_database.g.dart';

@DriftDatabase(include: {'tables.drift'})
class AppDatabase extends _$AppDatabase {
  new(super.e);

  /// Base de l'application sur le téléphone, chiffrée avec [cle] (A10).
  /// Une base en clair d'une version précédente est chiffrée au passage.
  static Future<AppDatabase> ouvrir(String cle) async {
    final dossier = await getApplicationDocumentsDirectory();
    final chemin = p.join(dossier.path, 'ecoleplus.sqlite');
    if (!_lisible(chemin, cle)) {
      // Clé perdue (téléphone réinitialisé, fichier restauré d'ailleurs) :
      // la base est illisible ; on repart de zéro, les données revenant du
      // serveur à la connexion.
      for (final suffixe in ['', '-wal', '-shm', '-journal']) {
        final f = File('$chemin$suffixe');
        if (f.existsSync()) f.deleteSync();
      }
    }
    return AppDatabase(
      driftDatabase(
        name: 'ecoleplus',
        native: DriftNativeOptions(
          databasePath: () async => chemin,
          setup: (db) => appliquerCle(db, cle),
        ),
      ),
    );
  }

  static bool _lisible(String chemin, String cle) {
    if (!File(chemin).existsSync()) return true;
    try {
      chiffrerSiNecessaire(chemin, cle);
      final db = sqlite3.open(chemin);
      try {
        appliquerCle(db, cle);
        return true;
      } finally {
        db.close();
      }
    } on Object {
      return false;
    }
  }

  @override
  int get schemaVersion => 3;

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
      if (from < 3) {
        // Phase 2 : personnel, classes, élèves, registres.
        for (final t in <TableInfo<Table, dynamic>>[
          levels,
          teachers,
          teacherPostings,
          teacherInterruptions,
          teacherAwards,
          teacherDiplomas,
          classes,
          teacherYearAssignments,
          students,
          studentRegistry,
          guardians,
          enrollments,
        ]) {
          await m.createTable(t);
        }
        await m.createIndex(enrollmentsClass);
        await m.createIndex(enrollmentsStudent);
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
