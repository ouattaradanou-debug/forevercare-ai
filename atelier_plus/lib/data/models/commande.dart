/// Modèle miroir de la table `commandes`.
class Commande {
  const Commande({
    required this.id,
    required this.atelierId,
    required this.clientId,
    required this.montantTotal,
    required this.avance,
    required this.updatedAt,
  });

  final String id;
  final String atelierId;
  final String clientId;
  final double montantTotal;
  final double avance;
  final DateTime updatedAt;

  factory Commande.depuisJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      clientId: json['client_id'] as String,
      // PostgREST peut renvoyer une colonne `numeric` en JSON comme nombre
      // OU comme texte selon la configuration : double.parse(toString())
      // gère les deux cas sans risque de perte de précision.
      montantTotal: double.parse(json['montant_total'].toString()),
      avance: double.parse(json['avance'].toString()),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// `updated_at` inclus pour la détection de conflit de `SyncEngine` — voir
  /// la remarque équivalente sur `Client.versJson`.
  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'atelier_id': atelierId,
      'client_id': clientId,
      'montant_total': montantTotal,
      'avance': avance,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
