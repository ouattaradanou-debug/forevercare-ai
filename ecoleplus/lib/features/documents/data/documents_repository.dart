import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/documents/domain/documents_directeur.dart';
import 'package:ecoleplus/features/forms/domain/donnees_formulaires.dart';
import 'package:uuid/uuid.dart';

/// Documents du directeur (A17) : préremplis depuis les fiches existantes
/// (école, en-têtes de l'année, élève, parents, registre, classe,
/// enseignant) ; chaque document délivré est journalisé.
class DocumentsRepository {
  new(this.store);

  final LocalStore store;
  AppDatabase get db => store.db;

  Future<SchoolRow> _ecole(String schoolId) =>
      (db.select(db.schools)..where((s) => s.id.equals(schoolId))).getSingle();

  static Signataire signataire(SchoolRow e) => Signataire(
    civilite: e.directorCivility,
    nom: _texte(e.directorName),
    grade: _texte(e.directorGrade),
  );

  Future<EnteteDocument> entete(SchoolRow e) async {
    final anneeId = e.currentSchoolYearId;
    final h = anneeId == null
        ? null
        : await (db.select(
            db.adminHeaders,
          )..where((x) => x.schoolYearId.equals(anneeId))).getSingleOrNull();
    final annee = anneeId == null
        ? null
        : await (db.select(
            db.schoolYears,
          )..where((y) => y.id.equals(anneeId))).getSingleOrNull();
    return EnteteDocument(
      ecole: _texte(h?.schoolLabel) ?? e.name,
      ministere: _texte(h?.ministry),
      directionRegionale: _texte(h?.regionalDirection),
      directionProvinciale: _texte(h?.provincialDirection),
      ceb: _texte(h?.ceb),
      pays: _texte(h?.country) ?? 'BURKINA FASO',
      devise: _texte(h?.motto),
      anneeScolaire: annee?.label,
    );
  }

  Future<EleveDocument?> eleve(String studentId) async {
    final s = await (db.select(
      db.students,
    )..where((x) => x.id.equals(studentId))).getSingleOrNull();
    if (s == null) return null;
    final parents =
        await (db.select(db.guardians)
              ..where(
                (g) => g.studentId.equals(studentId) & g.deletedAt.isNull(),
              )
              ..orderBy([(g) => OrderingTerm.asc(g.sortOrder)]))
            .get();
    GuardianRow? parent(String r) =>
        parents.where((g) => g.relation == r).firstOrNull;
    final ecole = await _ecole(s.schoolId);
    final anneeId = ecole.currentSchoolYearId;
    // Classe de l'année ; pour un élève parti, sa dernière classe.
    final inscriptions =
        await (db.select(db.enrollments)
              ..where(
                (e) => e.studentId.equals(studentId) & e.deletedAt.isNull(),
              )
              ..orderBy([(e) => OrderingTerm.desc(e.startsOn)]))
            .get();
    final inscription =
        inscriptions
            .where((e) => e.schoolYearId == anneeId && e.endsOn == null)
            .firstOrNull ??
        inscriptions.firstOrNull;
    final classe = inscription == null
        ? null
        : await (db.select(
            db.classes,
          )..where((c) => c.id.equals(inscription.classId))).getSingleOrNull();
    return EleveDocument(
      nom: '${s.lastName} ${s.firstNames}',
      sexe: s.sex,
      neLe: s.birthDate == null ? null : jjmmaaaa(s.birthDate),
      lieuNaissance: _texte(s.birthPlace),
      pere: parent('pere')?.fullName,
      professionPere: _texte(parent('pere')?.profession),
      mere: parent('mere')?.fullName,
      professionMere: _texte(parent('mere')?.profession),
      matricule: s.registryNumber?.toString(),
      classe: classe?.name,
      niveau: inscription?.levelCode,
      entreLe: s.entryDate == null ? null : jjmmaaaa(s.entryDate),
    );
  }

  Future<EnseignantDocument?> enseignant(String teacherId) async {
    final t = await (db.select(
      db.teachers,
    )..where((x) => x.id.equals(teacherId))).getSingleOrNull();
    if (t == null) return null;
    String? date(String? iso) => iso == null ? null : jjmmaaaa(iso);
    return EnseignantDocument(
      nom: '${t.lastName} ${t.firstNames}',
      sexe: t.sex,
      matricule: _texte(t.matricule),
      emploi: _texte(t.emploi),
      decisionNumero: _texte(t.assignmentDecisionNumber),
      decisionDate: date(t.assignmentDecisionDate),
      priseDeService: date(t.serviceStartDate),
    );
  }

  /// Le document à imprimer pour un élève ou un enseignant ([personneId]).
  Future<DocumentDirecteur?> document(
    CodeDocument code,
    String schoolId,
    String personneId, {
    String? lieu,
    String? date,
    String? niveau,
    bool court = false,
  }) async {
    final e = await _ecole(schoolId);
    final eleveDoc = code.pourEnseignant ? null : await eleve(personneId);
    final ensDoc = code.pourEnseignant ? await enseignant(personneId) : null;
    if (eleveDoc == null && ensDoc == null) return null;
    return DocumentDirecteur(
      code: code,
      entete: await entete(e),
      signataire: signataire(e),
      eleve: eleveDoc,
      enseignant: ensDoc,
      lieu: lieu ?? _texte(e.commune),
      date: date ?? jjmmaaaa(store.clock.nowIso().substring(0, 10)),
      niveau: niveau,
      court: court,
    );
  }

  /// Chaque document délivré est inscrit au journal (sans numéro).
  Future<void> journaliser(
    CodeDocument code,
    String schoolId,
    String personneId,
  ) async {
    final e = await _ecole(schoolId);
    await store.save('issued_documents', {
      'id': const Uuid().v4(),
      'school_id': schoolId,
      'school_year_id': e.currentSchoolYearId,
      'doc_code': code.code,
      'student_id': code.pourEnseignant ? null : personneId,
      'teacher_id': code.pourEnseignant ? personneId : null,
      'generated_at': store.clock.nowIso(),
    });
  }

  static String? _texte(String? v) =>
      v == null || v.trim().isEmpty ? null : v.trim();
}
