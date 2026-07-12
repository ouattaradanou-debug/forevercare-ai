import 'package:flutter/material.dart';

import '../../domain/entities/client.dart';

/// En-tête du dossier client.
///
/// Ce widget affiche les informations principales
/// du client.
///
/// Il ne contient aucune logique métier.
class ClientHeader extends StatelessWidget {
  const ClientHeader({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 42,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              client.fullName,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            if (client.gender != null)
              Chip(
                avatar: const Icon(Icons.badge, size: 18),
                label: Text(client.gender!),
              ),

            const SizedBox(height: 20),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.phone),
              title: const Text('Téléphone'),
              subtitle: Text(client.phone),
            ),

            if (client.email != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.email),
                title: const Text('Adresse e-mail'),
                subtitle: Text(client.email!),
              ),
          ],
        ),
      ),
    );
  }
}
