import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/documents/data/documents_repository.dart';
import 'package:ecoleplus/features/documents/domain/documents_directeur.dart';
import 'package:ecoleplus/features/forms/data/forms_repository.dart';
import 'package:ecoleplus/features/programme/domain/programme.dart';
import 'package:uuid/uuid.dart';

/// Programme d'activités (B6) et bilan (B7) : un seul jeu de lignes
/// « objectif → activités » ; une version finale verrouille son
/// formulaire, « Modifier » le rouvre et l'ancienne version reste.
class ProgrammeRepository {
  new(this.store);

  final LocalStore store;
  AppDatabase get db => store.db;

  static const _uuid = Uuid();

  // ------------------------------ Lecture ------------------------------

  /// Objectifs de l'année avec leurs activités, dans l'ordre.
  Stream<List<ObjectifProgramme>> watchObjectifs(String yearId) {
    final o = db.activityObjectives;
    final l = db.activityLines;
    final q =
        db.select(o).join([
            leftOuterJoin(
              l,
              l.objectiveId.equalsExp(o.id) & l.deletedAt.isNull(),
            ),
          ])
          ..where(o.schoolYearId.equals(yearId) & o.deletedAt.isNull())
          ..orderBy([
            OrderingTerm.asc(o.orderNo),
            OrderingTerm.asc(o.createdAt),
            OrderingTerm.asc(l.sortOrder),
            OrderingTerm.asc(l.createdAt),
          ]);
    return q.watch().map((rangs) {
      final objectifs =
          <String, (ActivityObjectiveRow, List<ActivityLineRow>)>{};
      for (final r in rangs) {
        final obj = r.readTable(o);
        final e = objectifs.putIfAbsent(obj.id, () => (obj, []));
        final ligne = r.readTableOrNull(l);
        if (ligne != null) e.$2.add(ligne);
      }
      return [
        for (final (obj, lignes) in objectifs.values)
          ObjectifProgramme(
            id: obj.id,
            libelle: obj.label,
            activites: [for (final x in lignes) _activite(x)],
          ),
      ];
    });
  }

  static ActiviteProgramme _activite(ActivityLineRow x) => ActiviteProgramme(
    id: x.id,
    activite: x.plannedActivity,
    echeanceDate: x.deadlineOn,
    echeanceTexte: x.deadlineText,
    contrainte: x.constraintText,
    attendu: x.expectedResult,
    atteint: x.achievedResult,
    taux: x.successRate,
  );

  Stream<ActivityLineRow?> watchActivite(String id) => (db.select(
    db.activityLines,
  )..where((x) => x.id.equals(id))).watchSingleOrNull();

  Stream<List<FormVersionRow>> watchVersions(String yearId, String code) =>
      (db.select(db.formVersions)
            ..where(
              (v) =>
                  v.formId.equals(FormsRepository.idFormulaire(yearId, code)),
            )
            ..orderBy([(v) => OrderingTerm.desc(v.versionNo)]))
          .watch();

  // ----------------------------- Objectifs -----------------------------

  Future<String> ajouterObjectif(
    String schoolId,
    String yearId,
    String libelle, {
    List<String> activites = const [],
  }) async {
    final max =
        await (db.selectOnly(db.activityObjectives)
              ..addColumns([db.activityObjectives.orderNo.max()])
              ..where(
                db.activityObjectives.schoolYearId.equals(yearId) &
                    db.activityObjectives.deletedAt.isNull(),
              ))
            .map((r) => r.read(db.activityObjectives.orderNo.max()))
            .getSingle();
    final id = _uuid.v4();
    await store.save('activity_objectives', {
      'id': id,
      'school_id': schoolId,
      'school_year_id': yearId,
      'order_no': (max ?? 0) + 1,
      'label': libelle.trim(),
    });
    for (final a in activites) {
      await ajouterActivite(schoolId, id, a);
    }
    return id;
  }

  Future<void> renommerObjectif(String id, String libelle) =>
      store.save('activity_objectives', {'id': id, 'label': libelle.trim()});

  /// Retire l'objectif et ses activités (effacement doux, synchronisé).
  Future<void> supprimerObjectif(String id) async {
    final now = store.clock.nowIso();
    final lignes = await (db.select(
      db.activityLines,
    )..where((x) => x.objectiveId.equals(id) & x.deletedAt.isNull())).get();
    for (final x in lignes) {
      await store.save('activity_lines', {'id': x.id, 'deleted_at': now});
    }
    await store.save('activity_objectives', {'id': id, 'deleted_at': now});
  }

  /// Monte (-1) ou descend (+1) un objectif ; le N° d'ordre imprimé est sa
  /// position.
  Future<void> deplacerObjectif(String yearId, String id, int sens) async {
    final tous =
        await (db.select(db.activityObjectives)
              ..where(
                (o) => o.schoolYearId.equals(yearId) & o.deletedAt.isNull(),
              )
              ..orderBy([
                (o) => OrderingTerm.asc(o.orderNo),
                (o) => OrderingTerm.asc(o.createdAt),
              ]))
            .get();
    final i = tous.indexWhere((o) => o.id == id);
    final j = i + sens;
    if (i < 0 || j < 0 || j >= tous.length) return;
    final ordre = [...tous];
    ordre.insert(j, ordre.removeAt(i));
    for (final (k, o) in ordre.indexed) {
      if (o.orderNo != k + 1) {
        await store.save('activity_objectives', {
          'id': o.id,
          'order_no': k + 1,
        });
      }
    }
  }

  // ----------------------------- Activités -----------------------------

  Future<String> ajouterActivite(
    String schoolId,
    String objectifId,
    String activite,
  ) async {
    final max =
        await (db.selectOnly(db.activityLines)
              ..addColumns([db.activityLines.sortOrder.max()])
              ..where(
                db.activityLines.objectiveId.equals(objectifId) &
                    db.activityLines.deletedAt.isNull(),
              ))
            .map((r) => r.read(db.activityLines.sortOrder.max()))
            .getSingle();
    final id = _uuid.v4();
    await store.save('activity_lines', {
      'id': id,
      'school_id': schoolId,
      'objective_id': objectifId,
      'sort_order': (max ?? 0) + 1,
      'planned_activity': activite.trim(),
    });
    return id;
  }

  Future<void> modifierActivite(String id, Map<String, Object?> champs) =>
      store.save('activity_lines', {'id': id, ...champs});

  Future<void> supprimerActivite(String id) => store.save('activity_lines', {
    'id': id,
    'deleted_at': store.clock.nowIso(),
  });

  // ------------------------------ Versions -----------------------------

  /// Ce qui serait imprimé maintenant.
  Future<DonneesProgramme> donnees(
    FormulaireActivites f,
    SchoolRow ecole,
    String yearId,
  ) async {
    final form =
        await (db.select(db.officialForms)..where(
              (x) => x.id.equals(FormsRepository.idFormulaire(yearId, f.code)),
            ))
            .getSingleOrNull();
    final signataire = DocumentsRepository.signataire(ecole);
    final nom = form?.directorName?.trim();
    return DonneesProgramme(
      formulaire: f,
      entete: await DocumentsRepository(store).entete(ecole),
      objectifs: await watchObjectifs(yearId).first,
      signataire: nom == null || nom.isEmpty
          ? signataire
          : Signataire(
              civilite: signataire.civilite,
              nom: nom,
              grade: signataire.grade,
            ),
      faitA: form?.signedPlace ?? ecole.commune,
      faitLe: form?.signedOn,
      moyenneParObjectif: form?.showObjectiveAverage ?? false,
    );
  }

  /// Valide la version finale : instantané de ce qui est imprimé, puis
  /// verrou du formulaire. Renvoie le numéro de la version.
  Future<int> validerVersionFinale(
    FormulaireActivites f,
    SchoolRow ecole,
    String yearId,
  ) async {
    final formId = FormsRepository.idFormulaire(yearId, f.code);
    final d = await donnees(f, ecole, yearId);
    final derniere =
        await (db.selectOnly(db.formVersions)
              ..addColumns([db.formVersions.versionNo.max()])
              ..where(db.formVersions.formId.equals(formId)))
            .map((r) => r.read(db.formVersions.versionNo.max()))
            .getSingle();
    final n = (derniere ?? 0) + 1;
    final forms = FormsRepository(store);
    // Le formulaire doit exister avant sa version (clé étrangère).
    await forms.enregistrer(ecole.id, yearId, f.code, {'status': 'complet'});
    await store.save('form_versions', {
      // Même numéro sur deux téléphones : une seule version au serveur.
      'id': _uuid.v5(Namespace.url.value, 'ecoleplus:$formId:version:$n'),
      'school_id': ecole.id,
      'form_id': formId,
      'version_no': n,
      'is_final': true,
      'snapshot': d.versJson(),
    });
    await forms.enregistrer(ecole.id, yearId, f.code, {'locked_version': n});
    return n;
  }

  /// « Modifier » : le formulaire redevient modifiable ; la version finale
  /// reste conservée telle quelle.
  Future<void> deverrouiller(String schoolId, String yearId, String code) =>
      FormsRepository(store).enregistrer(schoolId, yearId, code, {
        'locked_version': null,
        'status': 'a_completer',
      });

  static DonneesProgramme instantane(FormVersionRow v) =>
      DonneesProgramme.depuisJson(
        jsonDecode(v.snapshot) as Map<String, dynamic>,
      );
}
