import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/features/classes/data/classes_repository.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/staff/data/staff_repository.dart';
import 'package:ecoleplus/features/students/data/students_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

final staffRepositoryProvider = Provider<StaffRepository>(
  (ref) => StaffRepository(ref.watch(localStoreProvider)),
);
final classesRepositoryProvider = Provider<ClassesRepository>(
  (ref) => ClassesRepository(ref.watch(localStoreProvider)),
);

final StreamProviderFamily<List<TeacherRow>, String> teachersProvider =
    StreamProvider.family(
      (ref, schoolId) =>
          ref.watch(staffRepositoryProvider).watchTeachers(schoolId),
    );
final StreamProviderFamily<TeacherRow?, String> teacherProvider =
    StreamProvider.family(
      (ref, id) => ref.watch(staffRepositoryProvider).watchTeacher(id),
    );
final StreamProviderFamily<List<Map<String, dynamic>>, (Historique, String)>
historiqueProvider = StreamProvider.family(
  (ref, k) => ref.watch(staffRepositoryProvider).watchHistorique(k.$1, k.$2),
);
final StreamProviderFamily<TeacherAssignmentRow?, (String, String)>
assignmentProvider = StreamProvider.family(
  (ref, k) => ref.watch(staffRepositoryProvider).watchAssignment(k.$1, k.$2),
);
final StreamProviderFamily<List<TeacherAssignmentRow>, String>
assignmentsProvider = StreamProvider.family(
  (ref, yearId) => ref.watch(staffRepositoryProvider).watchAssignments(yearId),
);

final StreamProvider<List<LevelRow>> levelsProvider = StreamProvider(
  (ref) => ref.watch(classesRepositoryProvider).watchLevels(),
);
final StreamProviderFamily<List<ClassRow>, String> classesProvider =
    StreamProvider.family(
      (ref, yearId) =>
          ref.watch(classesRepositoryProvider).watchClasses(yearId),
    );
final StreamProviderFamily<Map<String, Effectif>, String> effectifsProvider =
    StreamProvider.family(
      (ref, yearId) =>
          ref.watch(classesRepositoryProvider).watchEffectifs(yearId),
    );

/// Droits de la personne connectée : tous pour le directeur, ceux accordés
/// pour un délégué, aucun pour un enseignant. Sert seulement à afficher les
/// bons écrans : le serveur vérifie chaque lecture et chaque écriture (RLS).
final Provider<Set<String>> mesDroitsProvider = Provider((ref) {
  final s = ref.watch(sessionProvider).value;
  if (s == null) return const {};
  if (s.role == 'directeur') return tousLesDroits;
  if (s.role != 'delegue') return const {};
  return ref.watch(permissionsProvider(s.membershipId)).value ?? const {};
});

const tousLesDroits = {
  'finances',
  'cartes',
  'eleves',
  'registres',
  'formulaires',
  'archives',
  'cantine',
};

final StreamProviderFamily<List<EleveDansAnnee>, (String, String, bool)>
elevesProvider = StreamProvider.family(
  (ref, k) => ref
      .watch(studentsRepositoryProvider)
      .watchEleves(k.$1, k.$2, avecSortis: k.$3),
);
final studentsRepositoryProvider = Provider<StudentsRepository>(
  (ref) => StudentsRepository(ref.watch(localStoreProvider)),
);
final StreamProviderFamily<StudentRow?, String> eleveProvider =
    StreamProvider.family(
      (ref, id) => ref.watch(studentsRepositoryProvider).watchEleve(id),
    );
final StreamProviderFamily<StudentRegistryRow?, String> registreProvider =
    StreamProvider.family(
      (ref, id) => ref.watch(studentsRepositoryProvider).watchRegistre(id),
    );
final StreamProviderFamily<List<GuardianRow>, String> parentsProvider =
    StreamProvider.family(
      (ref, id) => ref.watch(studentsRepositoryProvider).watchParents(id),
    );
final StreamProviderFamily<List<(EnrollmentRow, ClassRow?)>, String>
parcoursProvider = StreamProvider.family(
  (ref, id) => ref.watch(studentsRepositoryProvider).watchParcours(id),
);
