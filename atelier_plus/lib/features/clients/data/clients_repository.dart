import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
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

  /// Vrai si ce client a été enregistré il y a moins de deux semaines (voir
  /// AppConstants.dureeConservationFinances) : le supprimer purge alors
  /// aussi ses commandes/paiements, probablement une erreur de saisie
  /// récente plutôt que des finances déjà comptabilisées.
  bool _recent(DateTime createdAt) =>
      DateTime.now().toUtc().difference(createdAt) < AppConstants.dureeConservationFinances;

  /// Supprime un client — réservé au propriétaire, la RLS `clients_delete`
  /// (ou la politique restrictive sur `supprime_le`) l'impose de toute
  /// façon côté serveur.
  ///
  /// Un client enregistré depuis moins de deux semaines est réellement
  /// supprimé, avec tout ce qui lui est associé (mesures, photos,
  /// rendez-vous, commande, paiements) : probable erreur de saisie récente,
  /// aucune finance n'a encore pu être comptabilisée. Au-delà de ce délai,
  /// le client est seulement masqué (il disparaît de l'application) mais sa
  /// commande et ses paiements sont conservés intacts, pour que les
  /// récapitulatifs financiers de l'atelier ne reculent jamais après coup
  /// (voir AppConstants.dureeConservationFinances).
  ///
  /// Dans les deux cas, suppression locale d'abord, comme le reste de ce
  /// repository : la fiche disparaît immédiatement de l'écran, sans
  /// attendre une réponse serveur ni même une connexion. L'envoi au serveur
  /// est tenté juste après, sans bloquer l'appelant ; s'il échoue
  /// (hors-ligne), il est mis en file d'attente et rejoué automatiquement
  /// au retour de la connexion (voir data/sync/).
  Future<void> supprimerClient(Client client) async {
    await verifierEcritureAutorisee(_baseLocale, client.atelierId);

    if (_recent(client.createdAt)) {
      // Purge aussi toute tâche encore en attente pour ce client ou l'une
      // de ses dépendances (ajout fait hors-ligne, jamais encore envoyé) :
      // sans ça, elle serait "ressuscitée" dès que la file serait rejouée
      // après cette suppression.
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
      return;
    }

    final quand = DateTime.now().toUtc();
    await _baseLocale.masquerClientConserverFinances(client.id, quand);
    unawaited(
      ecrireEtSynchroniser(
        client: _client,
        baseLocale: _baseLocale,
        table: 'clients',
        recordId: client.id,
        operation: 'update',
        // `updated_at` inclus pour SyncEngine (voir _tablesAvecConflitPossible,
        // qui compare ce champ si cette écriture doit être rejouée plus
        // tard) — de toute façon réécrit par le déclencheur SQL
        // `maj_updated_at` à chaque UPDATE côté serveur.
        payload: {'supprime_le': quand.toIso8601String(), 'updated_at': quand.toIso8601String()},
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
      supprimeLe: client.supprimeLe,
    );
  }
}
