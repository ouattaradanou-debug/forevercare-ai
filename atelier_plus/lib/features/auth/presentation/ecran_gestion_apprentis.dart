import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../providers/auth_providers.dart';

/// Écran réservé au propriétaire : liste des apprentis de l'atelier et
/// accès à la création d'un nouveau compte / au panneau de permissions de
/// chacun.
class EcranGestionApprentis extends ConsumerWidget {
  const EcranGestionApprentis({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estProprietaire = ref.watch(estProprietaireProvider);

    if (!estProprietaire) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes apprentis')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Seul le propriétaire de l\'atelier peut gérer les apprentis.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final utilisateurs = ref.watch(utilisateursDeLAtelierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes apprentis')),
      body: utilisateurs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
        data: (liste) {
          final apprentis = liste.where((u) => u.estApprenti).toList();
          if (apprentis.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucun apprenti pour le moment.\nAjoutez-en un avec le bouton +',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: apprentis.length,
            itemBuilder: (context, index) {
              final apprenti = apprentis[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(apprenti.nom),
                subtitle: Text(apprenti.telephone),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  AppRoutes.permissionsApprenti(apprenti.id),
                  extra: apprenti.nom,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.creationApprenti),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Ajouter un apprenti'),
      ),
    );
  }
}
