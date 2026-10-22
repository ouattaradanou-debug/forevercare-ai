import 'package:drift/native.dart';
import 'package:ecoleplus/core/clock.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/import/analyse_import.dart';
import 'package:ecoleplus/core/import/tableur.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/staff/data/staff_repository.dart';
import 'package:ecoleplus/features/staff/domain/import_enseignants.dart';
import 'package:ecoleplus/features/students/data/import_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/xlsx.dart';

void main() {
  test('import enseignants : matricule en double écarté, T/S reconnu, '
      'classe tenue affectée', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final store = LocalStore(db, Clock());
    const classe = ClassRow(
      id: 'c-cm1',
      schoolId: 'ecole',
      schoolYearId: 'annee',
      levelCode: 'CM1',
      name: 'CM1 A',
      updatedAt: '2026-10-01T00:00:00Z',
    );
    final lignes = lireTableur(
      fabriquerXlsx([
        ['Matricule', 'Nom', 'Prénoms', 'Sexe', 'T/S', 'Classe tenue'],
        ['MAT-1', 'ENSEIGNANT', 'Trois', 'H', 'Titulaire', 'CM1 A'],
        ['MAT-1', 'AUTRE', 'Nom', 'F', 'S'],
        ['MAT-2', 'ENSEIGNANT', 'Quatre', 'F', 'Contractuel'],
      ]),
    );
    final a = analyserImport(
      lignes,
      colonnes: colonnesEnseignants,
      valider: validerEnseignant({'cm1a'}),
      cleDoublon: cleDoublonEnseignant,
    );
    expect(a.valides.length, 1);
    expect(a.doublons.single.toString(), contains('ligne 2'));
    expect(
      a.erreurs.single.toString(),
      'Ligne 4 : « Contractuel » : T (titulaire) ou S (stagiaire) attendu',
    );

    final n = await importerEnseignants(
      StaffRepository(store),
      a,
      schoolId: 'ecole',
      yearId: 'annee',
      classes: [classe],
    );
    expect(n, 1);
    final t = await db.select(db.teachers).getSingle();
    expect(
      (t.lastName, t.sex, t.tenureStatus, t.matricule),
      ('ENSEIGNANT', 'M', 'T', 'MAT-1'),
    );
    final aff = await db.select(db.teacherYearAssignments).getSingle();
    expect(aff.classId, 'c-cm1');
    expect(await store.pendingCount(), 2, reason: 'envoyé à la synchro');
  });
}
