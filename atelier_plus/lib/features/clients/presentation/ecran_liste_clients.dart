import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_providers.dart';
import '../../permissions/providers/permissions_providers.dart';
import '../providers/clients_providers.dart';

/// Liste des clients avec recherche instantanée (nom/prénom/téléphone).
/// Lecture entièrement locale : fonctionne hors-ligne au quotidien.
class EcranListeClients extends ConsumerStatefulWidget {
  const EcranListeClients({super.key});

  @override
  ConsumerState<EcranListeClients> createState() => _EcranListeClientsState();
}

class _EcranListeClientsState extends ConsumerState<EcranListeClients> {
  final _rechercheCtrl = TextEditingController();
  String _requete = '';

  @override
  void initState() {
    super.initState();
    // Rapatriement initial best-effort (silencieux si hors-ligne) : la
    // liste reste utilisable immédiatement via le cache local pendant ce
    // chargement.
    Future.microtask(() async {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      if (utilisateur != null) {
        await ref.read(clientsRepositoryProvider).chargerDepuisServeur(utilisateur.atelierId);
      }
    });
  }

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultats = ref.watch(rechercheClientsProvider(_requete));
    final permissions = ref.watch(mesPermissionsProvider);
    final estProprietaire = ref.watch(estProprietaireProvider);
    final peutCreer = estProprietaire || (permissions.valueOrNull?.creerClient ?? false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes clients'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _rechercheCtrl,
              onChanged: (valeur) => setState(() => _requete = valeur),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou téléphone',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: resultats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
        data: (clients) {
          if (clients.isEmpty) {
            return Center(
              child: Text(
                _requete.isEmpty ? 'Aucun client pour le moment.' : 'Aucun résultat.',
              ),
            );
          }
          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(client.nom.isNotEmpty ? client.nom[0].toUpperCase() : '?'),
                ),
                title: Text(client.nomComplet),
                subtitle: client.telephone != null ? Text(client.telephone!) : null,
                onTap: () => context.push(AppRoutes.ficheClient(client.id)),
              );
            },
          );
        },
      ),
      floatingActionButton: peutCreer
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.creationClient),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Nouveau client'),
            )
          : null,
    );
  }
}
