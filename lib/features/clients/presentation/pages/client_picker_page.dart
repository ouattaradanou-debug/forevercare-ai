import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/client.dart';
import '../providers/client_providers.dart';

/// ============================================================================
/// ForeverCare AI
/// ClientPickerPage
/// ============================================================================
///
/// Permet de sélectionner un client existant.
///
/// Retour :
///
/// Navigator.pop(client)
///
class ClientPickerPage extends ConsumerStatefulWidget {
  const ClientPickerPage({
    super.key,
  });

  @override
  ConsumerState<ClientPickerPage> createState() =>
      _ClientPickerPageState();
}

class _ClientPickerPageState
    extends ConsumerState<ClientPickerPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choisir un client',
        ),
      ),
      body: Column(
        children: [
          //------------------------------------------------------------------
          // Recherche
          //------------------------------------------------------------------

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un client...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _query = '';
                          });
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value.trim().toLowerCase();
                });
              },
            ),
          ),

          //------------------------------------------------------------------
          // Liste
          //------------------------------------------------------------------

          Expanded(
            child: clientsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (clients) {
                final filtered = _query.isEmpty
                    ? clients
                    : clients.where((client) {
                        return client.fullName
                                .toLowerCase()
                                .contains(_query) ||
                            client.phone
                                .toLowerCase()
                                .contains(_query) ||
                            (client.email ?? '')
                                .toLowerCase()
                                .contains(_query);
                      }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun client trouvé.',
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    16,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder:
                      (context, index) =>
                          const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final client = filtered[index];

                    final initials =
                        '${client.firstName.isNotEmpty ? client.firstName[0] : ''}'
                        '${client.lastName.isNotEmpty ? client.lastName[0] : ''}'
                            .toUpperCase();

                    return Card(
                      elevation: 0,
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(initials),
                        ),
                        title: Text(
                          client.fullName,
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(client.phone),
                            if (client.email != null &&
                                client.email!.isNotEmpty)
                              Text(client.email!),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: () {
                          Navigator.of(context).pop<Client>(
                            client,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}