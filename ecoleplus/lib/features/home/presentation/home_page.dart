import 'package:ecoleplus/app/app.dart';
import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/options/domain/module_rules.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
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
          const SizedBox(height: 24),
          if (isDirector) ...[
            BigButton(
              icon: Icons.account_balance,
              label: 'Mon école',
              onPressed: () => context.push('/ecole'),
            ),
            const SizedBox(height: 12),
            BigButton(
              icon: Icons.calendar_month,
              label: 'Années scolaires',
              onPressed: () => context.push('/annees'),
            ),
            const SizedBox(height: 12),
            BigButton(
              icon: Icons.people,
              label: 'Personnes et droits',
              onPressed: () => context.push('/personnes'),
            ),
            const SizedBox(height: 12),
            BigButton(
              icon: Icons.tune,
              label: 'Options de l’école',
              onPressed: () => context.push('/options'),
            ),
            const SizedBox(height: 12),
            BigButton(
              icon: Icons.save_alt,
              label: 'Sauvegarde',
              onPressed: () => context.push('/sauvegarde'),
            ),
          ] else
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
              'Les fonctions de votre classe et de vos droits arriveront '
              'dans les prochaines versions de l’application.',
            ),
          ],
        ),
      ),
    );
  }
}

String _libelles(Set<String> droits) =>
    droits.map((d) => droitsDelegables[d] ?? d).join(', ');
