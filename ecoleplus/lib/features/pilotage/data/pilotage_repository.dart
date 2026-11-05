import 'package:drift/drift.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/features/maternelle/data/maternelle_repository.dart';
import 'package:ecoleplus/features/pilotage/domain/emploi_du_temps.dart';
import 'package:uuid/uuid.dart';

/// Emploi du temps et appel du jour : écriture hors ligne, synchronisée.
class PilotageRepository {
  new(this.store);

  final LocalStore store;
  static const _uuid = Uuid();

  AppDatabase get db => store.db;

  // --------------------------- Emploi du temps ---------------------------

  Stream<List<TimetableSlotRow>> watchCreneaux(String classId) =>
      (db.select(db.timetableSlots)
            ..where((s) => s.classId.equals(classId) & s.deletedAt.isNull()))
          .watch()
          .map(trierCreneaux);

  Stream<List<TimetableSlotRow>> watchCreneauxEcole(String schoolId) =>
      (db.select(db.timetableSlots)
            ..where((s) => s.schoolId.equals(schoolId) & s.deletedAt.isNull()))
          .watch()
          .map(trierCreneaux);

  /// Crée ([id] null) ou modifie un créneau. Le contrôle des chevauchements
  /// est fait par l'écran ([verifierCreneau]).
  Future<void> enregistrerCreneau({
    required String schoolId,
    required String classId,
    required int jour,
    required String debut,
    required String fin,
    String? id,
    String? matiereId,
    String? activite,
    String? enseignantId,
  }) => store.save('timetable_slots', {
    'id': id ?? _uuid.v4(),
    'school_id': schoolId,
    'class_id': classId,
    'weekday': jour,
    'starts_at': debut,
    'ends_at': fin,
    'subject_id': matiereId,
    'activity_label': matiereId == null ? activite : null,
    'teacher_id': enseignantId,
    'deleted_at': null,
  });

  Future<void> retirerCreneau(String id) => store.save('timetable_slots', {
    'id': id,
    'deleted_at': store.clock.nowIso(),
  });

  /// Copie l'emploi du temps de [source] vers [cible]. [remplacer] : les
  /// créneaux existants de la cible sont d'abord retirés ; sinon les
  /// créneaux qui chevauchent un créneau existant ne sont pas copiés.
  /// Rend le nombre de créneaux copiés.
  Future<int> copier(
    String source,
    String cible, {
    required bool remplacer,
  }) async {
    final de = await (db.select(
      db.timetableSlots,
    )..where((s) => s.classId.equals(source) & s.deletedAt.isNull())).get();
    var existants = await (db.select(
      db.timetableSlots,
    )..where((s) => s.classId.equals(cible) & s.deletedAt.isNull())).get();
    if (remplacer) {
      for (final s in existants) {
        await retirerCreneau(s.id);
      }
      existants = [];
    }
    var n = 0;
    for (final s in trierCreneaux(de)) {
      final debut = heureCourte(s.startsAt);
      final fin = heureCourte(s.endsAt);
      if (verifierCreneau(
            jour: s.weekday,
            debut: debut,
            fin: fin,
            existants: existants,
          ) !=
          null) {
        continue;
      }
      await enregistrerCreneau(
        schoolId: s.schoolId,
        classId: cible,
        jour: s.weekday,
        debut: debut,
        fin: fin,
        matiereId: s.subjectId,
        activite: s.activityLabel,
        // L'enseignant d'une autre classe n'est pas recopié.
      );
      n++;
    }
    return n;
  }

  // ------------------------------ Appel ------------------------------

  /// Présences d'une classe un jour : élève → (statut, motif).
  Stream<Map<String, (String, String?)>> watchAppel(
    String classId,
    String day,
  ) =>
      (db.select(db.attendance)..where(
            (a) =>
                a.classId.equals(classId) &
                a.day.equals(day) &
                a.deletedAt.isNull(),
          ))
          .watch()
          .map((l) => {for (final a in l) a.studentId: (a.status, a.reason)});

  /// Toutes les présences de l'école (une année tient sur le téléphone :
  /// environ 200 jours × effectif).
  Stream<List<AttendanceRow>> watchPresences(String schoolId) => (db.select(
    db.attendance,
  )..where((a) => a.schoolId.equals(schoolId) & a.deletedAt.isNull())).watch();

  /// Enregistre l'appel : une ligne par élève (présent par défaut), même
  /// identifiant que l'appel de la maternelle (élève + jour) : deux
  /// téléphones qui font l'appel le même jour fusionnent.
  Future<void> validerAppel(
    ClassRow classe,
    String day,
    Map<String, (String, String?)> statuts,
  ) async {
    for (final MapEntry(key: eleve, value: (statut, motif))
        in statuts.entries) {
      await store.save('attendance', {
        'id': MaternelleRepository.idPresence(eleve, day),
        'school_id': classe.schoolId,
        'class_id': classe.id,
        'student_id': eleve,
        'day': day,
        'status': statut,
        'reason': statut == 'present' ? null : motif,
        'deleted_at': null,
      });
    }
  }

  // ------------------------- Fiches (recherche) -------------------------

  Future<List<LessonPrepRow>> fichesDe(String userId) => (db.select(
    db.lessonPreps,
  )..where((f) => f.authorId.equals(userId) & f.deletedAt.isNull())).get();
}
