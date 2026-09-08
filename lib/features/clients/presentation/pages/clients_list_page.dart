import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/client.dart';
import '../providers/clients_providers.dart';

/// Liste des clients avec recherche instantanée (nom/téléphone). Ne
/// contient, par construction, que des clients ayant au moins une mesure
/// (voir ClientRepository) : un brouillon inachevé n'y apparaît jamais.
class ClientsListPage extends ConsumerStatefulWidget {
  const ClientsListPage({super.key});

  @override
  ConsumerState<ClientsListPage> createState() => _ClientsListPageState();
}

class _ClientsListPageState extends ConsumerState<ClientsListPage> {
  final TextEditingController _rechercheCtrl = TextEditingController();
  String _recherche = '';

  @override
  void initState() {
    super.initState();
    _rechercheCtrl.addListener(() {
      setState(() => _recherche = _rechercheCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Client>> clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/clients/nouveau'),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Nouveau client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _rechercheCtrl,
              decoration: const InputDecoration(
                labelText: 'Rechercher (nom ou téléphone)',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Expanded(
              child: clientsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Erreur : $e')),
                data: (clients) {
                  final List<Client> filtres = _recherche.isEmpty
                      ? clients
                      : clients.where((c) {
                          final String nom = c.nomComplet.toLowerCase();
                          final String tel = (c.telephone ?? '')
                              .toLowerCase();
                          return nom.contains(_recherche) ||
                              tel.contains(_recherche);
                        }).toList();

                  if (filtres.isEmpty) {
                    return Center(
                      child: Text(
                        clients.isEmpty
                            ? "Aucun client pour l'instant."
                            : 'Aucun résultat.',
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtres.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.s),
                    itemBuilder: (context, index) {
                      final Client client = filtres[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(AppSpacing.m),
                          leading: const CircleAvatar(
                            child: Icon(Icons.person_outline),
                          ),
                          title: Text(client.nomComplet),
                          subtitle: Text(client.telephone ?? 'Aucun contact'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(
                            '/clients/${client.id}',
                            extra: client,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
