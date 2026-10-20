import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/members/presentation/password_tools.dart';
import 'package:ecoleplus/features/options/domain/module_rules.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const libellesProfils = {
  'directeur': 'Directeur',
  'enseignant': 'Enseignant',
  'delegue': 'Délégué (secrétaire, économe…)',
};

class MembersPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value!;
    final members =
        ref.watch(membersProvider(session.schoolId)).value ?? const [];
    return EcoleScaffold(
      title: 'Personnes et droits',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BigButton(
            icon: Icons.person_add,
            label: 'Ajouter une personne',
            onPressed: () => context.push('/personnes/ajouter'),
          ),
          const SizedBox(height: 16),
          for (final m in members)
            Card(
              child: ListTile(
                leading: Icon(
                  m.active ? Icons.person : Icons.person_off,
                  color: m.active ? null : Theme.of(context).disabledColor,
                ),
                title: Text(m.displayName),
                subtitle: Text(
                  '${libellesProfils[m.role] ?? m.role}'
                  '${m.active ? '' : ' — compte désactivé'}',
                ),
                trailing: m.id == session.membershipId
                    ? const Text('Vous')
                    : const Icon(Icons.chevron_right),
                onTap: m.id == session.membershipId
                    ? null
                    : () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => _MemberSheet(member: m),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MemberSheet extends ConsumerWidget {
  const new({required this.member});
  final MembershipRow member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(schoolRepositoryProvider);
    final droits = ref.watch(permissionsProvider(member.id)).value ?? const {};
    final cantine = ref
        .watch(modulesProvider(member.schoolId))
        .value
        ?.any((m) => m.$1.key == 'cantine' && m.$2);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            member.displayName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(libellesProfils[member.role] ?? member.role),
          if (member.role == 'delegue') ...[
            const SectionTitle('Droits accordés'),
            for (final k in droitsVisibles(cantineActive: cantine ?? false))
              CheckboxListTile(
                title: Text(droitsDelegables[k]!),
                value: droits.contains(k),
                onChanged: (v) => repo.setPermission(
                  member.schoolId,
                  member.id,
                  k,
                  granted: v ?? false,
                ),
              ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.lock_reset),
            label: const Text('Donner un nouveau mot de passe'),
            onPressed: () => _reset(context, ref),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: Icon(member.active ? Icons.block : Icons.check_circle),
            label: Text(
              member.active ? 'Désactiver le compte' : 'Réactiver le compte',
            ),
            onPressed: () async {
              final ok = await confirmer(
                context,
                titre: member.active ? 'Désactiver ?' : 'Réactiver ?',
                message: member.active
                    ? '${member.displayName} ne pourra plus se connecter ni '
                          'voir les données de l’école. Rien n’est supprimé.'
                    : '${member.displayName} pourra de nouveau se connecter.',
                bouton: member.active ? 'Désactiver' : 'Réactiver',
              );
              if (ok) {
                await repo.setMemberActive(member.id, active: !member.active);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final password = motDePasseProvisoire();
    final ok = await confirmer(
      context,
      titre: 'Nouveau mot de passe',
      message:
          'Nouveau mot de passe provisoire de ${member.displayName} :\n\n'
          '$password\n\nNotez-le avant de confirmer. Cette action a besoin '
          'd’Internet.',
      bouton: 'Confirmer',
    );
    if (!ok || !context.mounted) return;
    final done = await avecMessage(context, () async {
      await ref.read(membersServiceProvider).resetPassword(member.id, password);
      return true;
    });
    if ((done ?? false) && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Mot de passe changé.')));
    }
  }
}
