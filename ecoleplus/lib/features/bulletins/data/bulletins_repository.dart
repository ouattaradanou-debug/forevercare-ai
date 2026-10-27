import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/bulletins/domain/bulletin.dart';
import 'package:ecoleplus/features/forms/domain/donnees_formulaires.dart';
import 'package:ecoleplus/features/grades/data/grades_repository.dart';
import 'package:ecoleplus/features/grades/domain/calculs.dart';
import 'package:uuid/uuid.dart';

/// « Éval. », « Compo. ».
String epreuveCourte(String kind) => kind == 'evaluation' ? 'Éval.' : 'Compo.';

/// Période d'un bulletin : 1, 2, 3 (trimestres) ou [anneeEntiere].
const anneeEntiere = 4;

String periodeTexte(int p) => p == anneeEntiere ? 'Année' : trimestreTexte(p);

/// Bulletins (module 7) : appréciations, observations, décisions, modèle de
/// l'école, et mise en forme des données à imprimer. Les notes, moyennes et
/// rangs viennent toujours du calcul en direct ([DonneesClasse]) : une note
/// corrigée change aussitôt le bulletin.
class BulletinsRepository {
  new(this.store, this.notes);

  final LocalStore store;
  final GradesRepository notes;
  static const _uuid = Uuid();
  AppDatabase get db => store.db;

  static String _id(String cle) =>
      _uuid.v5(Namespace.url.value, 'ecoleplus:$cle');
  static String idBulletin(String classe, String eleve, int periode) =>
      _id('bulletin:$classe:$eleve:$periode');
  static String idModele(String ecole) => _id('modele-bulletin:$ecole');

  // ------------------------------- Modèle -------------------------------

  Stream<ModeleBulletin> watchModele(String schoolId) =>
      (db.select(db.reportTemplates)
            ..where((t) => t.schoolId.equals(schoolId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.isDefault)])
            ..limit(1))
          .watchSingleOrNull()
          .map((t) => ModeleBulletin.depuis(t?.settings));

  Future<void> enregistrerModele(String schoolId, ModeleBulletin m) =>
      store.save('report_templates', {
        'id': idModele(schoolId),
        'school_id': schoolId,
        'name': 'Modèle de l’école',
        'settings': m.versJson(),
        'is_default': true,
        'deleted_at': null,
      });

  // ------------------------------ Bulletins -----------------------------

  Stream<List<ReportCardRow>> watchCartes(String classId) => (db.select(
    db.reportCards,
  )..where((c) => c.classId.equals(classId) & c.deletedAt.isNull())).watch();

  /// Composition du trimestre (clé du bulletin) ; null pour l'année.
  static String? cleePeriode(DonneesClasse d, int periode) =>
      periode == anneeEntiere
      ? null
      : d.compositions
            .where((c) => c.sequence == periode && c.kind == 'composition')
            .firstOrNull
            ?.id;

  static ReportCardRow? carteDe(
    List<ReportCardRow> cartes,
    DonneesClasse d,
    String eleve,
    int periode,
  ) {
    final cle = cleePeriode(d, periode);
    if (periode != anneeEntiere && cle == null) return null;
    return cartes
        .where((c) => c.studentId == eleve && c.assessmentId == cle)
        .firstOrNull;
  }

  /// Appréciation, observation ou décision d'un élève pour une période.
  Future<void> enregistrerCarte(
    DonneesClasse d,
    String eleve,
    int periode,
    Map<String, Object?> champs,
  ) async {
    String? cle;
    if (periode != anneeEntiere) {
      final epreuves = await notes.preparerTrimestre(d, periode);
      cle = epreuves.firstWhere((e) => e.kind == 'composition').id;
    }
    final existe =
        await (db.select(db.reportCards)..where(
              (c) =>
                  c.studentId.equals(eleve) &
                  c.classId.equals(d.classe.id) &
                  (cle == null
                      ? c.assessmentId.isNull()
                      : c.assessmentId.equals(cle)),
            ))
            .getSingleOrNull();
    await store.save('report_cards', {
      'id': existe?.id ?? idBulletin(d.classe.id, eleve, periode),
      'school_id': d.classe.schoolId,
      'student_id': eleve,
      'class_id': d.classe.id,
      'assessment_id': cle,
      ...champs,
      'deleted_at': null,
    });
  }

  /// Bulletins à imprimer pour la [periode] (tous les élèves, ou [eleve]).
  /// Marque les bulletins comme « générés ».
  Future<List<Bulletin>> bulletins(
    DonneesClasse d,
    int periode, {
    String? eleve,
    bool marquer = true,
  }) async {
    final annee = await (db.select(
      db.schoolYears,
    )..where((y) => y.id.equals(d.classe.schoolYearId))).getSingleOrNull();
    final h =
        await (db.select(db.adminHeaders)
              ..where((x) => x.schoolYearId.equals(d.classe.schoolYearId)))
            .getSingleOrNull();
    final cartes = await watchCartes(d.classe.id).first;
    final annuel = periode == anneeEntiere;
    final classement = annuel ? d.annee() : d.trimestre(periode);
    final resultats = {for (final r in classement.resultats) r.eleve.id: r};
    final epreuves = annuel
        ? const <AssessmentRow>[]
        : d.epreuvesTrimestre(periode);
    final parTrimestre = annuel
        ? {
            for (final t in const [1, 2, 3])
              t: {for (final r in d.trimestre(t).resultats) r.eleve.id: r},
          }
        : const <int, Map<String, Resultat>>{};
    final entete = [
      if (h?.country != null) h!.country,
      if (h?.motto != null) h!.motto!,
      if (h?.ministry != null) h!.ministry!,
      if (h?.regionalDirection != null) h!.regionalDirection!,
      if (h?.provincialDirection != null) h!.provincialDirection!,
      if (h?.ceb != null) 'CEB de ${h!.ceb}',
    ];
    String noteTexte(AssessmentRow e, String eleveId, String matiere) {
      final g = d.notes
          .where(
            (g) =>
                g.assessmentId == e.id &&
                g.studentId == eleveId &&
                g.subjectId == matiere,
          )
          .firstOrNull;
      if (g == null) return '—';
      if (g.status == 'absent') return 'Abs.';
      if (g.status == 'dispense') return 'Disp.';
      return centiemesTexte((g.score! * 100).round());
    }

    final liste = <Bulletin>[];
    for (final s in d.eleves) {
      if (eleve != null && s.id != eleve) continue;
      final r = resultats[s.id]!;
      final carte = carteDe(cartes, d, s.id, periode);
      liste.add(
        Bulletin(
          entete: entete,
          ecole: h?.schoolLabel ?? d.ecole.name,
          annee: annee?.label ?? '',
          classe: d.classe.name,
          periode: periodeTexte(periode),
          eleve: '${s.lastName} ${s.firstNames}',
          matricule: s.registryNumber?.toString() ?? s.registryProvisional,
          neLe: s.birthDate == null ? null : jjmmaaaa(s.birthDate),
          sexe: switch (s.sex) {
            'F' => 'Fille',
            'M' => 'Garçon',
            _ => null,
          },
          titresCases: annuel
              ? const ['1er trim.', '2e trim.', '3e trim.']
              : [for (final e in epreuves) epreuveCourte(e.kind)],
          lignes: [
            for (final m in d.matieresCalcul)
              LigneBulletin(
                matiere: m.nom,
                coefficient: m.coefficient,
                cases: annuel
                    ? [
                        for (final t in const [1, 2, 3])
                          centiemesTexte(
                            parTrimestre[t]![s.id]?.moyennesMatieres[m.id],
                          ),
                      ]
                    : [for (final e in epreuves) noteTexte(e, s.id, m.id)],
                moyenne: annuel
                    ? _moyenneMatiereAnnee(parTrimestre, s.id, m.id)
                    : r.moyennesMatieres[m.id],
                uneSeuleNote: r.uneSeuleNote.contains(m.id),
              ),
          ],
          resultat: r,
          statistiques: classement.statistiques,
          echelle: d.echelle,
          appreciation: carte?.teacherAppreciation,
          observation: carte?.directorObservation,
          decision: carte?.decision,
          annuel: annuel,
        ),
      );
      if (marquer && carte != null && carte.status == 'brouillon') {
        await store.save('report_cards', {
          'id': carte.id,
          'status': 'genere',
          'generated_at': store.clock.nowIso(),
        });
      }
    }
    return liste;
  }

  /// Moyenne d'une matière sur l'année : moyenne des moyennes de trimestre
  /// existantes (pour information ; la moyenne annuelle générale, elle,
  /// exige les trois trimestres).
  static int? _moyenneMatiereAnnee(
    Map<int, Map<String, Resultat>> parTrimestre,
    String eleve,
    String matiere,
  ) {
    final v = [
      for (final t in const [1, 2, 3])
        ?parTrimestre[t]![eleve]?.moyennesMatieres[matiere],
    ];
    if (v.isEmpty) return null;
    return divArrondi(v.fold(0, (a, b) => a + b), v.length);
  }
}
