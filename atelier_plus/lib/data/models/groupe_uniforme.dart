/// Modèle miroir de la table `groupes_uniformes`.
class GroupeUniforme {
  const GroupeUniforme({
    required this.id,
    required this.atelierId,
    required this.nom,
    required this.updatedAt,
  });

  final String id;
  final String atelierId;
  final String nom;
  final DateTime updatedAt;

  factory GroupeUniforme.depuisJson(Map<String, dynamic> json) {
    return GroupeUniforme(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      nom: json['nom'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'atelier_id': atelierId,
      'nom': nom,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
