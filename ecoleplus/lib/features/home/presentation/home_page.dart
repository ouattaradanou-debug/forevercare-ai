import 'package:ecoleplus/app/app.dart';
import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/options/domain/module_rules.dart';
import 'package:ecoleplus/features/pilotage/presentation/accueil_pages.dart';
import 'package:ecoleplus/features/pilotage/presentation/bord_pages.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/security/domain/journal.dart';
import 'package:ecoleplus/features/security/presentation/security_providers.dart';
import 'package:ecoleplus/features/sync/domain/sync_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Accueil par thèmes (phase 13) : 8 gros boutons au plus. Directeur :
/// tableau de bord et recherche en haut, puis les thèmes ; enseignant :
/// « Ma journée », puis sa classe. Les modules désactivés n'apparaissent
/// pas.
class HomePage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;
    if (session == null) return const Scaffold();
    final school = ref.watch(schoolProvider(session.schoolId)).value;
    final themes = ref.watch(themesProvider);
    final directeur = session.role == 'directeur';
    final enseignant = session.role == 'enseignant';
    return EcoleScaffold(
      title: school?.name ?? appName,
      actions: const [ClocheNotifications()],
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
          if (enseignant) ...[const MaJournee(), const SizedBox(height: 12)],
          Row(
            children: [
              if (directeur || enseignant) ...[
                Expanded(
                  child: _Raccourci(
                    icon: Icons.dashboard_outlined,
                    label: enseignant
                        ? 'Mon tableau de bord'
                        : 'Tableau de bord',
                    route: '/tableau-de-bord',
                  ),
                ),
                const SizedBox(width: 12),
              ],
              const Expanded(
                child: _Raccourci(
                  icon: Icons.search,
                  label: 'Rechercher',
                  route: '/recherche',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final t in themes) ...[
            BigButton(
              key: Key('theme-${t.id}'),
              icon: t.icone,
              label: t.label,
              onPressed: () => context.push(t.route),
            ),
            const SizedBox(height: 12),
          ],
          if (session.role == 'delegue')
            _NonDirectorHome(
              role: session.role,
              membershipId: session.membershipId,
            ),
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

/// Raccourci de l'accueil (tableau de bord, recherche).
class _Raccourci extends StatelessWidget {
  const new({required this.icon, required this.label, required this.route});
  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) => FilledButton.tonalIcon(
    style: FilledButton.styleFrom(minimumSize: const Size(0, 64)),
    onPressed: () => context.push(route),
    icon: Icon(icon),
    label: Text(label, textAlign: TextAlign.center),
  );
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
          ],
        ),
      ),
    );
  }
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
