import 'dart:io';
import 'dart:math';

import 'package:sqlite3/common.dart' show CommonDatabase;
import 'package:sqlite3/sqlite3.dart';

/// Base du téléphone chiffrée (A10) avec SQLite3MultipleCiphers. La clé
/// (256 bits, tirée au hasard) est gardée dans le coffre du système
/// (Android Keystore) ; elle n'est jamais envoyée au serveur.

String nouvelleCleBase() {
  final r = Random.secure();
  return [
    for (var i = 0; i < 32; i++)
      r.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}

/// À appeler juste après l'ouverture, avant toute autre requête.
void appliquerCle(CommonDatabase db, String cle) {
  db.execute("PRAGMA hexkey = '$cle'");
  try {
    db.select('SELECT count(*) FROM sqlite_master');
  } on SqliteException {
    throw StateError('Clé de la base du téléphone incorrecte.');
  }
}

/// Une base créée par une version précédente (en clair) est chiffrée sur
/// place, sans perte : rien n'est à refaire ensuite.
void chiffrerSiNecessaire(String chemin, String cle) {
  final fichier = File(chemin);
  if (!fichier.existsSync() || fichier.lengthSync() < 16) return;
  final acces = fichier.openSync();
  final entete = acces.readSync(16);
  acces.closeSync();
  if (String.fromCharCodes(entete.take(15)) != 'SQLite format 3') return;
  final db = sqlite3.open(chemin);
  try {
    // Le chiffrement sur place exige le journal classique (pas de WAL).
    db
      ..execute('PRAGMA wal_checkpoint(TRUNCATE)')
      ..execute('PRAGMA journal_mode = DELETE')
      ..execute("PRAGMA hexrekey = '$cle'");
  } finally {
    db.close();
  }
}

/// Le fichier de sauvegarde ne doit pas dépendre de la clé de CE téléphone
/// (sinon il serait illisible sur un autre) : il est déchiffré après la
/// copie. Sa protection par un code du directeur est l'évolution A4 (V2).
void dechiffrerCopie(String chemin, String cle) {
  final db = sqlite3.open(chemin);
  try {
    appliquerCle(db, cle);
    db.execute("PRAGMA rekey = ''");
  } finally {
    db.close();
  }
}
