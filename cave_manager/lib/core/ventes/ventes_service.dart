import 'package:supabase_flutter/supabase_flutter.dart';

import 'client.dart';
import 'commande.dart';
import 'commande_ligne.dart';

/// Lecture des clients/commandes et gestion des clients : requêtes
/// directes Supabase (comme `ProduitsService`), nécessitent le réseau.
///
/// La CRÉATION d'une commande n'est volontairement PAS ici : c'est la
/// seule partie de cette phase où l'offline-first est un besoin explicite
/// du cahier des charges ("toute prise de commande" — voir PHASE1.md
/// section 10.4), elle passe donc par `VentesDao` (file de synchronisation
/// locale), pas par un appel réseau direct. Choisir/créer un client reste
/// en revanche une commodité qui suppose le réseau : une vente peut être
/// enregistrée hors ligne sans client (vente comptoir anonyme,
/// `client_id` nullable).
class VentesService {
  VentesService(this._client);

  final SupabaseClient _client;

  Future<List<Client>> listerClients(String caveId) async {
    final lignes = await _client
        .from('clients')
        .select()
        .eq('cave_id', caveId)
        .order('nom');
    return lignes.map((l) => Client.depuisJson(l)).toList();
  }

  Future<Client> creerClient({
    required String caveId,
    required String nom,
    String? telephone,
  }) async {
    final ligne = await _client
        .from('clients')
        .insert({
          'cave_id': caveId,
          'nom': nom,
          if (telephone != null && telephone.trim().isNotEmpty)
            'telephone': telephone.trim(),
        })
        .select()
        .single();
    return Client.depuisJson(ligne);
  }

  Future<List<Commande>> listerCommandes(String caveId) async {
    final lignes = await _client
        .from('commandes')
        .select()
        .eq('cave_id', caveId)
        .order('created_at', ascending: false);
    return lignes.map((l) => Commande.depuisJson(l)).toList();
  }

  Future<List<CommandeLigne>> listerLignes(String commandeId) async {
    final lignes = await _client
        .from('commande_lignes')
        .select('*, produits(nom)')
        .eq('commande_id', commandeId)
        .order('created_at');
    return lignes.map((l) => CommandeLigne.depuisJson(l)).toList();
  }

  /// Relit une commande (utilisé après modification/suppression d'une
  /// ligne, pour afficher le total recalculé côté serveur par trigger).
  Future<Commande> obtenirCommande(String commandeId) async {
    final ligne =
        await _client.from('commandes').select().eq('id', commandeId).single();
    return Commande.depuisJson(ligne);
  }

  /// Protégé côté serveur par `commandes_update` : seule la transition
  /// 'en_attente' -> 'annulee' est autorisée (Propriétaire/Propriétaire-
  /// Gérant/Gérant uniquement) — un appel bloqué par RLS affecte
  /// silencieusement 0 ligne plutôt que de lever une erreur.
  Future<void> annulerCommande(String commandeId) async {
    final resultat = await _client
        .from('commandes')
        .update({'statut': 'annulee'})
        .eq('id', commandeId)
        .select();
    if (resultat.isEmpty) {
      throw Exception(
          'Annulation refusée : rôle insuffisant, ou commande déjà traitée.');
    }
  }
}
