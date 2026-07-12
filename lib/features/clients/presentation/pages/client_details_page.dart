import 'package:flutter/material.dart';

import '../../domain/entities/client.dart';
import '../widgets/client_header.dart';
import '../widgets/client_identity_card.dart';
import '../widgets/client_quick_actions.dart';

/// Dossier complet d'un client.
///
/// Cette page orchestre les différentes sections
/// du dossier client.
class ClientDetailsPage extends StatelessWidget {
  const ClientDetailsPage({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dossier client')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClientHeader(client: client),

            const SizedBox(height: 16),

            ClientQuickActions(
              onEdit: () {
                // Sprint suivant :
                // ouverture de AddClientPage en mode édition.
              },
              onCall: () {
                // Sprint suivant :
                // appel téléphonique.
              },
              onWhatsApp: () {
                // Sprint suivant :
                // ouverture de WhatsApp.
              },
              onShare: () {
                // Sprint suivant :
                // partage de la fiche client.
              },
            ),

            const SizedBox(height: 16),

            ClientIdentityCard(client: client),
          ],
        ),
      ),
    );
  }
}
