import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:uuid/uuid.dart';

/// Élève avec sa classe de l'année (null : pas encore affecté).
class EleveDansAnnee {
  const new(this.eleve, this.inscription, this.classe);
  final StudentRow eleve;
  final EnrollmentRow? inscription;
  final ClassRow? classe;
}

/// Fiches élèves, inscriptions, parents et registre : écriture hors ligne.
class StudentsRepository {
  new(this.store);

  final LocalStore store;
  static const _uuid = Uuid();

  AppDatabase get db => store.db;

  /// Élèves présents (non archivés) avec leur classe de l'année.
  Stream<List<EleveDansAnnee>> watchEleves(
    String schoolId,
    String yearId, {
    bool avecSortis = false,
  }) {
    final q =
        db.select(db.students).join([
            leftOuterJoin(
              db.enrollments,
              db.enrollments.studentId.equalsExp(db.students.id) &
                  db.enrollments.schoolYearId.equals(yearId) &
                  db.enrollments.deletedAt.isNull() &
                  db.enrollments.endsOn.isNull(),
            ),
            leftOuterJoin(
              db.classes,
              db.classes.id.equalsExp(db.enrollments.classId),
            ),
          ])
          ..where(
            db.students.schoolId.equals(schoolId) &
                db.students.deletedAt.isNull() &
                (avecSortis
                    ? const Constant(true)
                    : db.students.archivedAt.isNull()),
          )
          ..orderBy([
            OrderingTerm.asc(db.students.lastName),
            OrderingTerm.asc(db.students.firstNames),
          ]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          EleveDansAnnee(
            r.readTable(db.students),
            r.readTableOrNull(db.enrollments),
            r.readTableOrNull(db.classes),
          ),
      ],
    );
  }

  Stream<StudentRow?> watchEleve(String id) => (db.select(
    db.students,
  )..where((s) => s.id.equals(id))).watchSingleOrNull();

  Stream<StudentRegistryRow?> watchRegistre(String id) => (db.select(
    db.studentRegistry,
  )..where((s) => s.id.equals(id))).watchSingleOrNull();

  Stream<List<GuardianRow>> watchParents(String studentId) =>
      (db.select(db.guardians)
            ..where((g) => g.studentId.equals(studentId) & g.deletedAt.isNull())
            ..orderBy([(g) => OrderingTerm.asc(g.sortOrder)]))
          .watch();

  /// Parcours de l'élève dans l'école (toutes années).
  Stream<List<(EnrollmentRow, ClassRow?)>> watchParcours(String studentId) {
    final q =
        db.select(db.enrollments).join([
            leftOuterJoin(
              db.classes,
              db.classes.id.equalsExp(db.enrollments.classId),
            ),
          ])
          ..where(
            db.enrollments.studentId.equals(studentId) &
                db.enrollments.deletedAt.isNull(),
          )
          ..orderBy([OrderingTerm.desc(db.enrollments.startsOn)]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          (r.readTable(db.enrollments), r.readTableOrNull(db.classes)),
      ],
    );
  }

  /// Numéro provisoire affiché tant que le serveur n'a pas attribué le
  /// numéro d'ordre définitif (« P-A-0003 » : série du téléphone + compteur).
  Future<String?> _numeroProvisoire() async {
    final session = await db.select(db.localSession).getSingleOrNull();
    final serie = session?.deviceSeries;
    if (serie == null) return null;
    final prefixe = 'P-$serie-';
    final r = await db
        .customSelect(
          'SELECT registry_provisional AS p FROM students '
          'WHERE registry_provisional LIKE ? ',
          variables: [Variable.withString('$prefixe%')],
        )
        .get();
    var max = 0;
    for (final x in r) {
      final n = int.tryParse(x.read<String>('p').substring(prefixe.length));
      if (n != null && n > max) max = n;
    }
    return '$prefixe${(max + 1).toString().padLeft(4, '0')}';
  }

  /// Crée l'élève (nom, prénoms, classe : le strict minimum) et l'inscrit.
  Future<String> creer({
    required String schoolId,
    required String lastName,
    required String firstNames,
    String? sex,
    ClassRow? classe,
    Map<String, Object?> autres = const {},
  }) async {
    final id = _uuid.v4();
    final provisoire = await _numeroProvisoire();
    await db.transaction(() async {
      await store.save('students', {
        'id': id,
        'school_id': schoolId,
        'last_name': lastName.trim().toUpperCase(),
        'first_names': firstNames.trim(),
        'sex': sex,
        'registry_provisional': provisoire,
        'entry_date': store.clock.nowIso().substring(0, 10),
        ...autres,
      });
      if (classe != null) await _inscrire(id, classe);
    });
    return id;
  }

  Future<void> _inscrire(String studentId, ClassRow classe) async {
    final existante =
        await (db.select(db.enrollments)..where(
              (e) =>
                  e.studentId.equals(studentId) & e.classId.equals(classe.id),
            ))
            .getSingleOrNull();
    await store.save('enrollments', {
      'id': existante?.id ?? _uuid.v4(),
      'school_id': classe.schoolId,
      'student_id': studentId,
      'class_id': classe.id,
      'school_year_id': classe.schoolYearId,
      'level_code': classe.levelCode,
      'starts_on': store.clock.nowIso().substring(0, 10),
      'ends_on': null,
      'end_reason': null,
      'deleted_at': null,
    });
  }

  Future<void> modifier(String id, Map<String, Object?> fields) =>
      store.save('students', {'id': id, ...fields});

  /// Champs du registre matricule et de la fiche de scolarité.
  Future<void> modifierRegistre(
    String id,
    String schoolId,
    Map<String, Object?> fields,
  ) => store.save('student_registry', {
    'id': id,
    'school_id': schoolId,
    ...fields,
  });

  /// Changement de classe dans l'année : l'ancienne inscription est close
  /// (l'historique est conservé), la nouvelle commence aujourd'hui.
  Future<void> changerDeClasse(String studentId, ClassRow nouvelle) =>
      db.transaction(() async {
        final aujourdhui = store.clock.nowIso().substring(0, 10);
        final actuelles =
            await (db.select(db.enrollments)..where(
                  (e) =>
                      e.studentId.equals(studentId) &
                      e.schoolYearId.equals(nouvelle.schoolYearId) &
                      e.endsOn.isNull() &
                      e.deletedAt.isNull(),
                ))
                .get();
        for (final e in actuelles) {
          if (e.classId == nouvelle.id) return;
          await store.save('enrollments', {
            'id': e.id,
            'ends_on': aujourdhui,
            'end_reason': 'changement de classe',
          });
        }
        await _inscrire(studentId, nouvelle);
      });

  /// Sortie définitive de l'école : l'élève est archivé, jamais supprimé
  /// (notes, paiements et registre restent intacts).
  Future<void> sortir(
    StudentRow eleve, {
    required String dateSortie,
    String? allantA,
    String? motif,
  }) => db.transaction(() async {
    await modifier(eleve.id, {
      'exit_date': dateSortie,
      'archived_at': store.clock.nowIso(),
    });
    await modifierRegistre(eleve.id, eleve.schoolId, {
      'destination': ?allantA,
      'exit_reason': ?motif,
    });
    final ouvertes =
        await (db.select(db.enrollments)..where(
              (e) =>
                  e.studentId.equals(eleve.id) &
                  e.endsOn.isNull() &
                  e.deletedAt.isNull(),
            ))
            .get();
    for (final e in ouvertes) {
      await store.save('enrollments', {
        'id': e.id,
        'ends_on': dateSortie,
        'end_reason': 'sortie de l’école',
      });
    }
  });

  /// Retour d'un élève sorti par erreur.
  Future<void> reintegrer(String id) =>
      modifier(id, {'exit_date': null, 'archived_at': null});

  Future<void> enregistrerParent(
    String schoolId,
    String studentId, {
    required Map<String, Object?> fields,
    String? id,
  }) => store.save('guardians', {
    'id': id ?? _uuid.v4(),
    'school_id': schoolId,
    'student_id': studentId,
    ...fields,
  });

  Future<void> retirerParent(String id) =>
      store.save('guardians', {'id': id, 'deleted_at': store.clock.nowIso()});
}
