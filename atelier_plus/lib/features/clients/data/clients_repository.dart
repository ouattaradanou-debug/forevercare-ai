import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../data/models/client.dart';

/// Gestion des fiches clients : écriture toujours locale d'abord (l'écran
/// ne dépend jamais du réseau), avec tentative immédiate de synchronisation
/// vers Supabase en meilleur effort. Si cette tentative échoue (hors-ligne,
/// coupure réseau), la fiche reste utilisable localement — la reprise
/// automatique de l'envoi sera assurée par la file d'attente de
/// synchronisation de la Phase 3, qui n'existe pas encore.
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
    String? prenom,
    String? telephone,
    String? sexe,
  }) async {
    final client = Client(
      id: _uuid.v4(),
      atelierId: atelierId,
      nom: nom,
      prenom: prenom,
      telephone: telephone,
      sexe: sexe,
      updatedAt: DateTime.now().toUtc(),
    );

    await _mettreEnCache(client);
    await _pousserVersServeurAuMieux(() => _client.from('clients').insert(client.versJson()));
    return client;
  }

  Future<Client> modifierClient(
    Client existant, {
    String? nom,
    String? prenom,
    String? telephone,
    String? sexe,
  }) async {
    final miseAJour = Client(
      id: existant.id,
      atelierId: existant.atelierId,
      nom: nom ?? existant.nom,
      prenom: prenom ?? existant.prenom,
      telephone: telephone ?? existant.telephone,
      sexe: sexe ?? existant.sexe,
      updatedAt: DateTime.now().toUtc(),
    );
    await _mettreEnCache(miseAJour);
    await _pousserVersServeurAuMieux(
      () => _client.from('clients').update(miseAJour.versJson()).eq('id', miseAJour.id),
    );
    return miseAJour;
  }

  /// Récupère tous les clients de l'atelier depuis Supabase et alimente le
  /// cache local. Appelée au premier affichage de l'écran liste des clients
  /// (ou lors d'un rafraîchissement manuel) : ce n'est PAS le moteur de
  /// synchronisation bidirectionnelle complet de la Phase 3, seulement un
  /// rapatriement initial en lecture, best-effort si hors-ligne.
  Future<void> chargerDepuisServeur(String atelierId) async {
    try {
      final lignes = await _client.from('clients').select().eq('atelier_id', atelierId);
      for (final ligne in lignes) {
        await _mettreEnCache(Client.depuisJson(ligne));
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
      updatedAt: client.updatedAt,
    );
  }

  Future<void> _pousserVersServeurAuMieux(Future<void> Function() envoi) async {
    try {
      await envoi();
    } catch (_) {
      // Voir commentaire de classe : la reprise est du ressort de la
      // Phase 3.
    }
  }
}
