/// Modèle miroir de la table `abonnements`.
///
/// La ligne est créée automatiquement par le déclencheur SQL
/// `creer_abonnement_essai` à la création de l'atelier (Phase 0) : jamais
/// insérée depuis l'application, seulement lue (voir supabase/README.md —
/// aucune politique d'écriture pour le rôle `authenticated`).
class Abonnement {
  const Abonnement({
    required this.id,
    required this.atelierId,
    required this.statut,
    required this.dateFinEssai,
    this.dateRenouvellement,
  });

  final String id;
  final String atelierId;
  final String statut; // 'essai' | 'actif' | 'expire' | 'suspendu'
  final DateTime dateFinEssai;
  final DateTime? dateRenouvellement;

  factory Abonnement.depuisJson(Map<String, dynamic> json) {
    return Abonnement(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      statut: json['statut'] as String,
      dateFinEssai: DateTime.parse(json['date_fin_essai'] as String),
      dateRenouvellement: json['date_renouvellement'] != null
          ? DateTime.parse(json['date_renouvellement'] as String)
          : null,
    );
  }
}
