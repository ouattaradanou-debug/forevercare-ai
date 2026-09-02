import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../providers/gabarits_providers.dart';

/// Choix du type de tenue avant la prise de mesure.
class EcranSelectionTypeTenue extends ConsumerWidget {
  const EcranSelectionTypeTenue({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(typesTenueVisiblesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quel type de tenue ?')),
      body: types.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
        data: (liste) {
          if (liste.isEmpty) {
            return const Center(child: Text('Aucun gabarit disponible.'));
          }
          return ListView.builder(
            itemCount: liste.length,
            itemBuilder: (context, index) {
              final type = liste[index];
              return ListTile(
                leading: const Icon(Icons.checkroom),
                title: Text(type.nom),
                subtitle: Text(type.sexe[0].toUpperCase() + type.sexe.substring(1)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.priseMesure(clientId, type.id)),
              );
            },
          );
        },
      ),
    );
  }
}
