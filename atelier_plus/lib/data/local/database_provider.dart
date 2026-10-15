import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';

/// Instance unique de la base locale, ouverte au premier accès et
/// conservée pendant toute la durée de vie de l'application.
final baseLocaleProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
