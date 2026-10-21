import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/features/auth/presentation/create_school_page.dart';
import 'package:ecoleplus/features/auth/presentation/forgot_password_page.dart';
import 'package:ecoleplus/features/auth/presentation/login_page.dart';
import 'package:ecoleplus/features/auth/presentation/welcome_page.dart';
import 'package:ecoleplus/features/backup/presentation/backup_page.dart';
import 'package:ecoleplus/features/home/presentation/home_page.dart';
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
      GoRoute(path: '/securite', builder: (_, _) => const SecurityPage()),
      GoRoute(
        path: '/securite/telephones',
        builder: (_, _) => const DevicesPage(),
      ),
      GoRoute(
        path: '/securite/journal',
        builder: (_, _) => const JournalPage(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
