/// Modèle miroir de la table `rendez_vous_groupe` — rendez-vous rattaché à
/// un groupe d'uniformes plutôt qu'à un client (voir `RendezVous` pour
/// l'équivalent client). Table dédiée pour la même raison que
/// `CommandeGroupe` : jamais d'ALTER sur `rendez_vous`, qui contient déjà
/// des données réelles.
class RendezVousGroupe {
  const RendezVousGroupe({
    required this.id,
    required this.atelierId,
    required this.groupeId,
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
  final String groupeId;
  final DateTime dateHeure;
  final String type; // 'essayage' | 'livraison'
  final String statut; // 'planifie' | 'confirme' | 'termine' | 'annule'
  final bool urgent;
  final DateTime updatedAt;

  /// Même principe que RendezVous.tenueRetiree/tenueRetireeLe.
  final bool tenueRetiree;
  final DateTime? tenueRetireeLe;

  factory RendezVousGroupe.depuisJson(Map<String, dynamic> json) {
    final dateHeure = DateTime.parse(json['date_heure'] as String);
    return RendezVousGroupe(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      groupeId: json['groupe_id'] as String,
      dateHeure: dateHeure,
      type: json['type'] as String,
      statut: json['statut'] as String,
      urgent: json['urgent'] as bool? ?? false,
      // Repli sur date_heure si absent (voir Mesure.depuisJson).
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : dateHeure,
      tenueRetiree: json['tenue_retiree'] as bool? ?? false,
      tenueRetireeLe: json['tenue_retiree_le'] != null
          ? DateTime.parse(json['tenue_retiree_le'] as String)
          : null,
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'atelier_id': atelierId,
      'groupe_id': groupeId,
      'date_heure': dateHeure.toIso8601String(),
      'type': type,
      'statut': statut,
      'urgent': urgent,
      'updated_at': updatedAt.toIso8601String(),
      'tenue_retiree': tenueRetiree,
      'tenue_retiree_le': tenueRetireeLe?.toIso8601String(),
    };
  }

  RendezVousGroupe copierAvec({
    DateTime? dateHeure,
    String? type,
    String? statut,
    bool? urgent,
    bool? tenueRetiree,
    DateTime? tenueRetireeLe,
  }) {
    return RendezVousGroupe(
      id: id,
      atelierId: atelierId,
      groupeId: groupeId,
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
