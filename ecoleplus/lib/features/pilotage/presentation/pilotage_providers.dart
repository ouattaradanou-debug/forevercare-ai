import 'package:drift/drift.dart';
import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/drafts/draft_store.dart';
import 'package:ecoleplus/features/grades/presentation/grades_pages.dart';
import 'package:ecoleplus/features/pilotage/data/pilotage_repository.dart';
import 'package:ecoleplus/features/pilotage/domain/absences.dart';
import 'package:ecoleplus/features/pilotage/domain/rapports.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:ecoleplus/features/students/data/students_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

final pilotageRepositoryProvider = Provider<PilotageRepository>(
  (ref) => PilotageRepository(ref.watch(localStoreProvider)),
);

/// École et année en cours (null : pas encore chargées).
(SchoolRow, SchoolYearRow)? contexteEcole(WidgetRef ref) {
  final session = ref.watch(sessionProvider).value;
  if (session == null) return null;
  final ecole = ref.watch(schoolProvider(session.schoolId)).value;
  final annee = ref
      .watch(yearsProvider(session.schoolId))
      .value
      ?.where((y) => y.id == ecole?.currentSchoolYearId)
      .firstOrNull;
  if (ecole == null || annee == null) return null;
  return (ecole, annee);
}

final StreamProviderFamily<List<TimetableSlotRow>, String> creneauxProvider =
    StreamProvider.family(
      (ref, classId) =>
          ref.watch(pilotageRepositoryProvider).watchCreneaux(classId),
    );

final StreamProviderFamily<List<TimetableSlotRow>, String>
creneauxEcoleProvider = StreamProvider.family(
  (ref, schoolId) =>
      ref.watch(pilotageRepositoryProvider).watchCreneauxEcole(schoolId),
);

/// Présences d'une période. Clé : (école, du, au).
final StreamProviderFamily<List<AttendanceRow>, (String, String, String)>
presencesPeriodeProvider = StreamProvider.family(
  (ref, k) => ref
      .watch(pilotageRepositoryProvider)
      .watchPresencesPeriode(k.$1, k.$2, k.$3),
);

/// Totaux d'une période (calculés par la base). Clé : (école, du, au).
final StreamProviderFamily<TotauxPresences, (String, String, String)>
totauxPresencesProvider = StreamProvider.family(
  (ref, k) =>
      ref.watch(pilotageRepositoryProvider).watchTotaux(k.$1, k.$2, k.$3),
);

final StreamProviderFamily<Map<String, (String, String?)>, (String, String)>
appelProvider = StreamProvider.family(
  (ref, k) => ref.watch(pilotageRepositoryProvider).watchAppel(k.$1, k.$2),
);

/// Élèves (présents, non sortis) d'une classe de l'année. Clé : (école,
/// année, classe).
final ProviderFamily<List<StudentRow>?, (String, String, String)>
elevesDeClasseProvider = Provider.family((ref, k) {
  final l = ref.watch(elevesProvider((k.$1, k.$2, false))).value;
  if (l == null) return null;
  return [
    for (final EleveDansAnnee e in l)
      if (e.classe?.id == k.$3) e.eleve,
  ];
});

/// Nom des matières de l'école : id → nom.
final StreamProviderFamily<Map<String, String>, String> nomsMatieresProvider =
    StreamProvider.family((ref, schoolId) {
      final db = ref.watch(databaseProvider);
      return (db.select(db.subjects)
            ..where((s) => s.schoolId.equals(schoolId) & s.deletedAt.isNull()))
          .watch()
          .map((l) => {for (final s in l) s.id: s.name});
    });

/// Peut modifier l'emploi du temps et faire l'appel de cette classe : le
/// directeur, un délégué « registres » (emploi du temps), l'enseignant
/// de la classe (le téléphone d'un enseignant ne reçoit que ses classes).
final ProviderFamily<bool, String> peutModifierEdtProvider = Provider.family((
  ref,
  classId,
) {
  final s = ref.watch(sessionProvider).value;
  if (s == null) return false;
  if (s.role == 'directeur') return true;
  if (s.role == 'delegue') {
    return ref.watch(mesDroitsProvider).contains('registres');
  }
  return true;
});

// ------------------------- Notifications lues -------------------------

const _cleLues = 'notifications_lues';

class NotificationsLues extends AsyncNotifier<Set<String>> {
  DraftStore get _store => DraftStore(ref.read(databaseProvider));

  @override
  Future<Set<String>> build() async {
    final m = await _store.load(_cleLues);
    return {...((m['ids'] as List?) ?? const []).cast<String>()};
  }

  Future<void> marquer(Iterable<String> ids) async {
    final l = {...state.value ?? const <String>{}, ...ids};
    // On ne garde que les 500 dernières.
    final garde = l.length > 500 ? l.skip(l.length - 500).toSet() : l;
    await _store.save(_cleLues, {'ids': garde.toList()});
    state = AsyncData(garde);
  }
}

final notificationsLuesProvider =
    AsyncNotifierProvider<NotificationsLues, Set<String>>(
      NotificationsLues.new,
    );

// ------------------------------ Résultats ------------------------------

/// Résultats de chaque classe notée de l'année. Clé : (année, trimestre,
/// seuil) ; trimestre 0 = l'année, null = le dernier trimestre noté de
/// chaque classe ; seuil null = la moitié du barème (en centièmes).
final FutureProviderFamily<List<ResultatsClasse>, (String, int?, int?)>
resultatsEcoleProvider = FutureProvider.autoDispose
    .family<List<ResultatsClasse>, (String, int?, int?)>((ref, k) async {
      final (yearId, t, seuil) = k;
      // Recalculé quand une note change.
      ref.watch(_notesModifieesProvider);
      final classes = await ref
          .watch(classesRepositoryProvider)
          .watchClasses(yearId)
          .first;
      final grades = ref.watch(gradesRepositoryProvider);
      final out = <ResultatsClasse>[];
      for (final c in classes) {
        final d = await grades.chargerDonnees(c.id);
        if (d == null || d.compositions.isEmpty || d.matieres.isEmpty) {
          continue;
        }
        final tr = t ?? d.dernierTrimestreNote;
        out.add(
          ResultatsClasse(
            c.name,
            tr == 0 ? d.annee() : d.trimestre(tr),
            tr == 0
                ? const []
                : [for (final m in d.matieresCalcul) (m.id, m.nom)],
            seuil: seuil ?? d.echelle ~/ 2,
          ),
        );
      }
      return out;
    });

final StreamProvider<String> _notesModifieesProvider =
    StreamProvider.autoDispose<String>((ref) {
      final db = ref.watch(databaseProvider);
      return db
          .customSelect(
            'SELECT COUNT(*) AS n, MAX(updated_at) AS m FROM grades',
            readsFrom: {db.grades},
          )
          .watch()
          .map((r) => '${r.first.data['n']}:${r.first.data['m']}');
    });
