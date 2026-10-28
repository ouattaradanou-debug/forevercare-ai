import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/documents/data/documents_repository.dart';
import 'package:ecoleplus/features/forms/domain/donnees_formulaires.dart';
import 'package:ecoleplus/features/maternelle/domain/maternelle.dart';
import 'package:uuid/uuid.dart';

/// Maternelle (module 8) : domaines, niveaux qualitatifs, trimestres,
/// évaluations, livrets et présences. Identifiants déterministes quand deux
/// téléphones hors ligne pourraient créer la même chose.
class MaternelleRepository {
  new(this.store);

  final LocalStore store;
  AppDatabase get db => store.db;

  static const _uuid = Uuid();
  static String _id(String cle) =>
      _uuid.v5(Namespace.url.value, 'ecoleplus:maternelle:$cle');

  static String idDomaineParDefaut(String schoolId, String nom) =>
      _id('$schoolId:domaine:$nom');
  static String idNiveau(String schoolId, String code) =>
      _id('$schoolId:niveau:$code');
  static String idPeriode(String classId, int trimestre) =>
      _id('$classId:trimestre:$trimestre');
  static String idEvaluation(
    String periodId,
    String studentId,
    String domainId,
  ) => _id('$periodId:$studentId:$domainId');
  static String idLivret(String periodId, String studentId) =>
      _id('$periodId:$studentId:livret');
  static String idPresence(String studentId, String day) =>
      _id('$studentId:$day');

  // --------------------------- Réglages ---------------------------

  Stream<List<LearningDomainRow>> watchDomaines(String schoolId) =>
      (db.select(db.learningDomains)
            ..where(
              (d) =>
                  d.schoolId.equals(schoolId) &
                  d.deletedAt.isNull() &
                  d.active.equals(true),
            )
            ..orderBy([
              (d) => OrderingTerm.asc(d.sortOrder),
              (d) => OrderingTerm.asc(d.name),
            ]))
          .watch();

  Stream<List<NiveauQualitatif>> watchNiveaux(String schoolId) =>
      (db.select(db.qualitativeLevels)
            ..where((n) => n.schoolId.equals(schoolId) & n.deletedAt.isNull())
            ..orderBy([(n) => OrderingTerm.asc(n.sortOrder)]))
          .watch()
          .map((l) => [for (final n in l) niveau(n)]);

  static NiveauQualitatif niveau(QualitativeLevelRow n) => NiveauQualitatif(
    id: n.id,
    code: n.code,
    libelle: n.label,
    couleur: n.colorHex,
    pictogramme: n.iconKey,
    ordre: n.sortOrder,
  );

  /// À l'activation du module : domaines et niveaux par défaut, s'il n'y en
  /// a pas encore (directeur).
  Future<void> assurerParDefaut(String schoolId) async {
    final domaines = await (db.select(
      db.learningDomains,
    )..where((d) => d.schoolId.equals(schoolId))).get();
    if (domaines.isEmpty) {
      for (final (i, nom) in domainesParDefaut.indexed) {
        await store.save('learning_domains', {
          'id': idDomaineParDefaut(schoolId, nom),
          'school_id': schoolId,
          'name': nom,
          'sort_order': i + 1,
          'active': true,
        });
      }
    }
    final niveaux = await (db.select(
      db.qualitativeLevels,
    )..where((n) => n.schoolId.equals(schoolId))).get();
    if (niveaux.isEmpty) {
      for (final n in niveauxParDefaut) {
        await store.save('qualitative_levels', {
          'id': idNiveau(schoolId, n.code),
          'school_id': schoolId,
          'code': n.code,
          'label': n.libelle,
          'color_hex': n.couleur,
          'icon_key': n.pictogramme,
          'sort_order': n.ordre,
        });
      }
    }
  }

  Future<void> ajouterDomaine(String schoolId, String nom) async {
    final tous = await (db.select(
      db.learningDomains,
    )..where((d) => d.schoolId.equals(schoolId))).get();
    // Même nom qu'un domaine retiré : on le remet (nom unique par école).
    final ancien = tous.where((d) => d.name == nom.trim()).firstOrNull;
    final max = tous.fold(0, (m, d) => d.sortOrder > m ? d.sortOrder : m);
    await store.save('learning_domains', {
      'id': ancien?.id ?? _uuid.v4(),
      'school_id': schoolId,
      'name': nom.trim(),
      'sort_order': max + 1,
      'active': true,
      'deleted_at': null,
    });
  }

  Future<void> renommerDomaine(String id, String nom) =>
      store.save('learning_domains', {'id': id, 'name': nom.trim()});

  /// Retiré de l'évaluation ; les évaluations passées restent conservées.
  Future<void> retirerDomaine(String id) =>
      store.save('learning_domains', {'id': id, 'active': false});

  Future<void> deplacerDomaine(String schoolId, String id, int sens) async {
    final tous = await watchDomaines(schoolId).first;
    final i = tous.indexWhere((d) => d.id == id);
    final j = i + sens;
    if (i < 0 || j < 0 || j >= tous.length) return;
    final ordre = [...tous];
    ordre.insert(j, ordre.removeAt(i));
    for (final (k, d) in ordre.indexed) {
      if (d.sortOrder != k + 1) {
        await store.save('learning_domains', {'id': d.id, 'sort_order': k + 1});
      }
    }
  }

  Future<void> modifierNiveau(String id, Map<String, Object?> champs) =>
      store.save('qualitative_levels', {'id': id, ...champs});

  // --------------------------- Classe ---------------------------

  Future<ClassRow?> classe(String classId) => (db.select(
    db.classes,
  )..where((c) => c.id.equals(classId))).getSingleOrNull();

  Stream<List<StudentRow>> watchEnfants(String classId) => db
      .tableUpdates(TableUpdateQuery.onAllTables([db.enrollments, db.students]))
      .asyncMap((_) => enfants(classId))
      .startWithFuture(enfants(classId));

  Future<List<StudentRow>> enfants(String classId) async {
    final inscrits =
        await (db.select(db.enrollments)..where(
              (e) =>
                  e.classId.equals(classId) &
                  e.deletedAt.isNull() &
                  e.endsOn.isNull(),
            ))
            .get();
    final ids = {for (final e in inscrits) e.studentId};
    return (await (db.select(
      db.students,
    )..where((s) => s.id.isIn(ids) & s.deletedAt.isNull())).get())..sort(
      (a, b) => '${a.lastName} ${a.firstNames}'.compareTo(
        '${b.lastName} ${b.firstNames}',
      ),
    );
  }

  /// Le trimestre [t] (1 à 3) de la classe, créé au premier usage.
  Future<String> assurerTrimestre(ClassRow c, int t) async {
    final id = idPeriode(c.id, t);
    final existe = await (db.select(
      db.preschoolPeriods,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    if (existe == null) {
      await store.save('preschool_periods', {
        'id': id,
        'school_id': c.schoolId,
        'class_id': c.id,
        'school_year_id': c.schoolYearId,
        'label': trimestresMaternelle[t - 1],
        'sequence': t,
      });
    }
    return id;
  }

  /// Niveau atteint par enfant et par domaine : {(enfant, domaine): niveau}.
  Stream<Map<(String, String), String>> watchEvaluations(String periodId) =>
      (db.select(db.preschoolEvaluations)
            ..where((e) => e.periodId.equals(periodId) & e.deletedAt.isNull()))
          .watch()
          .map(
            (l) => {for (final e in l) (e.studentId, e.domainId): e.levelId},
          );

  /// Choisit (ou retire, si [levelId] est null) le niveau d'un domaine.
  Future<void> evaluer({
    required String schoolId,
    required String periodId,
    required String studentId,
    required String domainId,
    required String? levelId,
  }) async {
    final id = idEvaluation(periodId, studentId, domainId);
    final existe = await (db.select(
      db.preschoolEvaluations,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    if (levelId == null) {
      if (existe != null) {
        await store.save('preschool_evaluations', {
          'id': id,
          'deleted_at': store.clock.nowIso(),
        });
      }
      return;
    }
    await store.save('preschool_evaluations', {
      'id': id,
      'school_id': schoolId,
      'period_id': periodId,
      'student_id': studentId,
      'domain_id': domainId,
      'level_id': levelId,
      'deleted_at': null,
    });
  }

  Stream<PreschoolBookletRow?> watchLivret(String periodId, String studentId) =>
      (db.select(db.preschoolBooklets)
            ..where((b) => b.id.equals(idLivret(periodId, studentId))))
          .watchSingleOrNull();

  Future<void> enregistrerLivret(
    String schoolId,
    String periodId,
    String studentId,
    Map<String, Object?> champs,
  ) => store.save('preschool_booklets', {
    'id': idLivret(periodId, studentId),
    'school_id': schoolId,
    'period_id': periodId,
    'student_id': studentId,
    ...champs,
  });

  // --------------------------- Présences ---------------------------

  Stream<Map<String, String>> watchPresences(String classId, String day) =>
      (db.select(db.attendance)..where(
            (a) =>
                a.classId.equals(classId) &
                a.day.equals(day) &
                a.deletedAt.isNull(),
          ))
          .watch()
          .map((l) => {for (final a in l) a.studentId: a.status});

  Future<void> marquer(
    ClassRow c,
    String studentId,
    String day,
    String status,
  ) => store.save('attendance', {
    'id': idPresence(studentId, day),
    'school_id': c.schoolId,
    'class_id': c.id,
    'student_id': studentId,
    'day': day,
    'status': status,
    'deleted_at': null,
  });

  /// Absences et retards d'un enfant dans la classe (jusqu'au [jusquau]
  /// inclus s'il est donné).
  Future<(int, int)> compterPresences(
    String classId,
    String studentId, {
    String? jusquau,
  }) async {
    final l =
        await (db.select(db.attendance)..where(
              (a) =>
                  a.classId.equals(classId) &
                  a.studentId.equals(studentId) &
                  a.deletedAt.isNull(),
            ))
            .get();
    final dans = [
      for (final a in l)
        if (jusquau == null || a.day.compareTo(jusquau) <= 0) a,
    ];
    return (
      dans.where((a) => a.status == 'absent').length,
      dans.where((a) => a.status == 'retard').length,
    );
  }

  // --------------------------- Livrets ---------------------------

  /// Rangs (si le directeur a activé le classement) : {enfant: rang}.
  Future<Map<String, int>> rangs(
    String periodId,
    List<String> enfants,
    String schoolId,
  ) async {
    final niveaux = await watchNiveaux(schoolId).first;
    final index = {for (final (i, n) in niveaux.indexed) n.id: i};
    final domaines = {
      for (final d in await watchDomaines(schoolId).first) d.id,
    };
    final evals = await watchEvaluations(periodId).first;
    return classerEnfants({
      for (final e in enfants)
        e: [
          for (final MapEntry(key: (enfant, domaine), value: niveau)
              in evals.entries)
            if (enfant == e &&
                domaines.contains(domaine) &&
                index[niveau] != null)
              pointsNiveau(index[niveau]!, niveaux.length),
        ],
    });
  }

  /// Livrets d'un trimestre (tous les enfants, ou un seul).
  Future<List<LivretMaternelle>> livrets(
    String classId,
    int trimestre, {
    String? studentId,
  }) async {
    final c = (await classe(classId))!;
    final ecole = await (db.select(
      db.schools,
    )..where((s) => s.id.equals(c.schoolId))).getSingle();
    final periodId = await assurerTrimestre(c, trimestre);
    final periode = await (db.select(
      db.preschoolPeriods,
    )..where((p) => p.id.equals(periodId))).getSingle();
    final domaines = await watchDomaines(c.schoolId).first;
    final niveaux = await watchNiveaux(c.schoolId).first;
    final parId = {for (final n in niveaux) n.id: n};
    final evals = await watchEvaluations(periodId).first;
    final tous = await enfants(classId);
    final classement = ecole.preschoolRanking
        ? await rangs(periodId, [for (final e in tous) e.id], c.schoolId)
        : const <String, int>{};
    final docs = DocumentsRepository(store);
    final entete = await docs.entete(ecole);
    final enseignant = c.mainTeacherId == null
        ? null
        : await (db.select(
            db.teachers,
          )..where((t) => t.id.equals(c.mainTeacherId!))).getSingleOrNull();
    return [
      for (final e in tous)
        if (studentId == null || e.id == studentId)
          await () async {
            final livret = await watchLivret(periodId, e.id).first;
            final (absences, retards) = await compterPresences(
              classId,
              e.id,
              jusquau: periode.endsOn,
            );
            return LivretMaternelle(
              entete: entete,
              classe: c.name,
              periode: periode.label,
              enfant: '${e.lastName} ${e.firstNames}',
              sexe: e.sex,
              neLe: e.birthDate == null ? null : jjmmaaaa(e.birthDate),
              lignes: [
                for (final d in domaines)
                  LigneLivret(d.name, parId[evals[(e.id, d.id)]]),
              ],
              niveaux: niveaux,
              appreciation: livret?.teacherAppreciation,
              observation: livret?.observation,
              absences: absences,
              retards: retards,
              rang: classement[e.id],
              effectif: classement.isEmpty ? null : classement.length,
              signataire: DocumentsRepository.signataire(ecole),
              enseignant: enseignant == null
                  ? null
                  : '${enseignant.lastName} ${enseignant.firstNames}',
            );
          }(),
    ];
  }
}

extension _Debut<T> on Stream<T> {
  /// Émet d'abord le résultat de [premier], puis les valeurs du flux.
  Stream<T> startWithFuture(Future<T> premier) async* {
    yield await premier;
    yield* this;
  }
}
