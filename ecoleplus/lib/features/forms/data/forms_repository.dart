import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/forms/domain/donnees_formulaires.dart';
import 'package:ecoleplus/features/forms/pdf/pdf_formulaires.dart';
import 'package:ecoleplus/features/staff/domain/anciennete.dart';
import 'package:uuid/uuid.dart';

/// Formulaires de l'année : un seul enregistrement par (année, formulaire),
/// avec un identifiant déterministe pour que deux téléphones hors ligne
/// n'en créent pas deux.
class FormsRepository {
  new(this.store);

  final LocalStore store;
  AppDatabase get db => store.db;

  static String idFormulaire(String yearId, String code) =>
      const Uuid().v5(Namespace.url.value, 'ecoleplus:$yearId:$code');

  Stream<OfficialFormRow?> watchFormulaire(String yearId, String code) =>
      (db.select(db.officialForms)
            ..where((f) => f.id.equals(idFormulaire(yearId, code))))
          .watchSingleOrNull();

  Future<void> enregistrer(
    String schoolId,
    String yearId,
    String code,
    Map<String, Object?> fields,
  ) => store.save('official_forms', {
    'id': idFormulaire(yearId, code),
    'school_id': schoolId,
    'school_year_id': yearId,
    'form_code': code,
    ...fields,
  });

  /// Construit le PDF à partir des fiches du téléphone.
  Future<Uint8List> pdf(
    String code, {
    required SchoolRow ecole,
    required SchoolYearRow annee,
    required PolicesPdf polices,
  }) async {
    final f =
        await (db.select(db.officialForms)
              ..where((x) => x.id.equals(idFormulaire(annee.id, code))))
            .getSingleOrNull();
    final h = await (db.select(
      db.adminHeaders,
    )..where((x) => x.schoolYearId.equals(annee.id))).getSingleOrNull();
    final p = ParametresImpression(
      anneeScolaire: annee.label,
      ceb: h?.ceb,
      ecole: h?.schoolLabel ?? ecole.name,
      province: h?.province ?? ecole.province,
      departement: h?.departement ?? ecole.departement,
      commune: h?.commune ?? ecole.commune,
      periodeDu: f?.registerPeriodFrom,
      periodeAu: f?.registerPeriodTo,
      faitA: f?.signedPlace ?? ecole.commune,
      faitLe: f?.signedOn,
      directeur: f?.directorName ?? ecole.directorName,
      dateReference:
          f?.referenceDate ?? _iso(referenceParDefaut(DateTime.now())),
    );
    Future<List<T>> tous<T extends DataClass>(TableInfo<Table, T> t) =>
        db.select(t).get();
    final classes = await (db.select(
      db.classes,
    )..where((c) => c.schoolYearId.equals(annee.id))).get();
    final affectations =
        await (db.select(db.teacherYearAssignments)..where(
              (a) => a.schoolYearId.equals(annee.id) & a.deletedAt.isNull(),
            ))
            .get();
    switch (code) {
      case 'B1':
        return await pdfB1(
          polices,
          p,
          lignesB1(
            enseignants: await tous(db.teachers),
            affectations: affectations,
            classes: classes,
            diplomes: await tous(db.teacherDiplomas),
            reference: DateTime.parse(p.dateReference!),
          ),
        );
      case 'B2':
        return await pdfB2(
          polices,
          p,
          lignesB2(
            eleves: await tous(db.students),
            parents: await tous(db.guardians),
            registres: await tous(db.studentRegistry),
          ),
        );
      default:
        return await pdfB3(
          polices,
          p,
          lignesB3(
            enseignants: await tous(db.teachers),
            affectations: affectations,
            classes: classes,
            communes: await tous(db.teacherPostings),
            interruptions: await tous(db.teacherInterruptions),
            recompenses: await tous(db.teacherAwards),
            diplomes: await tous(db.teacherDiplomas),
          ),
        );
    }
  }

  /// Ce qui manque pour un formulaire complet (17.3), en phrases simples.
  Future<List<String>> manques(String code, String schoolId) async {
    final enseignants =
        await (db.select(db.teachers)..where(
              (t) =>
                  t.schoolId.equals(schoolId) &
                  t.deletedAt.isNull() &
                  t.status.equals('actif'),
            ))
            .get();
    String? compte(int n, String phrase) =>
        n == 0 ? null : '$n ${n > 1 ? 'enseignants' : 'enseignant'} $phrase';
    switch (code) {
      case 'B1':
        return [
          ?compte(
            enseignants.where((t) => t.matricule == null).length,
            'sans matricule',
          ),
          ?compte(
            enseignants.where((t) => t.seniorityGeneralFrom == null).length,
            'sans date de départ de l’ancienneté générale',
          ),
        ];
      case 'B2':
        final eleves = await (db.select(
          db.students,
        )..where((s) => s.schoolId.equals(schoolId))).get();
        final attente = enAttenteB2(eleves);
        final sansNaissance = eleves.where((s) => s.birthDate == null).length;
        final pl = attente > 1;
        final numeros =
            '$attente élève${pl ? 's' : ''} attend${pl ? 'ent' : ''} son '
            'numéro d’ordre : synchronisez avant d’imprimer.';
        return [
          if (attente > 0) numeros,
          if (sansNaissance > 0)
            '$sansNaissance élève(s) sans date de naissance',
        ];
      default:
        return [
          ?compte(
            enseignants.where((t) => t.communeNominationDate == null).length,
            'sans date de nomination dans la commune',
          ),
          ?compte(
            enseignants.where((t) => t.tenureStatus == null).length,
            'sans « T ou S »',
          ),
        ];
    }
  }

  static String _iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
