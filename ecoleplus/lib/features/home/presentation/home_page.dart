import 'package:ecoleplus/app/app.dart';
import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/options/domain/module_rules.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/security/domain/journal.dart';
import 'package:ecoleplus/features/security/presentation/security_providers.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:ecoleplus/features/sync/domain/sync_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Accueil : gros boutons selon le profil (8 au plus).
class HomePage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;
    if (session == null) return const Scaffold();
    final school = ref.watch(schoolProvider(session.schoolId)).value;
    final isDirector = session.role == 'directeur';
    return EcoleScaffold(
      title: school?.name ?? appName,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Bonjour ${session.displayName}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const _Alertes(),
          const SizedBox(height: 8),
          if (isDirector) ...[
            ..._boutonsEcole(context, tousLesDroits, enseignant: false),
            BigButton(
              icon: Icons.account_balance,
              label: 'Mon école',
              onPressed: () => context.push('/ecole'),
            ),
            const SizedBox(height: 12),
            BigButton(
              icon: Icons.people,
              label: 'Personnes et droits',
              onPressed: () => context.push('/personnes'),
            ),
            const SizedBox(height: 12),
            BigButton(
              icon: Icons.shield_outlined,
              label: 'Sécurité',
              onPressed: () => context.push('/securite'),
            ),
          ] else ...[
            ..._boutonsEcole(
              context,
              ref.watch(mesDroitsProvider),
              enseignant: session.role == 'enseignant',
            ),
            BigButton(
              icon: Icons.person,
              label: 'Mon compte',
              onPressed: () => context.push('/compte'),
            ),
            const SizedBox(height: 12),
            _NonDirectorHome(
              role: session.role,
              membershipId: session.membershipId,
            ),
          ],
          const SizedBox(height: 32),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final pending = await ref.read(localStoreProvider).pendingCount();
    if (!context.mounted) return;
    final ok = await confirmer(
      context,
      titre: 'Se déconnecter ?',
      message: pending == 0
          ? 'Les données de l’école seront retirées de ce téléphone. Elles '
                'restent sur le serveur.'
          : 'Attention : $pending élément(s) ne sont pas encore envoyés. '
                'Si vous vous déconnectez maintenant, ils seront perdus. '
                'Connectez-vous à Internet et attendez « Tout est '
                'synchronisé » avant de vous déconnecter.',
      bouton: pending == 0 ? 'Se déconnecter' : 'Se déconnecter quand même',
    );
    if (ok) await ref.read(authServiceProvider).logout();
  }
}

class _NonDirectorHome extends ConsumerWidget {
  const new({required this.role, required this.membershipId});
  final String role;
  final String membershipId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final droits =
        ref.watch(permissionsProvider(membershipId)).value ?? const <String>{};
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role == 'enseignant' ? 'Enseignant' : 'Délégué du directeur',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (role == 'delegue') ...[
              Text(
                droits.isEmpty
                    ? 'Le directeur ne vous a encore accordé aucun droit.'
                    : 'Droits accordés : ${_libelles(droits)}.',
              ),
              const SizedBox(height: 8),
            ],
            const Text(
              'Les autres fonctions (notes, bulletins…) arriveront dans les '
              'prochaines versions de l’application.',
            ),
          ],
        ),
      ),
    );
  }
}

/// Boutons des élèves, classes, enseignants et registres selon les droits.
List<Widget> _boutonsEcole(
  BuildContext context,
  Set<String> droits, {
  required bool enseignant,
}) {
  final eleves = droits.contains('eleves') || droits.contains('registres');
  final registres = droits.contains('registres');
  final notes = enseignant || registres || droits.contains('formulaires');
  Widget bouton(IconData icon, String label, String route) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: BigButton(
      icon: icon,
      label: label,
      onPressed: () => context.push(route),
    ),
  );
  return [
    if (enseignant) ...[
      bouton(Icons.school, 'Mes élèves', '/eleves'),
      bouton(Icons.class_, 'Ma classe', '/classes'),
    ],
    if (eleves) ...[
      bouton(Icons.school, 'Élèves', '/eleves'),
      bouton(Icons.class_, 'Classes', '/classes'),
    ],
    if (registres) ...[
      bouton(Icons.badge, 'Enseignants', '/enseignants'),
      bouton(Icons.menu_book, 'Registres et formulaires', '/registres'),
    ],
    if (notes) bouton(Icons.grading, 'Notes et classement', '/notes'),
  ];
}

String _libelles(Set<String> droits) =>
    droits.map((d) => droitsDelegables[d] ?? d).join(', ');

/// Alertes de l'accueil : données non envoyées (alerte conditionnelle),
/// événements de sécurité non lus (directeur), question secrète à choisir.
class _Alertes extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;
    final pending = ref.watch(pendingInfoProvider).value;
    final composition = ref.watch(periodeCompositionProvider).value ?? false;
    final journal = ref.watch(journalProvider).value ?? const [];
    final question = ref.watch(hasRecoveryQuestionProvider).value;
    if (session == null) return const SizedBox.shrink();
    final sync = pending == null
        ? null
        : alerteSynchronisation(
            enAttente: pending.$1,
            plusAncienneAttente: pending.$2,
            derniereSynchro: session.lastSyncAt == null
                ? null
                : DateTime.parse(session.lastSyncAt!),
            maintenant: DateTime.now().toUtc(),
            periodeComposition: composition,
          );
    final vu = session.journalSeenAt;
    final securite = session.role == 'directeur'
        ? journal.where((r) {
            if (vu != null && r.occurredAt.compareTo(vu) <= 0) return false;
            if (r.actorId == session.userId && r.action == 'connexion') {
              return false;
            }
            return decrireEvenement(
              action: r.action,
              table: r.affectedTable,
              detailsJson: r.details,
              acteur: '',
            ).securite;
          }).length
        : 0;
    return Column(
      children: [
        if (sync != null)
          _AlerteCarte(
            icon: Icons.cloud_off,
            texte: sync,
            onTap: () => context.push('/synchronisation'),
          ),
        if (securite > 0)
          _AlerteCarte(
            icon: Icons.shield_outlined,
            texte: securite == 1
                ? '1 événement de sécurité à voir'
                : '$securite événements de sécurité à voir',
            onTap: () => context.push('/securite/journal'),
          ),
        if (question == false)
          _AlerteCarte(
            icon: Icons.help_outline,
            texte:
                'Choisissez une question secrète : elle vous permettra de '
                'retrouver l’accès si vous oubliez votre mot de passe.',
            onTap: () => context.push('/compte/question'),
          ),
      ],
    );
  }
}

class _AlerteCarte extends StatelessWidget {
  const new({required this.icon, required this.texte, required this.onTap});
  final IconData icon;
  final String texte;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.errorContainer,
    child: ListTile(
      leading: Icon(icon),
      title: Text(texte),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
