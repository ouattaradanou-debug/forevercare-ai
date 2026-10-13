import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../data/models/client.dart';
import '../../../data/sync/ecriture_synchronisee.dart';
import '../../abonnement/data/abonnement_guard.dart';

/// Gestion des fiches clients : écriture toujours locale d'abord (l'écran
/// ne dépend jamais du réseau), avec tentative immédiate de synchronisation
/// vers Supabase ; en cas d'échec (hors-ligne), l'écriture est déposée dans
/// la file d'attente de synchronisation et rejouée automatiquement dès
/// qu'une connexion est détectée (voir data/sync/).
class ClientsRepository {
  ClientsRepository({required SupabaseClient client, required AppDatabase baseLocale})
      : _client = client,
        _baseLocale = baseLocale;

  final SupabaseClient _client;
  final AppDatabase _baseLocale;
  static const _uuid = Uuid();

  Future<Client> creerClient({
    required String atelierId,
    required String nom,
    required String prenom,
    required String telephone,
    required String sexe,
    required DateTime datePriseMesures,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final maintenant = DateTime.now().toUtc();
    final client = Client(
      id: _uuid.v4(),
      atelierId: atelierId,
      nom: nom,
      prenom: prenom,
      telephone: telephone,
      sexe: sexe,
      datePriseMesures: datePriseMesures,
      createdAt: maintenant,
      updatedAt: maintenant,
    );

    await _mettreEnCache(client);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'clients',
      recordId: client.id,
      operation: 'insert',
      payload: client.versJson(),
    );
    return client;
  }

  Future<Client> modifierClient(
    Client existant, {
    String? nom,
    String? prenom,
    String? telephone,
    String? sexe,
    DateTime? datePriseMesures,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, existant.atelierId);
    final miseAJour = Client(
      id: existant.id,
      atelierId: existant.atelierId,
      nom: nom ?? existant.nom,
      prenom: prenom ?? existant.prenom,
      telephone: telephone ?? existant.telephone,
      sexe: sexe ?? existant.sexe,
      datePriseMesures: datePriseMesures ?? existant.datePriseMesures,
      createdAt: existant.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    await _mettreEnCache(miseAJour);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'clients',
      recordId: miseAJour.id,
      operation: 'update',
      payload: miseAJour.versJson(),
    );
    return miseAJour;
  }

  /// Supprime définitivement un client et tout ce qui lui est associé
  /// (mesures, photos, rendez-vous, commande, paiements) — réservé au
  /// propriétaire, la RLS `clients_delete` l'impose de toute façon côté
  /// serveur.
  ///
  /// Suppression locale d'abord, comme le reste de ce repository : la fiche
  /// disparaît immédiatement de l'écran, sans attendre une réponse serveur
  /// ni même une connexion. L'envoi au serveur est tenté juste après, sans
  /// bloquer l'appelant ; s'il échoue (hors-ligne), il est mis en file
  /// d'attente et rejoué automatiquement au retour de la connexion (voir
  /// data/sync/). Le `on delete cascade` du schéma Postgres supprime alors
  /// lui-même mesures/photos/rendez-vous/commande/paiements en une seule
  /// suppression côté serveur, sans qu'il soit nécessaire de les mettre en
  /// file d'attente séparément.
  Future<void> supprimerClient(Client client) async {
    await verifierEcritureAutorisee(_baseLocale, client.atelierId);

    // Purge aussi toute tâche encore en attente pour ce client ou l'une de
    // ses dépendances (ajout fait hors-ligne, jamais encore envoyé) : sans
    // ça, elle serait "ressuscitée" dès que la file serait rejouée après
    // cette suppression.
    await _baseLocale.supprimerClientEtDependances(client.id);

    unawaited(
      ecrireEtSynchroniser(
        client: _client,
        baseLocale: _baseLocale,
        table: 'clients',
        recordId: client.id,
        operation: 'delete',
        payload: const {},
      ),
    );
  }

  /// Récupère tous les clients de l'atelier depuis Supabase et alimente le
  /// cache local. Appelée au premier affichage de l'écran liste des clients
  /// (ou lors d'un rafraîchissement manuel) : ce n'est PAS le moteur de
  /// synchronisation bidirectionnelle complet de la Phase 3, seulement un
  /// rapatriement initial en lecture, best-effort si hors-ligne.
  Future<void> chargerDepuisServeur(String atelierId) async {
    try {
      final lignes = await _client.from('clients').select().eq('atelier_id', atelierId);
      // Un client supprimé localement hors-ligne reste sur le serveur
      // jusqu'à ce que la suppression en file d'attente soit rejouée : ne
      // pas le remettre en cache ici, sous peine de le faire réapparaître
      // (voir AppDatabase.idsEnAttenteDeSuppression).
      final idsSupprimes = await _baseLocale.idsEnAttenteDeSuppression('clients');
      for (final ligne in lignes) {
        final client = Client.depuisJson(ligne);
        if (idsSupprimes.contains(client.id)) continue;
        await _mettreEnCache(client);
      }
    } catch (_) {
      // Hors-ligne : l'écran continue de fonctionner avec le cache local
      // existant, conformément à l'exigence d'usage hors-ligne quotidien.
    }
  }

  Future<void> _mettreEnCache(Client client) {
    return _baseLocale.enregistrerClient(
      id: client.id,
      atelierId: client.atelierId,
      nom: client.nom,
      prenom: client.prenom,
      telephone: client.telephone,
      sexe: client.sexe,
      datePriseMesures: client.datePriseMesures,
      createdAt: client.createdAt,
      updatedAt: client.updatedAt,
    );
  }
}
