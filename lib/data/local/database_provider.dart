import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Instance unique de la base locale, partagée par toute l'application.
final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((
  ref,
) {
  final AppDatabase base = AppDatabase();
  ref.onDispose(base.close);
  return base;
});
