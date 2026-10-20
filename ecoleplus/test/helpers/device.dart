import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:ecoleplus/core/clock.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/core/sync/sync_engine.dart';

import 'fake_server.dart';

/// Un téléphone simulé : base locale en mémoire, horloge réglable, réseau
/// coupable, relié au serveur simulé.
class TestDevice {
  new(FakeServer server, {DateTime? start})
    : time = start ?? DateTime.utc(2026, 10, 21, 8),
      remote = FakeRemote(server) {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    clock = Clock(source: () => time);
    store = LocalStore(db, clock);
    engine = SyncEngine(store: store, remote: remote, pageSize: 50);
  }

  late final AppDatabase db;
  late final Clock clock;
  late final LocalStore store;
  late final SyncEngine engine;
  final FakeRemote remote;
  DateTime time;

  bool get online => remote.online;
  set online(bool v) => remote.online = v;

  void advance(Duration d) => time = time.add(d);

  Future<void> initSession() => db
      .into(db.localSession)
      .insert(
        LocalSessionCompanion.insert(
          userId: 'u',
          login: 'l',
          membershipId: 'm',
          schoolId: 's',
          role: 'directeur',
          displayName: 'D',
          deviceId: 'd',
          lastSyncAt: const Value(null),
        ),
      );

  Future<void> close() => db.close();
}
