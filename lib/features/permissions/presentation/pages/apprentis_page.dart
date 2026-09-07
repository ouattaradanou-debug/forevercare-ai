import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/utilisateur.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/apprentis_providers.dart';

/// Liste de l'équipe de l'atelier. Réservée au propriétaire : un apprenti
/// qui atteindrait cet écran (lien direct, retour navigateur...) voit un
/// message d'accès refusé plutôt que la liste de l'équipe.
class ApprentisPage extends ConsumerWidget {
  const ApprentisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Utilisateur? utilisateur = ref
        .watch(utilisateurCourantProvider)
        .valueOrNull;

    if (utilisateur != null && !utilisateur.estProprietaire) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mon équipe')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.l),
            child: Text(
              "Cet écran est réservé au propriétaire de l'atelier.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final AsyncValue<List<Utilisateur>> equipe = ref.watch(
      equipeAtelierProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Mon équipe')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/apprentis/nouveau'),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Ajouter un apprenti'),
      ),
      body: equipe.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur : $e')),
        data: (membres) {
          if (membres.isEmpty) {
            return const Center(child: Text('Aucun membre pour le moment.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.l),
            itemCount: membres.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.s),
            itemBuilder: (context, index) {
              final Utilisateur membre = membres[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.m),
                  leading: CircleAvatar(
                    backgroundColor: membre.estProprietaire
                        ? AppColors.or500
                        : AppColors.indigo700,
                    child: Icon(
                      membre.estProprietaire
                          ? Icons.storefront
                          : Icons.person_outline,
                      color: AppColors.ecru50,
                    ),
                  ),
                  title: Text(membre.nom),
                  subtitle: Text(
                    membre.estProprietaire ? 'Propriétaire' : 'Apprenti',
                  ),
                  trailing: membre.estProprietaire
                      ? null
                      : const Icon(Icons.chevron_right),
                  onTap: membre.estProprietaire
                      ? null
                      : () => context.push(
                          '/apprentis/${membre.id}/permissions',
                          extra: membre,
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
