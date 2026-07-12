import 'package:flutter/material.dart';

import '../../domain/entities/client.dart';

/// Carte des informations générales du client.
class ClientIdentityCard extends StatelessWidget {
  const ClientIdentityCard({super.key, required this.client});

  final Client client;

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Non renseignée';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const ListTile(
              leading: Icon(Icons.badge),
              title: Text(
                'Informations générales',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Nom complet'),
              subtitle: Text(client.fullName),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Téléphone'),
              subtitle: Text(client.phone),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(client.email ?? 'Non renseigné'),
            ),
            ListTile(
              leading: const Icon(Icons.wc),
              title: const Text('Sexe'),
              subtitle: Text(client.gender ?? 'Non renseigné'),
            ),
            ListTile(
              leading: const Icon(Icons.cake),
              title: const Text('Date de naissance'),
              subtitle: Text(_formatDate(client.birthDate)),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Client depuis'),
              subtitle: Text(_formatDate(client.createdAt)),
            ),
          ],
        ),
      ),
    );
  }
}
