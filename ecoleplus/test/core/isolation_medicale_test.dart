import 'dart:io';

import 'package:drift/native.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/synced_tables.dart';
import 'package:ecoleplus/features/medical/domain/fiche_medicale.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contrôles automatiques du dossier médico-scolaire (phase 7) : aucune
/// donnée de santé ne peut partir vers l'IA, la recherche globale, les
/// exports, la synchronisation ou le journal d'activité, parce qu'aucun de
/// ces chemins n'a accès au module.
void main() {
  // Seuls ces fichiers peuvent utiliser le module (ses écrans et leurs
  // points d'entrée).
  const autorises = {
    'lib/app/router.dart',
    'lib/features/options/presentation/options_page.dart',
    'lib/features/students/presentation/students_pages.dart',
  };

  test('aucun autre code (IA, recherche, exports, synchro, journal) '
      'n’importe le dossier médico-scolaire', () {
    final fautifs = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final chemin = f.path.replaceAll(r'\', '/');
      if (chemin.startsWith('lib/features/medical/')) continue;
      if (f.readAsStringSync().contains('features/medical/') &&
          !autorises.contains(chemin)) {
        fautifs.add(chemin);
      }
    }
    expect(fautifs, isEmpty);
  });

  test('aucune table du téléphone ne contient de champ de santé ; rien du '
      'module n’est synchronisé', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final colonnes = {
      for (final t in db.allTables)
        for (final c in t.$columns) c.name,
    };
    final sante = {
      for (final (c, _) in [...champsFiche, ...constantes]) c,
      'examen_physique',
      'aptitude',
    };
    expect(colonnes.intersection(sante), isEmpty);
    final synchronisees = {for (final t in syncedTables(db)) t.name};
    for (final t in ['records', 'yearly_exams', 'fitness', 'access_log']) {
      expect(synchronisees, isNot(contains(t)));
    }
    await db.close();
  });

  test('le module de l’IA (phase 12) n’existe pas encore : il devra passer '
      'ce même contrôle', () {
    expect(Directory('lib/features/ia').existsSync(), isFalse);
  });
}
