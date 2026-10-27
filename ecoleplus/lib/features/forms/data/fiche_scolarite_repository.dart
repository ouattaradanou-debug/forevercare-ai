import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/forms/domain/donnees_formulaires.dart';
import 'package:ecoleplus/features/forms/domain/fiche_scolarite.dart';
import 'package:ecoleplus/features/grades/data/grades_repository.dart';
import 'package:uuid/uuid.dart';

/// Fiche de scolarité (B4, module 17.6) : préremplie depuis la fiche de
/// l'élève, le registre, les parents, les résultats annuels gardés et,
/// pour l'année en cours, le calcul en direct.
class FicheScolariteRepository {
  new(this.store, this.notes);

  final LocalStore store;
  final GradesRepository notes;
  AppDatabase get db => store.db;

  Future<FicheScolarite?> fiche(
    String studentId, {
    bool copieConforme = false,
  }) async {
    final s = await (db.select(
      db.students,
    )..where((x) => x.id.equals(studentId))).getSingleOrNull();
    if (s == null) return null;
    final ecole = await (db.select(
      db.schools,
    )..where((x) => x.id.equals(s.schoolId))).getSingle();
    final anneeId = ecole.currentSchoolYearId;
    final h = anneeId == null
        ? null
        : await (db.select(
            db.adminHeaders,
          )..where((x) => x.schoolYearId.equals(anneeId))).getSingleOrNull();
    final r = await (db.select(
      db.studentRegistry,
    )..where((x) => x.id.equals(studentId))).getSingleOrNull();
    final parents =
        await (db.select(db.guardians)
              ..where(
                (g) => g.studentId.equals(studentId) & g.deletedAt.isNull(),
              )
              ..orderBy([(g) => OrderingTerm.asc(g.sortOrder)]))
            .get();
    GuardianRow? parent(String relation) =>
        parents.where((g) => g.relation == relation).firstOrNull;
    final logeur =
        parents.where((g) => g.isLodger).firstOrNull ??
        parent('logeur') ??
        parent('tuteur') ??
        parent('pere');
    final fille = s.sex == 'F';

    // Résultats gardés, puis l'année en cours calculée en direct.
    final gardes =
        await (db.select(db.annualResults)..where(
              (a) => a.studentId.equals(studentId) & a.deletedAt.isNull(),
            ))
            .get();
    final enDirect = anneeId == null
        ? null
        : await _anneeEnCours(studentId, anneeId, fille: fille);
    final cours = [
      for (final a in gardes)
        if (enDirect == null || a.schoolYearId != anneeId)
          CoursSuivi(
            niveau: a.levelCode,
            essai: a.attempt,
            date: a.resultDate,
            moyenne: a.generalAverage == null
                ? null
                : (a.generalAverage! * 100).round(),
            rang: a.rank,
            exAequo: a.rankExAequo,
            effectif: a.classSize,
            fille: fille,
          ),
      ?enDirect,
    ];
    String? texte(String? v) => v == null || v.trim().isEmpty ? null : v;
    return FicheScolarite(
      entete: [
        if (h?.ministry != null) h!.ministry!,
        if (h?.regionalDirection != null) h!.regionalDirection!,
        if (h?.provincialDirection != null) h!.provincialDirection!,
      ],
      pays: h?.country ?? 'BURKINA FASO',
      devise: h?.motto,
      nom: '${s.lastName} ${s.firstNames}',
      sexe: switch (s.sex) {
        'F' => 'F',
        'M' => 'M',
        _ => null,
      },
      neLe: s.birthDate == null ? null : jjmmaaaa(s.birthDate),
      lieuNaissance: texte(s.birthPlace),
      pere: parent('pere')?.fullName,
      professionPere: parent('pere')?.profession,
      mere: parent('mere')?.fullName,
      professionMere: parent('mere')?.profession,
      domicile: texte(s.domicile),
      race: r?.race,
      religion: r?.religion,
      raceReligion: ecole.showRaceReligion,
      matricule: s.registryNumber?.toString(),
      ecole: h?.schoolLabel ?? ecole.name,
      logeur: logeur == null
          ? null
          : [
              logeur.fullName,
              ?texte(logeur.address ?? logeur.domicile),
            ].join(', '),
      entreLe: s.entryDate == null ? null : jjmmaaaa(s.entryDate),
      venantDe: r?.originSchool,
      sortiLe: s.exitDate == null ? null : jjmmaaaa(s.exitDate),
      allantA: r?.destination,
      motifDepart: r?.exitReason,
      cours: coursParCase(cours),
      diplomes: [
        if (r?.cepDate != null) 'C.E.P. le ${jjmmaaaa(r!.cepDate)}',
        ?texte(r?.diplomas),
      ].join(' ; '),
      observations: r?.directorObservations,
      copieConforme: copieConforme,
      dateCopie: copieConforme
          ? jjmmaaaa(store.clock.nowIso().substring(0, 10))
          : null,
    );
  }

  /// Résultat de l'année en cours calculé en direct (null si l'élève n'est
  /// pas inscrit cette année ou s'il manque un trimestre).
  Future<CoursSuivi?> _anneeEnCours(
    String studentId,
    String anneeId, {
    required bool fille,
  }) async {
    final inscription =
        await (db.select(db.enrollments)..where(
              (e) =>
                  e.studentId.equals(studentId) &
                  e.schoolYearId.equals(anneeId) &
                  e.deletedAt.isNull() &
                  e.endsOn.isNull(),
            ))
            .getSingleOrNull();
    if (inscription == null) return null;
    final d = await notes.chargerDonnees(inscription.classId);
    final r = d?.annee().resultats.where((x) => x.eleve.id == studentId);
    final res = r == null || r.isEmpty ? null : r.first;
    if (res?.moyenne == null) return null;
    final annee = await (db.select(
      db.schoolYears,
    )..where((y) => y.id.equals(anneeId))).getSingleOrNull();
    return CoursSuivi(
      niveau: inscription.levelCode,
      essai: inscription.isRepeat ? 2 : 1,
      date: annee?.endsOn ?? store.clock.nowIso().substring(0, 10),
      moyenne: res!.moyenne,
      rang: res.rang,
      exAequo: res.exAequo,
      effectif: d!.eleves.length,
      fille: fille,
    );
  }

  /// Chaque fiche générée est inscrite au journal (copie conforme ou non).
  Future<void> journaliser(
    String schoolId,
    String studentId, {
    required bool copieConforme,
  }) => store.save('scolarity_copy_log', {
    'id': const Uuid().v4(),
    'school_id': schoolId,
    'student_id': studentId,
    'is_certified_copy': copieConforme,
    'generated_at': store.clock.nowIso(),
  });
}
