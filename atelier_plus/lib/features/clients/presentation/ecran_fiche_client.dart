import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../permissions/providers/permissions_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/clients_providers.dart';

/// Écran central d'un client : informations, et accès à la prise de mesure
/// et aux photos. Les finances (Phase 3) n'apparaîtront ici que pour le
/// propriétaire.
class EcranFicheClient extends ConsumerWidget {
  const EcranFicheClient({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientParIdProvider(clientId));
    final permissions = ref.watch(mesPermissionsProvider);
    final estProprietaire = ref.watch(estProprietaireProvider);
    final peutModifier = estProprietaire || (permissions.valueOrNull?.modifierClient ?? false);
    final peutPrendreMesure = estProprietaire || (permissions.valueOrNull?.prendreMesures ?? false);
    final peutAjouterPhoto = estProprietaire || (permissions.valueOrNull?.ajouterPhotos ?? false);

    return client.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (erreur, _) => Scaffold(body: Center(child: Text('Erreur : $erreur'))),
      data: (client) {
        if (client == null) {
          return const Scaffold(body: Center(child: Text('Client introuvable.')));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(client.nomComplet),
            actions: [
              if (peutModifier)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push(AppRoutes.modificationClient(client.id), extra: client),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (client.telephone != null)
                ListTile(leading: const Icon(Icons.phone), title: Text(client.telephone!)),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  enabled: peutPrendreMesure,
                  leading: const Icon(Icons.straighten),
                  title: const Text('Prendre une mesure'),
                  subtitle: peutPrendreMesure
                      ? null
                      : const Text('Non autorisé — demandez au propriétaire.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: peutPrendreMesure
                      ? () => context.push(AppRoutes.selectionTypeTenue(client.id))
                      : null,
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Photos (tissus et modèles)'),
                  subtitle: peutAjouterPhoto ? null : const Text('Lecture seule'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.photosClient(client.id)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
