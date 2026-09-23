import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/type_emballage.dart';
import 'produit.dart';

/// Lecture/écriture du catalogue produits et des prix d'achat. Lecture en
/// direct (comme `AuthService.informationsCaveActuelles`) : le catalogue
/// change rarement et se configure typiquement avec réseau, contrairement
/// aux ajustements de stock (voir `StockDao`, qui eux passent par la file
/// de synchronisation locale pour fonctionner hors ligne).
class ProduitsService {
  ProduitsService(this._client);

  final SupabaseClient _client;

  Future<List<Produit>> listerProduits(String caveId) async {
    final lignes = await _client
        .from('produits')
        .select()
        .eq('cave_id', caveId)
        .order('nom');
    return lignes.map((l) => Produit.depuisJson(l)).toList();
  }

  Future<Produit> creerProduit({
    required String caveId,
    required String nom,
    required int prixVenteDetail,
    required int prixVenteGros,
    required TypeEmballage typeEmballage,
    required int bouteillesParEmballage,
  }) async {
    final ligne = await _client
        .from('produits')
        .insert({
          'cave_id': caveId,
          'nom': nom,
          'prix_vente_detail': prixVenteDetail,
          'prix_vente_gros': prixVenteGros,
          'type_emballage': typeEmballage.nomPostgres,
          'bouteilles_par_emballage': bouteillesParEmballage,
        })
        .select()
        .single();
    return Produit.depuisJson(ligne);
  }

  /// Protégé côté serveur par `produits_write` (Propriétaire/Propriétaire-
  /// Gérant/Gérant, migration 0008) : un appel bloqué par RLS affecte
  /// silencieusement 0 ligne (une UPDATE, contrairement à un insert/rpc, ne
  /// lève pas 42501 — vérifié en Phase 1, section 10quater de PHASE1.md).
  Future<void> modifierProduit({
    required String produitId,
    required String nom,
    required int prixVenteDetail,
    required int prixVenteGros,
    required TypeEmballage typeEmballage,
    required int bouteillesParEmballage,
    required bool actif,
  }) async {
    final resultat = await _client
        .from('produits')
        .update({
          'nom': nom,
          'prix_vente_detail': prixVenteDetail,
          'prix_vente_gros': prixVenteGros,
          'type_emballage': typeEmballage.nomPostgres,
          'bouteilles_par_emballage': bouteillesParEmballage,
          'actif': actif,
        })
        .eq('id', produitId)
        .select();
    if (resultat.isEmpty) {
      throw Exception('Modification refusée : rôle insuffisant.');
    }
  }

  /// Renvoie `null` si aucun prix d'achat n'est encore enregistré (produit
  /// tout juste créé) ou si l'appelant n'y a pas droit (RLS filtre
  /// silencieusement, sans erreur — c'est le comportement attendu pour un
  /// Agent de vente, qui ne devrait de toute façon jamais afficher ce
  /// champ).
  Future<int?> obtenirPrixAchat(String produitId) async {
    final ligne = await _client
        .from('produits_couts')
        .select('prix_achat')
        .eq('produit_id', produitId)
        .maybeSingle();
    return ligne == null ? null : ligne['prix_achat'] as int;
  }

  Future<void> modifierPrixAchat({
    required String produitId,
    required String caveId,
    required int prixAchat,
  }) async {
    final resultat = await _client.from('produits_couts').upsert({
      'produit_id': produitId,
      'cave_id': caveId,
      'prix_achat': prixAchat,
    }).select();
    if (resultat.isEmpty) {
      throw Exception('Modification refusée : rôle insuffisant.');
    }
  }

  /// Stock actuel côté serveur (utilisé uniquement pour amorcer le cache
  /// local `LocalStock` la première fois qu'un produit est consulté — les
  /// lectures/écritures suivantes passent par `StockDao`, pas par ici).
  Future<({int cartons, int bouteilles})> stockServeur(String produitId) async {
    final ligne = await _client
        .from('stock')
        .select('quantite_cartons, quantite_bouteilles')
        .eq('produit_id', produitId)
        .maybeSingle();
    if (ligne == null) return (cartons: 0, bouteilles: 0);
    return (
      cartons: ligne['quantite_cartons'] as int,
      bouteilles: ligne['quantite_bouteilles'] as int,
    );
  }
}
