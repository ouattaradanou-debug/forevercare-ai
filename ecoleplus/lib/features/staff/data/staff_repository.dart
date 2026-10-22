import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:uuid/uuid.dart';

/// Historiques de la fiche enseignant (B3 col. 8 à 11).
enum Historique {
  communes('teacher_postings'),
  interruptions('teacher_interruptions'),
  recompenses('teacher_awards'),
  diplomes('teacher_diplomas');

  new(this.table);
  final String table;
}

/// Fiches du personnel enseignant : lecture réactive, écriture hors ligne.
class StaffRepository {
  new(this.store);

  final LocalStore store;
  static const _uuid = Uuid();

  AppDatabase get db => store.db;

  Stream<List<TeacherRow>> watchTeachers(String schoolId) =>
      (db.select(db.teachers)
            ..where((t) => t.schoolId.equals(schoolId) & t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm.asc(t.lastName),
              (t) => OrderingTerm.asc(t.firstNames),
            ]))
          .watch();

  Stream<TeacherRow?> watchTeacher(String id) => (db.select(
    db.teachers,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<String> createTeacher(
    String schoolId, {
    required String lastName,
    required String firstNames,
    Map<String, Object?> autres = const {},
  }) async {
    final id = _uuid.v4();
    await store.save('teachers', {
      'id': id,
      'school_id': schoolId,
      'last_name': lastName.trim().toUpperCase(),
      'first_names': firstNames.trim(),
      ...autres,
    });
    return id;
  }

  Future<void> updateTeacher(String id, Map<String, Object?> fields) =>
      store.save('teachers', {'id': id, ...fields});

  /// Départ de l'école : la fiche reste (registre B3), marquée « parti ».
  Future<void> setParti(String id, {required bool parti}) => updateTeacher(id, {
    'status': parti ? 'parti' : 'actif',
    'archived_at': parti ? store.clock.nowIso() : null,
  });

  Stream<List<Map<String, dynamic>>> watchHistorique(
    Historique h,
    String teacherId,
  ) {
    final t = store.table(h.table);
    final info = t.info;
    final q = db.customSelect(
      'SELECT * FROM ${info.actualTableName} '
      'WHERE teacher_id = ? AND deleted_at IS NULL '
      'ORDER BY ${_ordre(h)}',
      variables: [Variable.withString(teacherId)],
      readsFrom: {info},
    );
    return q.watch().map((rows) => [for (final r in rows) r.data]);
  }

  static String _ordre(Historique h) => switch (h) {
    Historique.communes => 'sort_order, nominated_on',
    Historique.interruptions => 'starts_on',
    Historique.recompenses => 'awarded_on',
    Historique.diplomes => 'delivered_on',
  };

  Future<void> saveHistorique(
    Historique h, {
    required String schoolId,
    required String teacherId,
    required Map<String, Object?> fields,
    String? id,
  }) => store.save(h.table, {
    'id': id ?? _uuid.v4(),
    'school_id': schoolId,
    'teacher_id': teacherId,
    ...fields,
  });

  Future<void> removeHistorique(Historique h, String id) =>
      store.save(h.table, {'id': id, 'deleted_at': store.clock.nowIso()});

  // ------------------------ Affectation de l'année -----------------------

  Stream<TeacherAssignmentRow?> watchAssignment(
    String teacherId,
    String yearId,
  ) =>
      (db.select(db.teacherYearAssignments)..where(
            (a) =>
                a.teacherId.equals(teacherId) &
                a.schoolYearId.equals(yearId) &
                a.deletedAt.isNull(),
          ))
          .watchSingleOrNull();

  Stream<List<TeacherAssignmentRow>> watchAssignments(String yearId) =>
      (db.select(
            db.teacherYearAssignments,
          )..where((a) => a.schoolYearId.equals(yearId) & a.deletedAt.isNull()))
          .watch();

  Future<void> setAssignment({
    required String schoolId,
    required String yearId,
    required String teacherId,
    required Map<String, Object?> fields,
  }) async {
    final existing =
        await (db.select(db.teacherYearAssignments)..where(
              (a) =>
                  a.teacherId.equals(teacherId) & a.schoolYearId.equals(yearId),
            ))
            .getSingleOrNull();
    await store.save('teacher_year_assignments', {
      'id': existing?.id ?? _uuid.v4(),
      'school_id': schoolId,
      'school_year_id': yearId,
      'teacher_id': teacherId,
      'deleted_at': null,
      ...fields,
    });
  }
}
