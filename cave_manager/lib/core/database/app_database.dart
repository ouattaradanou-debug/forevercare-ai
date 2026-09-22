import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables/local_caves_table.dart';
import 'tables/local_profiles_table.dart';
import 'tables/sync_queue_table.dart';
import 'daos/sync_queue_dao.dart';

part 'app_database.g.dart';

/// Base locale Drift (offline-first). Voir PHASE1.md, section "Règles de
/// synchronisation offline" pour la stratégie générale.
///
/// NOTE POUR LE DÉVELOPPEUR : ce fichier requiert la génération de code
/// (`app_database.g.dart`) via build_runner avant de pouvoir compiler :
///   flutter pub get
///   dart run build_runner build --delete-conflicting-outputs
@DriftDatabase(
  tables: [LocalCaves, LocalProfiles, SyncQueue],
  daos: [SyncQueueDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_ouvrirConnexion());
  AppDatabase.testInMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _ouvrirConnexion() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroids();
    }
    final dossier = await getApplicationDocumentsDirectory();
    final fichier = File(p.join(dossier.path, 'cave_manager.sqlite'));
    return NativeDatabase.createInBackground(fichier);
  });
}
