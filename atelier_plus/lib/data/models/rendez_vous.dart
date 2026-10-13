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
    this.tenueRetiree = false,
    this.tenueRetireeLe,
  });

  final String id;
  final String atelierId;
  final String clientId;
  final DateTime dateHeure;
  final String type; // 'essayage' | 'livraison'
  final String statut; // 'planifie' | 'confirme' | 'termine' | 'annule'
  final bool urgent;
  final DateTime updatedAt;

  /// Le client est-il venu récupérer sa tenue à ce rendez-vous ?
  /// [tenueRetireeLe] sert à faire disparaître automatiquement ce
  /// rendez-vous de la liste 10 minutes après ce marquage (voir
  /// EcranListeRendezVous), sans jamais supprimer la ligne elle-même.
  final bool tenueRetiree;
  final DateTime? tenueRetireeLe;

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
      tenueRetiree: json['tenue_retiree'] as bool? ?? false,
      tenueRetireeLe: json['tenue_retiree_le'] != null
          ? DateTime.parse(json['tenue_retiree_le'] as String)
          : null,
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
      'tenue_retiree': tenueRetiree,
      'tenue_retiree_le': tenueRetireeLe?.toIso8601String(),
    };
  }

  RendezVous copierAvec({
    DateTime? dateHeure,
    String? type,
    String? statut,
    bool? urgent,
    bool? tenueRetiree,
    DateTime? tenueRetireeLe,
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
      tenueRetiree: tenueRetiree ?? this.tenueRetiree,
      tenueRetireeLe: tenueRetireeLe ?? this.tenueRetireeLe,
    );
  }
}
