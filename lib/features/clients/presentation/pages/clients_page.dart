import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/presentation/widgets/navigation/app_drawer.dart';
import '../../domain/entities/client.dart';
import '../providers/client_providers.dart';
import 'add_client_page.dart';
import 'client_details_page.dart';

class ClientsPage extends ConsumerWidget {
  const ClientsPage({super.key});

  Future<void> _showClientActions(
    BuildContext context,
    WidgetRef ref,
    Client client,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Modifier'),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Supprimer'),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Annuler'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );

    if (!context.mounted) return;

    switch (action) {
      case 'edit':
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => AddClientPage(
              client: client,
            ),
          ),
        );

        if (result == true) {
          ref.invalidate(clientsProvider);
        }
        break;

      case 'delete':
        await _deleteClient(
          context,
          ref,
          client,
        );
        break;
    }
  }

  Future<void> _deleteClient(
    BuildContext context,
    WidgetRef ref,
    Client client,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text(
            'Voulez-vous vraiment supprimer ${client.fullName} ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final deleteClient = ref.read(deleteClientUseCaseProvider);

      await deleteClient(client.id);

      ref.invalidate(clientsProvider);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${client.fullName} a été supprimé.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la suppression : $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Clients'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push('/clients/new');

          if (result == true) {
            ref.invalidate(clientsProvider);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau client'),
      ),
      body: clientsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Erreur lors du chargement des clients.\n\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (clients) {
          if (clients.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 72,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Aucun client enregistré.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Cliquez sur "Nouveau client" pour créer votre premier client.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: clients.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final client = clients[index];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(client.fullName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.phone),
                      if (client.email != null) Text(client.email!),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClientDetailsPage(
                          client: client,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    _showClientActions(
                      context,
                      ref,
                      client,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}