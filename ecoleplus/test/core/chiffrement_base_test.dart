import 'dart:io';

import 'package:ecoleplus/core/db/chiffrement_base.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory dossier;
  setUp(() => dossier = Directory.systemTemp.createTempSync('base-'));
  tearDown(() => dossier.deleteSync(recursive: true));

  const cle =
      '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';

  test('SQLite3MultipleCiphers est bien la bibliothèque utilisée', () {
    final db = sqlite3.openInMemory();
    expect(db.select('PRAGMA cipher').first.values.first, isNotNull);
    db.close();
  });

  test('base en clair d’une version précédente : chiffrée sur place, '
      'données conservées', () {
    final chemin = '${dossier.path}/ecoleplus.sqlite';
    sqlite3.open(chemin)
      ..execute('create table t (x text)')
      ..execute("insert into t values ('Élève Test')")
      ..close();
    expect(
      File(chemin).readAsBytesSync().take(15),
      'SQLite format 3'.codeUnits,
    );

    chiffrerSiNecessaire(chemin, cle);
    expect(
      File(chemin).readAsBytesSync().take(15),
      isNot('SQLite format 3'.codeUnits),
      reason: 'le fichier ne doit plus être lisible tel quel',
    );
    final sansCle = sqlite3.open(chemin);
    expect(
      () => sansCle.select('select * from t'),
      throwsA(isA<SqliteException>()),
    );
    sansCle.close();

    final avecCle = sqlite3.open(chemin);
    appliquerCle(avecCle, cle);
    expect(avecCle.select('select x from t').single['x'], 'Élève Test');
    avecCle.close();

    // Deuxième ouverture : rien à refaire.
    chiffrerSiNecessaire(chemin, cle);
    final encore = sqlite3.open(chemin);
    appliquerCle(encore, cle);
    expect(encore.select('select count(*) n from t').single['n'], 1);
    encore.close();
  });

  test('mauvaise clé : refus clair', () {
    final chemin = '${dossier.path}/b.sqlite';
    chiffrerSiNecessaire(chemin, cle);
    final db = sqlite3.open(chemin);
    appliquerCle(db, cle);
    db
      ..execute('create table t (x)')
      ..close();
    final autre = sqlite3.open(chemin);
    expect(() => appliquerCle(autre, 'ff' * 32), throwsA(isA<StateError>()));
    autre.close();
  });

  test('copie de sauvegarde (VACUUM INTO) : lisible sans la clé du '
      'téléphone', () {
    final chemin = '${dossier.path}/c.sqlite';
    final copie = '${dossier.path}/copie.sqlite';
    final db = sqlite3.open(chemin);
    appliquerCle(db, cle);
    db
      ..execute('create table t (x)')
      ..execute("insert into t values ('y')")
      ..execute("VACUUM INTO '$copie'")
      ..close();
    dechiffrerCopie(copie, cle);
    expect(File(copie).readAsBytesSync().take(15), 'SQLite format 3'.codeUnits);
    final lue = sqlite3.open(copie);
    expect(lue.select('select x from t').single['x'], 'y');
    lue.close();
  });

  test('nouvelle clé : 64 caractères hexadécimaux, toujours différente', () {
    final a = nouvelleCleBase();
    expect(a, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(nouvelleCleBase(), isNot(a));
  });
}
