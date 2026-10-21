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
