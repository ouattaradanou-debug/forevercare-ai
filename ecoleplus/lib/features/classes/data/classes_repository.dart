import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:uuid/uuid.dart';

/// Effectif d'une classe (élèves inscrits et non sortis).
class Effectif {
  const new({this.filles = 0, this.garcons = 0, this.autres = 0});
  final int filles;
  final int garcons;

  /// Sexe non renseigné.
  final int autres;
  int get total => filles + garcons + autres;

  Effectif operator +(Effectif o) => Effectif(
    filles: filles + o.filles,
    garcons: garcons + o.garcons,
    autres: autres + o.autres,
  );
}

class ClassesRepository {
  new(this.store);

  final LocalStore store;
  static const _uuid = Uuid();

  AppDatabase get db => store.db;

  Stream<List<LevelRow>> watchLevels() => (db.select(
    db.levels,
  )..orderBy([(l) => OrderingTerm.asc(l.sortOrder)])).watch();

  /// Classes d'une année, dans l'ordre des niveaux puis des noms.
  Stream<List<ClassRow>> watchClasses(String yearId) {
    final q =
        db.select(db.classes).join([
            leftOuterJoin(
              db.levels,
              db.levels.code.equalsExp(db.classes.levelCode),
            ),
          ])
          ..where(
            db.classes.schoolYearId.equals(yearId) &
                db.classes.deletedAt.isNull(),
          )
          ..orderBy([
            OrderingTerm.asc(db.levels.sortOrder),
            OrderingTerm.asc(db.classes.name),
          ]);
    return q.watch().map((r) => [for (final x in r) x.readTable(db.classes)]);
  }

  Stream<ClassRow?> watchClass(String id) => (db.select(
    db.classes,
  )..where((c) => c.id.equals(id))).watchSingleOrNull();

  Future<String> createClass({
    required String schoolId,
    required String yearId,
    required String levelCode,
    required String name,
  }) async {
    final nom = name.trim();
    final doublon =
        await (db.select(db.classes)..where(
              (c) =>
                  c.schoolYearId.equals(yearId) &
                  c.name.equals(nom) &
                  c.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (doublon != null) {
      throw UserMessage('Une classe « $nom » existe déjà cette année.');
    }
    final id = _uuid.v4();
    await store.save('classes', {
      'id': id,
      'school_id': schoolId,
      'school_year_id': yearId,
      'level_code': levelCode,
      'name': nom,
    });
    return id;
  }

  Future<void> updateClass(String id, Map<String, Object?> fields) =>
      store.save('classes', {'id': id, ...fields});

  /// Effectifs par classe (élèves inscrits, non sortis, non archivés).
  Stream<Map<String, Effectif>> watchEffectifs(String yearId) {
    final q = db.customSelect(
      'SELECT e.class_id AS classe, s.sex AS sexe, count(*) AS n '
      'FROM enrollments e JOIN students s ON s.id = e.student_id '
      'WHERE e.school_year_id = ? AND e.deleted_at IS NULL '
      'AND e.ends_on IS NULL AND s.deleted_at IS NULL '
      'AND s.archived_at IS NULL '
      'GROUP BY e.class_id, s.sex',
      variables: [Variable.withString(yearId)],
      readsFrom: {db.enrollments, db.students},
    );
    return q.watch().map((rows) {
      final out = <String, Effectif>{};
      for (final r in rows) {
        final classe = r.read<String>('classe');
        final n = r.read<int>('n');
        final e = switch (r.readNullable<String>('sexe')) {
          'F' => Effectif(filles: n),
          'M' => Effectif(garcons: n),
          _ => Effectif(autres: n),
        };
        out[classe] = (out[classe] ?? const Effectif()) + e;
      }
      return out;
    });
  }
}
