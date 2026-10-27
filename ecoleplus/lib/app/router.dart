import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/features/auth/presentation/create_school_page.dart';
import 'package:ecoleplus/features/auth/presentation/forgot_password_page.dart';
import 'package:ecoleplus/features/auth/presentation/login_page.dart';
import 'package:ecoleplus/features/auth/presentation/welcome_page.dart';
import 'package:ecoleplus/features/backup/presentation/backup_page.dart';
import 'package:ecoleplus/features/bulletins/presentation/bulletins_pages.dart';
import 'package:ecoleplus/features/classes/presentation/classes_pages.dart';
import 'package:ecoleplus/features/documents/domain/documents_directeur.dart';
import 'package:ecoleplus/features/documents/presentation/documents_pages.dart';
import 'package:ecoleplus/features/forms/presentation/fiche_scolarite_page.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/grades/presentation/classement_page.dart';
import 'package:ecoleplus/features/grades/presentation/grades_pages.dart';
import 'package:ecoleplus/features/grades/presentation/saisie_vocale_page.dart';
import 'package:ecoleplus/features/home/presentation/home_page.dart';
import 'package:ecoleplus/features/import/presentation/import_page.dart';
import 'package:ecoleplus/features/lock/presentation/lock_pages.dart';
import 'package:ecoleplus/features/lock/presentation/lock_providers.dart';
import 'package:ecoleplus/features/members/presentation/add_member_page.dart';
import 'package:ecoleplus/features/members/presentation/members_page.dart';
import 'package:ecoleplus/features/options/presentation/options_page.dart';
import 'package:ecoleplus/features/school/presentation/headers_page.dart';
import 'package:ecoleplus/features/school/presentation/school_page.dart';
import 'package:ecoleplus/features/school/presentation/years_page.dart';
import 'package:ecoleplus/features/security/presentation/account_pages.dart';
import 'package:ecoleplus/features/security/presentation/security_pages.dart';
import 'package:ecoleplus/features/staff/presentation/teachers_pages.dart';
import 'package:ecoleplus/features/students/presentation/students_pages.dart';
import 'package:ecoleplus/features/sync/presentation/sync_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _publicRoutes = {
  '/bienvenue',
  '/connexion',
  '/creer-ecole',
  '/mot-de-passe-oublie',
};

/// Pages réservées au directeur (les droits sont de toute façon vérifiés par
/// le serveur ; ceci évite seulement d'afficher un écran inutile).
const _directorRoutes = {
  '/ecole',
  '/annees',
  '/personnes',
  '/options',
  '/sauvegarde',
  '/securite',
  '/mentions',
  '/bulletins-modele',
};

const _lockRoutes = {'/verrouille', '/verrouille/mot-de-passe'};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref
    ..listen(sessionProvider, (_, _) => refresh.value++)
    ..listen(appLockProvider, (_, _) => refresh.value++)
    ..listen(lockedProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  final router = GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      if (session.isLoading) return null;
      final s = session.value;
      final path = state.matchedLocation;
      if (s == null) {
        return _publicRoutes.contains(path) ? null : '/bienvenue';
      }
      // Verrouillage : un code est obligatoire, demandé à l'ouverture.
      final lock = ref.read(appLockProvider);
      if (lock.isLoading) return null;
      if (lock.value == null) {
        return path == '/code/creer' || path == '/verrouille/mot-de-passe'
            ? null
            : '/code/creer';
      }
      if (ref.read(lockedProvider)) {
        return _lockRoutes.contains(path) ? null : '/verrouille';
      }
      if (_publicRoutes.contains(path) || _lockRoutes.contains(path)) {
        return '/';
      }
      if (s.role != 'directeur' &&
          _directorRoutes.any((r) => path == r || path.startsWith('$r/'))) {
        // Les en-têtes restent consultables par tous ; le reste non.
        if (!path.startsWith('/annees/')) return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomePage()),
      GoRoute(path: '/bienvenue', builder: (_, _) => const WelcomePage()),
      GoRoute(path: '/connexion', builder: (_, _) => const LoginPage()),
      GoRoute(
        path: '/mot-de-passe-oublie',
        builder: (_, _) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/creer-ecole',
        builder: (_, _) => const CreateSchoolPage(),
      ),
      GoRoute(path: '/ecole', builder: (_, _) => const SchoolPage()),
      GoRoute(path: '/annees', builder: (_, _) => const YearsPage()),
      GoRoute(
        path: '/annees/:id',
        builder: (_, s) => HeadersPage(yearId: s.pathParameters['id']!),
      ),
      GoRoute(path: '/personnes', builder: (_, _) => const MembersPage()),
      GoRoute(
        path: '/personnes/ajouter',
        builder: (_, _) => const AddMemberPage(),
      ),
      GoRoute(path: '/options', builder: (_, _) => const OptionsPage()),
      GoRoute(path: '/sauvegarde', builder: (_, _) => const BackupPage()),
      GoRoute(path: '/synchronisation', builder: (_, _) => const SyncPage()),
      GoRoute(path: '/code/creer', builder: (_, _) => const CreatePinPage()),
      GoRoute(path: '/verrouille', builder: (_, _) => const LockPage()),
      GoRoute(
        path: '/verrouille/mot-de-passe',
        builder: (_, _) => const PasswordUnlockPage(),
      ),
      GoRoute(path: '/compte', builder: (_, _) => const AccountPage()),
      GoRoute(
        path: '/compte/question',
        builder: (_, _) => const RecoveryQuestionPage(),
      ),
      GoRoute(
        path: '/compte/numero',
        builder: (_, _) => const LoginPhonePage(),
      ),
      GoRoute(path: '/securite', builder: (_, _) => const SecurityPage()),
      GoRoute(path: '/enseignants', builder: (_, _) => const TeachersPage()),
      GoRoute(path: '/classes', builder: (_, _) => const ClassesPage()),
      GoRoute(
        path: '/classes/:id',
        builder: (_, s) => ClassPage(s.pathParameters['id']!),
      ),
      GoRoute(path: '/eleves', builder: (_, _) => const StudentsPage()),
      // Ancienne adresse « Registres et formulaires » : tout est dans
      // « Documents » (A17).
      GoRoute(path: '/registres', builder: (_, _) => const DocumentsPage()),
      GoRoute(path: '/documents', builder: (_, _) => const DocumentsPage()),
      GoRoute(
        path: '/documents/choisir/:code',
        builder: (_, s) => ChoisirPersonnePage(s.pathParameters['code']!),
      ),
      GoRoute(
        path: '/documents/:code/:id',
        builder: (_, s) => DocumentPage(
          CodeDocument.depuis(s.pathParameters['code']!) ??
              CodeDocument.certificatScolarite,
          s.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/registres/:code',
        builder: (_, s) => FormulairePage(s.pathParameters['code']!),
      ),
      GoRoute(
        path: '/import/eleves',
        builder: (_, _) => const ImportPage(TypeImport.eleves),
      ),
      GoRoute(
        path: '/import/enseignants',
        builder: (_, _) => const ImportPage(TypeImport.enseignants),
      ),
      GoRoute(
        path: '/eleves/:id/fiche',
        builder: (_, s) => FicheScolaritePage(s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/eleves/:id',
        builder: (_, s) => StudentPage(s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/enseignants/:id',
        builder: (_, s) => TeacherPage(s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/securite/telephones',
        builder: (_, _) => const DevicesPage(),
      ),
      GoRoute(
        path: '/securite/journal',
        builder: (_, _) => const JournalPage(),
      ),
      GoRoute(path: '/notes', builder: (_, _) => const NotesPage()),
      GoRoute(path: '/mentions', builder: (_, _) => const MentionsPage()),
      GoRoute(
        path: '/bulletins-modele',
        builder: (_, _) => const ModeleBulletinPage(),
      ),
      GoRoute(
        path: '/bulletins/:classId',
        builder: (_, s) => BulletinsPage(s.pathParameters['classId']!),
      ),
      GoRoute(
        path: '/notes/:classId',
        builder: (_, s) => ClasseNotesPage(s.pathParameters['classId']!),
      ),
      GoRoute(
        path: '/notes/:classId/matieres',
        builder: (_, s) => MatieresClassePage(s.pathParameters['classId']!),
      ),
      GoRoute(
        path: '/notes/:classId/classement',
        builder: (_, s) => ClassementPage(s.pathParameters['classId']!),
      ),
      GoRoute(
        path: '/notes/:classId/trimestre/:t',
        builder: (_, s) => SaisieNotesPage(
          s.pathParameters['classId']!,
          int.tryParse(s.pathParameters['t']!) ?? 1,
        ),
      ),
      GoRoute(
        path: '/notes/:classId/vocal/:t/:subjectId',
        builder: (_, s) => SaisieVocalePage(
          s.pathParameters['classId']!,
          int.tryParse(s.pathParameters['t']!) ?? 1,
          s.pathParameters['subjectId']!,
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
