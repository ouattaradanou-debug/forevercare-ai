import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ecoleplus/core/clock.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/pilotage/data/pilotage_repository.dart';
import 'package:ecoleplus/features/pilotage/domain/absences.dart';
import 'package:ecoleplus/features/pilotage/domain/recherche.dart';
import 'package:ecoleplus/features/students/data/students_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mesures « grande école » : 1 000 élèves, 20 classes, 180 jours d'appel
/// (180 000 présences). Les temps sont écrits dans la sortie du test et
/// repris dans docs/PERFORMANCE.md.
void main() {
  test('grande école : liste des élèves, statistiques d’absences et '
      'recherche restent rapides', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase(NativeDatabase.memory());
    const ecole = 's';
    const annee = 'a';
    final debut = DateTime.utc(2025, 10);
    await db.batch((b) {
      b.insert(
        db.schools,
        SchoolsCompanion.insert(id: ecole, name: 'Grande École', updatedAt: ''),
      );
      for (var c = 0; c < 20; c++) {
        b.insert(
          db.classes,
          ClassesCompanion.insert(
            id: 'c$c',
            schoolId: ecole,
            schoolYearId: annee,
            levelCode: 'CM1',
            name: 'Classe $c',
            updatedAt: '',
          ),
        );
      }
      for (var i = 0; i < 1000; i++) {
        b
          ..insert(
            db.students,
            StudentsCompanion.insert(
              id: 'e$i',
              schoolId: ecole,
              lastName: 'NOM$i',
              firstNames: i.isEven ? 'Aïcha' : 'Boukary',
              sex: Value(i.isEven ? 'F' : 'M'),
              updatedAt: '',
            ),
          )
          ..insert(
            db.enrollments,
            EnrollmentsCompanion.insert(
              id: 'i$i',
              schoolId: ecole,
              studentId: 'e$i',
              classId: 'c${i % 20}',
              schoolYearId: annee,
              levelCode: 'CM1',
              updatedAt: '',
            ),
          );
      }
    });
    await db.batch((b) {
      for (var j = 0; j < 180; j++) {
        final jour = debut
            .add(Duration(days: j))
            .toIso8601String()
            .substring(0, 10);
        for (var i = 0; i < 1000; i++) {
          b.insert(
            db.attendance,
            AttendanceCompanion.insert(
              id: 'p$i-$j',
              schoolId: ecole,
              classId: 'c${i % 20}',
              studentId: 'e$i',
              day: jour,
              status: (i + j) % 23 == 0 ? 'absent' : 'present',
              updatedAt: '',
            ),
          );
        }
      }
    });
    final store = LocalStore(db, Clock());
    final mesures = <String, int>{};
    Future<T> chrono<T>(String nom, Future<T> Function() f) async {
      final s = Stopwatch()..start();
      final r = await f();
      mesures[nom] = s.elapsedMilliseconds;
      return r;
    }

    final eleves = await chrono(
      'liste des 1 000 élèves',
      () => StudentsRepository(store).watchEleves(ecole, annee).first,
    );
    expect(eleves, hasLength(1000));
    final repo = PilotageRepository(store);
    final presences = await chrono(
      'lecture des 180 000 présences (ancienne méthode)',
      () => repo.watchPresences(ecole).first,
    );
    expect(presences, hasLength(180000));
    final duJour = await chrono(
      'présences du jour (accueil, notifications)',
      () => repo.watchPresencesPeriode(ecole, '2026-03-02', '2026-03-02').first,
    );
    expect(duJour, hasLength(1000));
    final totaux = await chrono(
      'totaux de l’année calculés par la base',
      () => repo.watchTotaux(ecole, '2025-09-01', '2026-06-30').first,
    );
    final classes = totaux.parClasse([
      for (var c = 0; c < 20; c++) ('c$c', 'Classe $c', 50),
    ]);
    expect(
      classes.fold<int>(0, (s, c) => s + c.absences),
      presences.where((a) => a.status == 'absent').length,
      reason: 'mêmes totaux que le calcul ligne à ligne',
    );
    final stats = await chrono('statistiques de l’année par classe', () async {
      return absencesParClasse(
        dansPeriode(presences, '2025-09-01', '2026-06-30'),
        [for (var c = 0; c < 20; c++) ('c$c', 'Classe $c', 50)],
      );
    });
    expect(stats.fold<int>(0, (s, c) => s + c.absences), greaterThan(7000));
    final parEleve = await chrono('élèves les plus absents', () async {
      return absencesParEleve(presences, {
        for (final e in eleves) e.eleve.id: (e.eleve.lastName, ''),
      });
    });
    expect(parEleve, isNotEmpty);
    final trouves = await chrono('recherche « aich »', () async {
      return [
        for (final e in eleves)
          if (correspond('aich', [e.eleve.lastName, e.eleve.firstNames])) e,
      ];
    });
    expect(trouves, hasLength(500));

    final texte = [for (final e in mesures.entries) '${e.key}: ${e.value} ms']
        .join(' | ');
    // Mesures affichées pour être reprises dans PERFORMANCE.md.
    // ignore: avoid_print
    print('MESURES $texte');
    // Ordinateur d'intégration : large marge pour un téléphone d'entrée de
    // gamme (5 à 10 fois plus lent).
    expect(mesures['liste des 1 000 élèves'], lessThan(1500));
    expect(
      mesures['présences du jour (accueil, notifications)'],
      lessThan(300),
    );
    expect(mesures['totaux de l’année calculés par la base'], lessThan(1500));
    expect(mesures['recherche « aich »'], lessThan(300));
    await db.close();
  }, timeout: const Timeout(Duration(minutes: 3)));
}
