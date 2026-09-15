import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/groupe_uniforme.dart';
import '../providers/uniformes_providers.dart';

/// Liste des groupes d'uniformes de l'atelier (promotions, établissements,
/// équipes...) — voir la demande "Mesures des uniformes". Chaque groupe
/// ouvre sur sa propre fiche (GroupeUniformeDetailPage), avec ses membres et
/// leurs mesures.
class GroupesUniformesListPage extends ConsumerWidget {
  const GroupesUniformesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<GroupeUniforme>> groupesAsync = ref.watch(
      groupesUniformesProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Mesures des uniformes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/uniformes/nouveau'),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau groupe'),
      ),
      body: groupesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur : $e')),
        data: (groupes) {
          if (groupes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.l),
                child: Text(
                  "Aucun groupe pour l'instant. Crée un groupe pour une "
                  'promotion, un établissement ou une équipe qui commande '
                  'des uniformes.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.l),
            itemCount: groupes.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.s),
            itemBuilder: (context, index) {
              final GroupeUniforme groupe = groupes[index];
              return _CarteGroupe(groupe: groupe);
            },
          );
        },
      ),
    );
  }
}

class _CarteGroupe extends ConsumerWidget {
  const _CarteGroupe({required this.groupe});

  final GroupeUniforme groupe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int nombreMembres = ref
        .watch(membresGroupeUniformeProvider(groupe.id))
        .asData
        ?.value
        .length ?? 0;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.m),
        leading: const CircleAvatar(child: Icon(Icons.groups_outlined)),
        title: Text(groupe.nom),
        subtitle: Text(
          '$nombreMembres membre${nombreMembres > 1 ? 's' : ''}'
          '${groupe.repondantNom != null ? ' • ${groupe.repondantNom}' : ''}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/uniformes/${groupe.id}', extra: groupe),
      ),
    );
  }
}
