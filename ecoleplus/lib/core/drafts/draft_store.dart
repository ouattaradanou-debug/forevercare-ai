import 'dart:convert';

import 'package:ecoleplus/core/db/app_database.dart';

/// Brouillons des formulaires, sauvegardés automatiquement sur le téléphone
/// (jamais de mot de passe).
class DraftStore {
  new(this.db);
  final AppDatabase db;

  Future<Map<String, dynamic>> load(String key) async {
    final row = await (db.select(
      db.drafts,
    )..where((d) => d.key.equals(key))).getSingleOrNull();
    return row == null
        ? <String, dynamic>{}
        : jsonDecode(row.payload) as Map<String, dynamic>;
  }

  Future<void> save(String key, Map<String, dynamic> values) => db
      .into(db.drafts)
      .insertOnConflictUpdate(
        DraftsCompanion.insert(
          key: key,
          payload: jsonEncode(values),
          updatedAt: DateTime.now().toUtc().toIso8601String(),
        ),
      );

  Future<void> clear(String key) =>
      (db.delete(db.drafts)..where((d) => d.key.equals(key))).go();
}
