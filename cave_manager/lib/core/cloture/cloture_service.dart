import 'package:supabase_flutter/supabase_flutter.dart';

import 'cloture.dart';
import 'historique_correction.dart';

/// Aperçu de ce qu'une clôture produirait si elle était faite maintenant
/// (mêmes filtres que la fonction serveur `cloturer_caisse`, mais en
/// lecture seule — aucune écriture). Affiché avant que le responsable
/// confirme la clôture.
class PrevisionCloture {
  const PrevisionCloture({
    required this.totalVentes,
    required this.totalEspeces,
    required this.totalMobileMoney,
    required this.nombreCommandes,
  });

  final int totalVentes;
  final int totalEspeces;
  final int totalMobileMoney;
  final int nombreCommandes;

  int get totalEncaisse => totalEspeces + totalMobileMoney;
}

/// Clôture de caisse (Phase 5) : la clôture elle-même et sa correction
/// exceptionnelle passent par des RPC `security definer` (migration 0015),
/// jamais par un insert/update direct — la lecture reste une requête
/// directe Supabase (comme le reste de l'historique des ventes, nécessite
/// le réseau).
class ClotureService {
  ClotureService(this._client);

  final SupabaseClient _client;

  Future<List<Cloture>> listerClotures(String caveId) async {
    final lignes = await _client
        .from('clotures')
        .select()
        .eq('cave_id', caveId)
        .order('date_cloture', ascending: false);
    return lignes.map((l) => Cloture.depuisJson(l)).toList();
  }

  /// Aperçu en lecture seule de ce que `cloturerCaisse` produirait :
  /// mêmes filtres (`cloture_id is null`) que la fonction serveur, sommés
  /// côté client.
  Future<PrevisionCloture> previsualiser(String caveId) async {
    final commandes = await _client
        .from('commandes')
        .select('total')
        .eq('cave_id', caveId)
        .eq('statut', 'validee')
        .isFilter('cloture_id', null);
    final encaissements = await _client
        .from('encaissements')
        .select('montant_especes, montant_mobile_money')
        .eq('cave_id', caveId)
        .isFilter('cloture_id', null);

    final totalVentes = commandes.fold<int>(
        0, (somme, c) => somme + (c['total'] as int));
    final totalEspeces = encaissements.fold<int>(
        0, (somme, e) => somme + (e['montant_especes'] as int));
    final totalMobile = encaissements.fold<int>(
        0, (somme, e) => somme + (e['montant_mobile_money'] as int));

    return PrevisionCloture(
      totalVentes: totalVentes,
      totalEspeces: totalEspeces,
      totalMobileMoney: totalMobile,
      nombreCommandes: commandes.length,
    );
  }

  /// Réservé aux responsables (PG/GER toujours, PROP seulement si la cave
  /// l'autorise) — vérifié côté serveur par la fonction elle-même, pas
  /// seulement par l'affichage du bouton.
  Future<Cloture> cloturerCaisse(String caveId) async {
    final resultat = await _client
        .rpc('cloturer_caisse', params: {'p_cave_id': caveId});
    return Cloture.depuisJson(resultat as Map<String, dynamic>);
  }

  Future<List<HistoriqueCorrection>> listerCorrections(
      String clotureId) async {
    final lignes = await _client
        .from('historique_corrections')
        .select()
        .eq('cloture_id', clotureId)
        .order('created_at');
    return lignes.map((l) => HistoriqueCorrection.depuisJson(l)).toList();
  }

  /// Réservé au Propriétaire/Propriétaire-Gérant — vérifié côté serveur.
  Future<HistoriqueCorrection> corrigerCloture({
    required String clotureId,
    required int montantCorrection,
    required String motif,
  }) async {
    final resultat = await _client.rpc('corriger_cloture', params: {
      'p_cloture_id': clotureId,
      'p_montant_correction': montantCorrection,
      'p_motif': motif,
    });
    return HistoriqueCorrection.depuisJson(resultat as Map<String, dynamic>);
  }
}
