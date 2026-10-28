import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ecoleplus/core/clock.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/synced_tables.dart';

/// Toutes les écritures de l'application passent par ici : la ligne est
/// enregistrée sur le téléphone ET ajoutée à la file d'envoi, dans la même
/// transaction. L'interface n'attend jamais le réseau (R3).
class LocalStore {
  new(this.db, this.clock)
    : _tables = {for (final t in syncedTables(db)) t.name: t};

  final AppDatabase db;
  final Clock clock;
  final Map<String, SyncedTable> _tables;

  SyncedTable table(String name) {
    final t = _tables[name];
    if (t == null) throw ArgumentError('Table non synchronisée : $name');
    return t;
  }

  Iterable<SyncedTable> get tables => _tables.values;

  Future<Map<String, dynamic>?> read(
    String tableName,
    Map<String, Object?> key,
  ) async {
    final t = table(tableName);
    final where = key.keys.map((k) => '"$k" = ?').join(' AND ');
    final row = await db
        .customSelect(
          'SELECT * FROM "${t.name}" WHERE $where',
          variables: [for (final v in key.values) Variable(v)],
          readsFrom: {t.info},
        )
        .getSingleOrNull();
    if (row == null) return null;
    final data = await t.info.map(row.data);
    return data.toJson();
  }

  /// Crée ou modifie une ligne. [fields] contient au minimum la clé.
  Future<Map<String, dynamic>> save(
    String tableName,
    Map<String, Object?> fields,
  ) {
    final t = table(tableName);
    return db.transaction(() async {
      final key = t.keyOf(fields);
      final existing = await read(tableName, key);
      final now = clock.nowIso();
      final merged = <String, dynamic>{
        ...?existing,
        ...fields,
        'updated_at': now,
      };
      if (existing == null) merged['created_at'] ??= now;
      await writeLocal(t, merged);
      // Ligne neuve : envoi complet (valeurs par défaut comprises) ; les
      // valeurs données gardent leur forme (un objet JSON reste un objet).
      final payload = existing == null
          ? <String, dynamic>{
              ...(await read(tableName, key))!..remove('synced_at'),
              ...fields,
              'updated_at': now,
            }
          : <String, dynamic>{...key, ...fields, 'updated_at': now};
      await _enqueue(t, key, payload);
      return merged;
    });
  }

  /// Écrit une ligne en local sans l'envoyer (données reçues du serveur, ou
  /// première étape d'une écriture). Les colonnes inconnues du téléphone sont
  /// ignorées ; les colonnes absentes prennent leur valeur par défaut.
  Future<void> writeLocal(SyncedTable t, Map<String, dynamic> row) async {
    final known = {for (final c in t.info.$columns) c.name};
    final entries = row.entries.where((e) => known.contains(e.key)).toList();
    final names = entries.map((e) => '"${e.key}"').join(', ');
    final marks = List.filled(entries.length, '?').join(', ');
    final updates = entries
        .where((e) => !t.keyColumns.contains(e.key))
        .map((e) => '"${e.key}" = excluded."${e.key}"')
        .join(', ');
    final keys = t.keyColumns.map((k) => '"$k"').join(', ');
    await db.customInsert(
      'INSERT INTO "${t.name}" ($names) VALUES ($marks) '
      'ON CONFLICT ($keys) DO '
      '${updates.isEmpty ? 'NOTHING' : 'UPDATE SET $updates'}',
      variables: [for (final e in entries) Variable(_toSql(e.value))],
      updates: {t.info},
    );
  }

  static Object? _toSql(Object? v) => switch (v) {
    final bool b => b ? 1 : 0,
    final Map<String, dynamic> m => jsonEncode(m),
    final List<dynamic> l => jsonEncode(l),
    _ => v,
  };

  Future<void> deleteLocal(SyncedTable t, Map<String, Object?> key) async {
    final where = key.keys.map((k) => '"$k" = ?').join(' AND ');
    await db.customUpdate(
      'DELETE FROM "${t.name}" WHERE $where',
      variables: [for (final v in key.values) Variable(v)],
      updates: {t.info},
      updateKind: UpdateKind.delete,
    );
  }

  Future<void> _enqueue(
    SyncedTable t,
    Map<String, Object?> key,
    Map<String, dynamic> payload,
  ) async {
    final rowKey = jsonEncode(key);
    final pending =
        await (db.select(db.outbox)..where(
              (o) =>
                  o.targetTable.equals(t.name) &
                  o.rowKey.equals(rowKey) &
                  o.status.equals('en_attente'),
            ))
            .getSingleOrNull();
    if (pending == null) {
      await db
          .into(db.outbox)
          .insert(
            OutboxCompanion.insert(
              targetTable: t.name,
              rowKey: rowKey,
              payload: jsonEncode(payload),
              createdAt: clock.nowIso(),
            ),
          );
    } else {
      final mergedPayload = {
        ...(jsonDecode(pending.payload) as Map<String, dynamic>),
        ...payload,
      };
      await (db.update(db.outbox)..where((o) => o.id.equals(pending.id))).write(
        OutboxCompanion(
          payload: Value(jsonEncode(mergedPayload)),
          revision: Value(pending.revision + 1),
        ),
      );
    }
  }

  Future<bool> hasPending(String tableName, String rowKey) async {
    final n =
        await (db.selectOnly(db.outbox)
              ..addColumns([db.outbox.id.count()])
              ..where(
                db.outbox.targetTable.equals(tableName) &
                    db.outbox.rowKey.equals(rowKey) &
                    db.outbox.status.equals('en_attente'),
              ))
            .map((r) => r.read(db.outbox.id.count()))
            .getSingle();
    return (n ?? 0) > 0;
  }

  Stream<int> watchCount(String status) {
    final count = db.outbox.id.count();
    return (db.selectOnly(db.outbox)
          ..addColumns([count])
          ..where(db.outbox.status.equals(status)))
        .map((r) => r.read(count) ?? 0)
        .watchSingle();
  }

  Future<int> pendingCount() => watchCount('en_attente').first;
}
