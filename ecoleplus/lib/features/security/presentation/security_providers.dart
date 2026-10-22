import 'package:drift/drift.dart';
import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final devicesProvider = StreamProvider<List<DeviceRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.devices)..orderBy([
        (d) => OrderingTerm.asc(d.revokedAt.isNotNull()),
        (d) => OrderingTerm.desc(d.lastSyncAt),
      ]))
      .watch();
});

final journalProvider = StreamProvider<List<AuditRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.auditLog)
        ..orderBy([(a) => OrderingTerm.desc(a.occurredAt)])
        ..limit(300))
      .watch();
});

/// Noms des personnes de l'école, par identifiant de compte.
final namesByUserProvider = StreamProvider<Map<String, String>>((ref) {
  final db = ref.watch(databaseProvider);
  return db
      .select(db.memberships)
      .watch()
      .map((rows) => {for (final m in rows) m.userId: m.displayName});
});

/// (nombre d'éléments en attente, date du plus ancien) pour l'alerte.
final pendingInfoProvider = StreamProvider<(int, DateTime?)>((ref) {
  final db = ref.watch(databaseProvider);
  final count = db.outbox.id.count();
  final oldest = db.outbox.createdAt.min();
  return (db.selectOnly(db.outbox)
        ..addColumns([count, oldest])
        ..where(db.outbox.status.equals('en_attente')))
      .map((r) {
        final o = r.read(oldest);
        return (r.read(count) ?? 0, o == null ? null : DateTime.parse(o));
      })
      .watchSingle();
});

/// Question secrète déjà choisie ? (null si on ne sait pas : hors ligne).
final hasRecoveryQuestionProvider = FutureProvider<bool?>((ref) async {
  ref.watch(sessionProvider);
  try {
    return await ref.watch(authApiProvider).hasRecoveryQuestion();
  } on Object {
    return null;
  }
});

/// Période de composition (H23) : une composition datée des 7 derniers jours
/// ou des 3 prochains, ou des notes pas encore envoyées. L'alerte de
/// synchronisation se déclenche alors après 1 jour au lieu de 3.
final periodeCompositionProvider = StreamProvider<bool>((ref) {
  final db = ref.watch(databaseProvider);
  final auj = DateTime.now();
  String jour(DateTime d) => d.toIso8601String().substring(0, 10);
  final du = jour(auj.subtract(const Duration(days: 7)));
  final au = jour(auj.add(const Duration(days: 3)));
  final compositions = db.assessments.id.count();
  final notes = db.outbox.id.count();
  Future<bool> calculer() async {
    final c =
        await (db.selectOnly(db.assessments)
              ..addColumns([compositions])
              ..where(
                db.assessments.deletedAt.isNull() &
                    db.assessments.heldOn.isBetweenValues(du, au),
              ))
            .map((r) => r.read(compositions) ?? 0)
            .getSingle();
    if (c > 0) return true;
    final n =
        await (db.selectOnly(db.outbox)
              ..addColumns([notes])
              ..where(
                db.outbox.status.equals('en_attente') &
                    db.outbox.targetTable.equals('grades'),
              ))
            .map((r) => r.read(notes) ?? 0)
            .getSingle();
    return n > 0;
  }

  Stream<bool> suivre() async* {
    yield await calculer();
    await for (final _ in db.tableUpdates(
      TableUpdateQuery.onAllTables([db.assessments, db.outbox]),
    )) {
      yield await calculer();
    }
  }

  return suivre();
});
