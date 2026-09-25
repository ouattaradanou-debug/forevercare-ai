/// Une correction exceptionnelle apportée à une clôture déjà écrite
/// (réservée au Propriétaire/Propriétaire-Gérant — voir
/// `corriger_cloture`, migration 0015). `montantCorrection` est un delta
/// signé (positif = ajout, négatif = retrait), jamais une nouvelle valeur
/// absolue.
class HistoriqueCorrection {
  const HistoriqueCorrection({
    required this.id,
    required this.clotureId,
    required this.montantCorrection,
    required this.motif,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String clotureId;
  final int montantCorrection;
  final String motif;
  final String createdBy;
  final DateTime createdAt;

  factory HistoriqueCorrection.depuisJson(Map<String, dynamic> json) {
    return HistoriqueCorrection(
      id: json['id'] as String,
      clotureId: json['cloture_id'] as String,
      montantCorrection: json['montant_correction'] as int,
      motif: json['motif'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
