import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/features/auth/presentation/create_school_page.dart';
import 'package:ecoleplus/features/auth/presentation/forgot_password_page.dart';
import 'package:ecoleplus/features/auth/presentation/login_page.dart';
import 'package:ecoleplus/features/auth/presentation/welcome_page.dart';
import 'package:ecoleplus/features/backup/presentation/backup_page.dart';
import 'package:ecoleplus/features/bibliotheque/data/bibliotheque_repository.dart';
import 'package:ecoleplus/features/bibliotheque/domain/document.dart';
import 'package:ecoleplus/features/bibliotheque/presentation/bibliotheque_pages.dart';
import 'package:ecoleplus/features/bulletins/presentation/bulletins_pages.dart';
import 'package:ecoleplus/features/cartes/presentation/cartes_pages.dart';
import 'package:ecoleplus/features/classes/presentation/classes_pages.dart';
import 'package:ecoleplus/features/documents/domain/documents_directeur.dart';
import 'package:ecoleplus/features/documents/presentation/documents_pages.dart';
import 'package:ecoleplus/features/finances/presentation/finances_gestion_pages.dart';
import 'package:ecoleplus/features/finances/presentation/finances_pages.dart';
import 'package:ecoleplus/features/forms/presentation/apercu_pdf_page.dart';
import 'package:ecoleplus/features/forms/presentation/fiche_scolarite_page.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/grades/presentation/classement_page.dart';
import 'package:ecoleplus/features/grades/presentation/grades_pages.dart';
import 'package:ecoleplus/features/grades/presentation/saisie_vocale_page.dart';
import 'package:ecoleplus/features/home/presentation/home_page.dart';
import 'package:ecoleplus/features/import/presentation/import_page.dart';
import 'package:ecoleplus/features/lock/presentation/lock_pages.dart';
import 'package:ecoleplus/features/lock/presentation/lock_providers.dart';
import 'package:ecoleplus/features/maternelle/presentation/maternelle_pages.dart';
import 'package:ecoleplus/features/medical/presentation/medical_pages.dart';
import 'package:ecoleplus/features/members/presentation/add_member_page.dart';
import 'package:ecoleplus/features/members/presentation/members_page.dart';
import 'package:ecoleplus/features/options/presentation/options_page.dart';
import 'package:ecoleplus/features/programme/presentation/programme_pages.dart';
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
        path: '/apercu',
        builder: (_, s) => ApercuPdfPage(s.extra! as ApercuPdf),
      ),
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
        path: '/maternelle/reglages',
        builder: (_, _) => const MaternelleReglagesPage(),
      ),
      GoRoute(
        path: '/maternelle/classe/:id',
        builder: (_, s) => ClasseMaternellePage(s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/maternelle/classe/:id/presences',
        builder: (_, s) => PresencesPage(s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/maternelle/classe/:id/t/:t/enfant/:eleve',
        builder: (_, s) => EvaluationEnfantPage(
          s.pathParameters['id']!,
          int.parse(s.pathParameters['t']!),
          s.pathParameters['eleve']!,
        ),
      ),
      GoRoute(path: '/cartes', builder: (_, _) => const CartesPage()),
      GoRoute(
        path: '/formulaires',
        builder: (_, _) => const FormulairesAnneePage(),
      ),
      GoRoute(
        path: '/programme/:code',
        builder: (_, s) => ProgrammePage(s.pathParameters['code']!),
      ),
      GoRoute(
        path: '/programme/:code/activite/:id',
        builder: (_, s) =>
            ActivitePage(s.pathParameters['code']!, s.pathParameters['id']!),
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
        path: '/eleves/:id/medical',
        builder: (_, s) => FicheMedicalePage(s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/medical/journal',
        builder: (_, _) => const JournalMedicalPage(),
      ),
      GoRoute(
        path: '/medical/information',
        builder: (_, _) => const InformationParentsPage(),
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
      GoRoute(
        path: '/bibliotheque',
        builder: (_, _) => const BibliothequePage(Espace.bibliotheque),
      ),
      GoRoute(
        path: '/bibliotheque/corbeille',
        builder: (_, _) =>
            const BibliothequePage(Espace.bibliotheque, corbeille: true),
      ),
      GoRoute(
        path: '/bibliotheque/ajout',
        builder: (_, s) => AjoutDocumentsPage(
          Espace.bibliotheque,
          s.extra as List<FichierChoisi>? ?? const [],
        ),
      ),
      GoRoute(
        path: '/archives',
        builder: (_, _) => const BibliothequePage(Espace.archives),
      ),
      GoRoute(
        path: '/archives/corbeille',
        builder: (_, _) =>
            const BibliothequePage(Espace.archives, corbeille: true),
      ),
      GoRoute(
        path: '/archives/ajout',
        builder: (_, s) => AjoutDocumentsPage(
          Espace.archives,
          s.extra as List<FichierChoisi>? ?? const [],
        ),
      ),
      GoRoute(
        path: '/document/:id',
        builder: (_, s) => FicheDocumentPage(s.pathParameters['id']!),
      ),
      GoRoute(path: '/finances', builder: (_, _) => const FinancesPage()),
      GoRoute(
        path: '/finances/encaisser',
        builder: (_, s) =>
            EncaissementPage(eleveId: s.uri.queryParameters['eleve']),
      ),
      GoRoute(
        path: '/finances/recu/:id',
        builder: (_, s) => RecuPage(s.pathParameters['id']!),
      ),
      GoRoute(path: '/finances/recus', builder: (_, _) => const RecusPage()),
      GoRoute(
        path: '/finances/eleves',
        builder: (_, _) => const ElevesFinancesPage(),
      ),
      GoRoute(
        path: '/finances/eleve/:id',
        builder: (_, s) => SituationElevePage(s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/finances/impayes',
        builder: (_, _) => const ImpayesPage(),
      ),
      GoRoute(path: '/finances/grille', builder: (_, _) => const GrillePage()),
      GoRoute(
        path: '/finances/grille/:id',
        builder: (_, s) => LigneFraisPage(s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/finances/remises',
        builder: (_, _) => const RemisesPage(),
      ),
      GoRoute(
        path: '/finances/depenses',
        builder: (_, _) => const DepensesPage(),
      ),
      GoRoute(
        path: '/finances/depense/nouvelle',
        builder: (_, _) => const NouvelleDepensePage(),
      ),
      GoRoute(
        path: '/finances/depense/:id',
        builder: (_, s) => DepensePage(s.pathParameters['id']!),
      ),
      GoRoute(path: '/finances/caisse', builder: (_, _) => const CaissePage()),
      GoRoute(
        path: '/finances/rapports',
        builder: (_, _) => const RapportsFinancesPage(),
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
