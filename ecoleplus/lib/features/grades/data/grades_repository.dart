import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/grades/domain/calculs.dart';
import 'package:uuid/uuid.dart';

/// Matière d'une classe avec son coefficient.
class MatiereDeClasse {
  const new(this.lien, this.matiere);
  final ClassSubjectRow lien;
  final SubjectRow matiere;
}

/// Épreuves de chaque trimestre selon le type d'école (`assessments.kind`).
List<String> typesEpreuves(TypeEcole type) => type == TypeEcole.privee
    ? const ['evaluation', 'composition']
    : const ['composition'];

/// « 1er trimestre », « 2e trimestre »…
String trimestreTexte(int t) => t == 1 ? '1er trimestre' : '${t}e trimestre';

/// « Évaluation », « Composition ».
String epreuveTexte(String kind) =>
    kind == 'evaluation' ? 'Évaluation' : 'Composition';

/// Tout ce qu'il faut pour classer une classe.
class DonneesClasse {
  const new({
    required this.classe,
    required this.ecole,
    required this.eleves,
    required this.matieres,
    required this.compositions,
    required this.notes,
    required this.mentions,
  });
  final ClassRow classe;
  final SchoolRow ecole;
  final List<StudentRow> eleves;
  final List<MatiereDeClasse> matieres;
  final List<AssessmentRow> compositions;
  final List<GradeRow> notes;
  final List<MentionScaleRow> mentions;

  int get echelle => (ecole.gradingScale * 100).round();
  RegleAbsent get regle =>
      ecole.absentRule == 'zero' ? RegleAbsent.zero : RegleAbsent.nonCompte;

  /// Méthode de calcul : type d'école choisi dans « Mon école » (A15).
  TypeEcole get type => TypeEcole.depuis(ecole.schoolType);

  /// Épreuves d'un trimestre selon le type d'école (évaluation puis
  /// composition en école privée).
  List<AssessmentRow> epreuvesTrimestre(int t) => [
    for (final k in typesEpreuves(type))
      ...compositions.where((c) => c.sequence == t && c.kind == k),
  ];

  List<Eleve> get _eleves => [
    for (final s in eleves)
      Eleve(s.id, '${s.lastName} ${s.firstNames}', fille: s.sex == 'F'),
  ];
  List<Matiere> get matieresCalcul => [
    for (final m in matieres)
      Matiere(m.matiere.id, m.matiere.name, (m.lien.coefficient * 100).round()),
  ];
  List<Composition> get _epreuves => [
    for (final c in compositions)
      Composition(
        c.id,
        c.label,
        (c.maxScore * 100).round(),
        trimestre: c.sequence,
        type: TypeEpreuve.depuis(c.kind),
      ),
  ];
  List<Mention> get _mentions => [
    for (final m in mentions)
      Mention(
        (m.minAverage * 100).round(),
        (m.maxAverage * 100).round(),
        m.label,
      ),
  ];

  /// Classement d'un trimestre (1, 2, 3).
  Classement trimestre(int t) => classementTrimestre(
    type: type,
    trimestre: t,
    eleves: _eleves,
    matieres: matieresCalcul,
    compositions: _epreuves,
    notes: [for (final g in notes) noteDe(g)],
    regle: regle,
    echelle: echelle,
    mentions: _mentions,
  );

  /// Classement de l'année : (T1 + T2 + T3) ÷ 3.
  Classement annee() => classementAnnuel(
    type: type,
    eleves: _eleves,
    matieres: matieresCalcul,
    compositions: _epreuves,
    notes: [for (final g in notes) noteDe(g)],
    regle: regle,
    echelle: echelle,
    mentions: _mentions,
  );

  static Note noteDe(GradeRow g) => Note(
    eleveId: g.studentId,
    matiereId: g.subjectId,
    compositionId: g.assessmentId,
    valeur: g.score == null ? null : (g.score! * 100).round(),
    statut: switch (g.status) {
      'absent' => StatutNote.absent,
      'dispense' => StatutNote.dispense,
      _ => StatutNote.note,
    },
  );
}

class GradesRepository {
  new(this.store);

  final LocalStore store;
  static const _uuid = Uuid();
  AppDatabase get db => store.db;

  static String _id(String cle) =>
      _uuid.v5(Namespace.url.value, 'ecoleplus:$cle');
  static String idNote(String assessment, String student, String subject) =>
      _id('note:$assessment:$student:$subject');
  static String idMatiereClasse(String classe, String subject) =>
      _id('matiere:$classe:$subject');
  static String idResultatAnnuel(String student, String year) =>
      _id('annuel:$student:$year');

  // ------------------------------ Matières ------------------------------

  Stream<List<SubjectRow>> watchMatieresEcole(String schoolId) =>
      (db.select(db.subjects)
            ..where((s) => s.schoolId.equals(schoolId) & s.deletedAt.isNull())
            ..orderBy([
              (s) => OrderingTerm.asc(s.sortOrder),
              (s) => OrderingTerm.asc(s.name),
            ]))
          .watch();

  Future<String> creerMatiere(String schoolId, String nom) async {
    final n = nom.trim();
    final existe =
        await (db.select(db.subjects)
              ..where((s) => s.schoolId.equals(schoolId) & s.name.equals(n)))
            .getSingleOrNull();
    if (existe != null) return existe.id;
    final id = _id('matiere-ecole:$schoolId:${n.toLowerCase()}');
    await store.save('subjects', {
      'id': id,
      'school_id': schoolId,
      'name': n,
      'cycle': 'primaire',
    });
    return id;
  }

  Stream<List<MatiereDeClasse>> watchMatieresClasse(String classId) {
    final q =
        db.select(db.classSubjects).join([
            innerJoin(
              db.subjects,
              db.subjects.id.equalsExp(db.classSubjects.subjectId),
            ),
          ])
          ..where(
            db.classSubjects.classId.equals(classId) &
                db.classSubjects.deletedAt.isNull(),
          )
          ..orderBy([
            OrderingTerm.asc(db.subjects.sortOrder),
            OrderingTerm.asc(db.subjects.name),
          ]);
    return q.watch().map(
      (r) => [
        for (final x in r)
          MatiereDeClasse(
            x.readTable(db.classSubjects),
            x.readTable(db.subjects),
          ),
      ],
    );
  }

  /// Ajoute la matière à la classe (ou change son coefficient).
  Future<void> definirCoefficient(
    ClassRow classe,
    String subjectId,
    double coefficient,
  ) async {
    if (coefficient < 0) {
      throw const UserMessage('Le coefficient ne peut pas être négatif.');
    }
    // Lien déjà connu (même créé ailleurs) : il est mis à jour.
    final existe =
        await (db.select(db.classSubjects)
              ..where(
                (l) =>
                    l.classId.equals(classe.id) & l.subjectId.equals(subjectId),
              )
              ..limit(1))
            .getSingleOrNull();
    await store.save('class_subjects', {
      'id': existe?.id ?? idMatiereClasse(classe.id, subjectId),
      'school_id': classe.schoolId,
      'class_id': classe.id,
      'subject_id': subjectId,
      'coefficient': coefficient,
      'deleted_at': null,
    });
  }

  Future<void> retirerMatiere(String classSubjectId) => store.save(
    'class_subjects',
    {'id': classSubjectId, 'deleted_at': store.clock.nowIso()},
  );

  // ---------------------------- Compositions ----------------------------

  Stream<List<AssessmentRow>> watchCompositions(String classId) =>
      (db.select(db.assessments)
            ..where((a) => a.classId.equals(classId) & a.deletedAt.isNull())
            ..orderBy([(a) => OrderingTerm.asc(a.sequence)]))
          .watch();

  /// Épreuves du trimestre [t], créées au besoin (barème de l'école) :
  /// une composition (école publique), ou une évaluation et une composition
  /// (école privée). Une épreuve déjà connue (même créée ailleurs) est
  /// reprise ; sinon identifiant fixe, pour que deux téléphones hors ligne
  /// ne la créent pas deux fois.
  Future<List<AssessmentRow>> preparerTrimestre(DonneesClasse d, int t) async {
    if (t < 1 || t > 3) throw const UserMessage('Trimestre 1, 2 ou 3.');
    final epreuves = <AssessmentRow>[];
    for (final kind in typesEpreuves(d.type)) {
      var e = d.compositions
          .where((c) => c.sequence == t && c.kind == kind)
          .firstOrNull;
      if (e == null) {
        final id = _id('epreuve:${d.classe.id}:$t:$kind');
        await store.save('assessments', {
          'id': id,
          'school_id': d.classe.schoolId,
          'class_id': d.classe.id,
          'school_year_id': d.classe.schoolYearId,
          'label': '${epreuveTexte(kind)} — ${trimestreTexte(t)}',
          'kind': kind,
          'sequence': t,
          'max_score': d.ecole.gradingScale,
          'held_on': store.clock.nowIso().substring(0, 10),
          'deleted_at': null,
        });
        e = await (db.select(
          db.assessments,
        )..where((a) => a.id.equals(id))).getSingle();
      }
      epreuves.add(e);
    }
    return epreuves;
  }

  // -------------------------------- Notes -------------------------------

  Stream<List<GradeRow>> watchNotes(String assessmentId) =>
      (db.select(db.grades)..where(
            (g) => g.assessmentId.equals(assessmentId) & g.deletedAt.isNull(),
          ))
          .watch();

  /// Enregistre une note (en centièmes), une absence, ou efface la saisie
  /// (centiemes == null et statut note).
  Future<void> enregistrerNote({
    required AssessmentRow composition,
    required String studentId,
    required String subjectId,
    int? centiemes,
    StatutNote statut = StatutNote.note,
  }) async {
    if (centiemes != null && centiemes > (composition.maxScore * 100).round()) {
      throw UserMessage(
        'Note hors barème : ${centiemesTexte(centiemes)} sur '
        '${centiemesTexte((composition.maxScore * 100).round())}.',
      );
    }
    final efface = statut == StatutNote.note && centiemes == null;
    // Une note déjà connue (même créée ailleurs, avec un autre identifiant)
    // est corrigée ; sinon identifiant fixe : deux téléphones qui saisissent
    // la même note la corrigent au lieu de la doubler.
    final existe =
        await (db.select(db.grades)
              ..where(
                (g) =>
                    g.assessmentId.equals(composition.id) &
                    g.studentId.equals(studentId) &
                    g.subjectId.equals(subjectId),
              )
              ..orderBy([(g) => OrderingTerm.asc(g.deletedAt.isNotNull())])
              ..limit(1))
            .getSingleOrNull();
    final id = existe?.id ?? idNote(composition.id, studentId, subjectId);
    if (efface) {
      // Rien à effacer si aucune note n'a encore été enregistrée.
      if (existe == null || existe.deletedAt != null) return;
      await store.save('grades', {
        'id': id,
        'deleted_at': store.clock.nowIso(),
      });
      return;
    }
    await store.save('grades', {
      'id': id,
      'school_id': composition.schoolId,
      'assessment_id': composition.id,
      'student_id': studentId,
      'subject_id': subjectId,
      'score': centiemes == null ? null : centiemes / 100,
      'status': switch (statut) {
        StatutNote.note => 'note',
        StatutNote.absent => 'absent',
        StatutNote.dispense => 'dispense',
      },
      'deleted_at': null,
    });
  }

  // -------------------------- Résultats annuels --------------------------

  /// Garde, pour la fiche de scolarité, la moyenne annuelle, le rang et
  /// l'effectif de chaque élève classé (classement de l'année, [cumul]).
  Future<int> enregistrerResultatsAnnuels(
    DonneesClasse d,
    Classement cumul, {
    required String date,
  }) async {
    var n = 0;
    for (final r in cumul.resultats) {
      // Sans moyenne annuelle (un trimestre manque) : rien à garder.
      if (r.moyenne == null) continue;
      n++;
      final existe =
          await (db.select(db.annualResults)
                ..where(
                  (a) =>
                      a.studentId.equals(r.eleve.id) &
                      a.schoolYearId.equals(d.classe.schoolYearId),
                )
                ..limit(1))
              .getSingleOrNull();
      await store.save('annual_results', {
        'id': existe?.id ?? idResultatAnnuel(r.eleve.id, d.classe.schoolYearId),
        'school_id': d.classe.schoolId,
        'student_id': r.eleve.id,
        'school_year_id': d.classe.schoolYearId,
        'class_id': d.classe.id,
        'level_code': d.classe.levelCode,
        'result_date': date,
        'general_average': r.moyenne == null ? null : r.moyenne! / 100,
        'rank': r.rang,
        'rank_ex_aequo': r.exAequo,
        'class_size': cumul.statistiques.effectif,
        'deleted_at': null,
      });
    }
    return n;
  }

  Stream<List<AnnualResultRow>> watchResultatsAnnuels(String classId) =>
      (db.select(db.annualResults)
            ..where((r) => r.classId.equals(classId) & r.deletedAt.isNull()))
          .watch();

  // ------------------------------ Mentions ------------------------------

  Stream<List<MentionScaleRow>> watchMentions(String schoolId) =>
      (db.select(db.mentionScales)
            ..where((m) => m.schoolId.equals(schoolId) & m.deletedAt.isNull())
            ..orderBy([(m) => OrderingTerm.asc(m.minAverage)]))
          .watch();

  Future<void> enregistrerMention(
    String schoolId, {
    required double min,
    required double max,
    required String libelle,
    String? id,
  }) {
    if (min > max) {
      throw const UserMessage('Le minimum doit être inférieur au maximum.');
    }
    return store.save('mention_scales', {
      'id': id ?? _uuid.v4(),
      'school_id': schoolId,
      'min_average': min,
      'max_average': max,
      'label': libelle.trim(),
    });
  }

  Future<void> retirerMention(String id) => store.save('mention_scales', {
    'id': id,
    'deleted_at': store.clock.nowIso(),
  });

  // ------------------------- Données de la classe ------------------------

  /// Recalcul automatique : toute modification des notes, coefficients,
  /// compositions, élèves ou mentions relance le calcul.
  Stream<DonneesClasse?> watchDonnees(String classId) => db
      .tableUpdates(
        TableUpdateQuery.onAllTables([
          db.grades,
          db.classSubjects,
          db.subjects,
          db.assessments,
          db.enrollments,
          db.students,
          db.mentionScales,
          db.schools,
        ]),
      )
      .asyncMap((_) => chargerDonnees(classId))
      .startWithFuture(chargerDonnees(classId));

  Future<DonneesClasse?> chargerDonnees(String classId) async {
    final classe = await (db.select(
      db.classes,
    )..where((c) => c.id.equals(classId))).getSingleOrNull();
    if (classe == null) return null;
    final ecole = await (db.select(
      db.schools,
    )..where((s) => s.id.equals(classe.schoolId))).getSingleOrNull();
    if (ecole == null) return null;
    final inscrits =
        await (db.select(db.enrollments)..where(
              (e) =>
                  e.classId.equals(classId) &
                  e.deletedAt.isNull() &
                  e.endsOn.isNull(),
            ))
            .get();
    final ids = {for (final e in inscrits) e.studentId};
    final eleves =
        (await (db.select(
          db.students,
        )..where((s) => s.id.isIn(ids) & s.deletedAt.isNull())).get())..sort(
          (a, b) => '${a.lastName} ${a.firstNames}'.compareTo(
            '${b.lastName} ${b.firstNames}',
          ),
        );
    final compositions = await watchCompositions(classId).first;
    final notes = compositions.isEmpty
        ? const <GradeRow>[]
        : await (db.select(db.grades)..where(
                (g) =>
                    g.assessmentId.isIn([for (final c in compositions) c.id]) &
                    g.deletedAt.isNull(),
              ))
              .get();
    return DonneesClasse(
      classe: classe,
      ecole: ecole,
      eleves: eleves,
      matieres: await watchMatieresClasse(classId).first,
      compositions: compositions,
      notes: notes,
      mentions: await watchMentions(classe.schoolId).first,
    );
  }
}

extension _Debut<T> on Stream<T> {
  /// Émet d'abord le résultat de [premier], puis les valeurs du flux.
  Stream<T> startWithFuture(Future<T> premier) async* {
    yield await premier;
    yield* this;
  }
}
