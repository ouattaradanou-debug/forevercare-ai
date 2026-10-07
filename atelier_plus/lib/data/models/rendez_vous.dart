/// Modèle miroir de la table `rendez_vous`.
class RendezVous {
  const RendezVous({
    required this.id,
    required this.atelierId,
    required this.clientId,
    required this.dateHeure,
    required this.type,
    required this.statut,
    this.urgent = false,
    required this.updatedAt,
  });

  final String id;
  final String atelierId;
  final String clientId;
  final DateTime dateHeure;
  final String type; // 'essayage' | 'livraison'
  final String statut; // 'planifie' | 'confirme' | 'termine' | 'annule'
  final bool urgent;
  final DateTime updatedAt;

  factory RendezVous.depuisJson(Map<String, dynamic> json) {
    return RendezVous(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      clientId: json['client_id'] as String,
      dateHeure: DateTime.parse(json['date_heure'] as String),
      type: json['type'] as String,
      statut: json['statut'] as String,
      urgent: json['urgent'] as bool? ?? false,
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
      'date_heure': dateHeure.toIso8601String(),
      'type': type,
      'statut': statut,
      'urgent': urgent,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  RendezVous copierAvec({
    DateTime? dateHeure,
    String? type,
    String? statut,
    bool? urgent,
  }) {
    return RendezVous(
      id: id,
      atelierId: atelierId,
      clientId: clientId,
      dateHeure: dateHeure ?? this.dateHeure,
      type: type ?? this.type,
      statut: statut ?? this.statut,
      urgent: urgent ?? this.urgent,
      updatedAt: DateTime.now().toUtc(),
    );
  }
}
