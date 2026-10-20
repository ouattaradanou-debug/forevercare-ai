import 'dart:io';

import 'package:ecoleplus/core/db/app_database.dart';
import 'package:path/path.dart' as p;

/// Sauvegarde : copie complète de la base du téléphone (y compris les
/// éléments pas encore envoyés) dans un seul fichier à garder en lieu sûr.
/// Les données envoyées au serveur sont en plus sauvegardées par Supabase.
class BackupService {
  new(this.db, this.directory);

  final AppDatabase db;
  final Directory directory;

  Future<File> createBackup(DateTime now) async {
    final stamp =
        '${now.year}-${_d(now.month)}-${_d(now.day)}_'
        '${_d(now.hour)}h${_d(now.minute)}';
    await directory.create(recursive: true);
    final file = File(
      p.join(directory.path, 'ecoleplus-sauvegarde-$stamp.sqlite'),
    );
    if (file.existsSync()) file.deleteSync();
    await db.customStatement('VACUUM INTO ?', [file.path]);
    return file;
  }

  static String _d(int n) => n.toString().padLeft(2, '0');
}
