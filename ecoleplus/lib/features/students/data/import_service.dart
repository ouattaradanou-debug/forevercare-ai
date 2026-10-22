import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/import/analyse_import.dart';
import 'package:ecoleplus/core/import/tableur.dart';
import 'package:ecoleplus/features/staff/data/staff_repository.dart';
import 'package:ecoleplus/features/staff/domain/import_enseignants.dart';
import 'package:ecoleplus/features/students/data/students_repository.dart';

/// Enregistre les lignes valides d'un import (hors ligne : envoi au serveur
/// à la prochaine synchronisation). Renvoie le nombre de fiches créées.
Future<int> importerEleves(
  StudentsRepository repo,
  AnalyseImport analyse, {
  required String schoolId,
  required List<ClassRow> classes,
}) async {
  final parNom = {for (final c in classes) normaliser(c.name): c};
  var n = 0;
  await repo.db.transaction(() async {
    for (final l in analyse.valides) {
      final numero = l['numero'] == null
          ? null
          : int.parse(l['numero']!.replaceAll('.0', ''));
      final id = await repo.creer(
        schoolId: schoolId,
        lastName: l['nom']!,
        firstNames: l['prenoms']!,
        sex: sexeDeCellule(l['sexe']),
        classe: l['classe'] == null ? null : parNom[normaliser(l['classe']!)],
        autres: {
          'birth_date': dateDeCellule(l['naissance']),
          'birth_place': l['lieu'],
          'student_code': l['identifiant'],
          'domicile': l['domicile'],
          'entry_date': ?dateDeCellule(l['entree']),
          // Reprise d'un registre papier : le numéro saisi est conservé.
          if (numero != null) ...{
            'registry_number': numero,
            'registry_provisional': null,
          },
        },
      );
      if (l['parent'] != null) {
        await repo.enregistrerParent(
          schoolId,
          id,
          fields: {
            'relation': 'tuteur',
            'full_name': l['parent'],
            'profession': l['profession'],
            'domicile': l['domicile'],
            'phone': l['telephone'],
          },
        );
      }
      n++;
    }
  });
  return n;
}

Future<int> importerEnseignants(
  StaffRepository repo,
  AnalyseImport analyse, {
  required String schoolId,
  required String? yearId,
  required List<ClassRow> classes,
}) async {
  final parNom = {for (final c in classes) normaliser(c.name): c};
  var n = 0;
  await repo.db.transaction(() async {
    for (final l in analyse.valides) {
      final id = await repo.createTeacher(
        schoolId,
        lastName: l['nom']!,
        firstNames: l['prenoms']!,
        autres: {
          'sex': sexeDeCellule(l['sexe']),
          'matricule': l['matricule'],
          'phone': l['telephone'],
          'birth_date': dateDeCellule(l['naissance']),
          'birth_place': l['lieu'],
          'emploi': l['emploi'],
          'categorie': l['categorie'],
          'echelon': l['echelon'],
          'tenure_status': tsDeCellule(l['ts']),
        },
      );
      final classe = l['classe'] == null
          ? null
          : parNom[normaliser(l['classe']!)];
      if (yearId != null && (classe != null || l['fonction'] != null)) {
        await repo.setAssignment(
          schoolId: schoolId,
          yearId: yearId,
          teacherId: id,
          fields: {'class_id': classe?.id, 'fonction': l['fonction']},
        );
      }
      n++;
    }
  });
  return n;
}
