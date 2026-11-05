import 'dart:convert';
import 'dart:io';

import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/db/chiffrement_base.dart';
import 'package:path/path.dart' as p;

/// Sauvegarde : copie complète de la base du téléphone (y compris les
/// éléments pas encore envoyés) dans un seul fichier à garder en lieu sûr,
/// chiffré avec un mot de passe (phase 14). Les données envoyées au serveur
/// sont en plus sauvegardées chaque nuit sur le serveur.
class BackupService {
  new(this.db, this.directory, {this.cle});

  final AppDatabase db;
  final Directory directory;

  /// Clé de la base du téléphone : la copie est déchiffrée pour rester
  /// lisible sur un autre téléphone (voir A4).
  final String? cle;

  /// Mot de passe de sauvegarde : 8 caractères au moins.
  static String? verifierMotDePasse(String m) =>
      m.length < 8 ? 'Au moins 8 caractères.' : null;

  Future<File> createBackup(DateTime now, {required String motDePasse}) async {
    if (verifierMotDePasse(motDePasse) case final e?) {
      throw ArgumentError(e);
    }
    final stamp =
        '${now.year}-${_d(now.month)}-${_d(now.day)}_'
        '${_d(now.hour)}h${_d(now.minute)}';
    await directory.create(recursive: true);
    final file = File(
      p.join(directory.path, 'ecoleplus-sauvegarde-$stamp.ecoleplus'),
    );
    if (file.existsSync()) file.deleteSync();
    await db.customStatement('VACUUM INTO ?', [file.path]);
    proteger(file.path, cle, motDePasse);
    return file;
  }

  static String _d(int n) => n.toString().padLeft(2, '0');
}

/// Contenu utile d'une sauvegarde pour un autre téléphone : les éléments
/// pas encore envoyés (le reste est déjà sur le serveur et revient par la
/// synchronisation).
class ContenuSauvegarde {
  const new({
    required this.schoolId,
    required this.ecole,
    required this.elements,
    required this.photosNonEnvoyees,
  });
  final String schoolId;
  final String ecole;

  /// (table, clé, données) en attente d'envoi.
  final List<(String, Map<String, dynamic>, Map<String, dynamic>)> elements;

  /// Photos ou fichiers non envoyés : leur image n'est pas dans le fichier.
  final int photosNonEnvoyees;
}

/// Lit une sauvegarde (mot de passe) sans rien modifier.
ContenuSauvegarde lireSauvegarde(String chemin, String motDePasse) {
  final db = ouvrirSauvegarde(chemin, motDePasse);
  try {
    final session = db.select('SELECT school_id FROM local_session LIMIT 1');
    if (session.isEmpty) {
      throw const FormatException('Sauvegarde vide (aucune école).');
    }
    final schoolId = session.first['school_id'] as String;
    final ecole = db.select('SELECT name FROM schools WHERE id = ?', [
      schoolId,
    ]);
    final l = db.select(
      'SELECT target_table, row_key, payload FROM outbox '
      "WHERE status = 'en_attente' ORDER BY id",
    );
    return ContenuSauvegarde(
      schoolId: schoolId,
      ecole: ecole.isEmpty ? '' : ecole.first['name'] as String,
      elements: [
        for (final r in l)
          (
            r['target_table'] as String,
            Map<String, dynamic>.from(
              jsonDecode(r['row_key'] as String) as Map,
            ),
            Map<String, dynamic>.from(
              jsonDecode(r['payload'] as String) as Map,
            ),
          ),
      ],
      photosNonEnvoyees:
          db.select('SELECT count(*) AS n FROM file_uploads').first['n'] as int,
    );
  } finally {
    db.close();
  }
}
