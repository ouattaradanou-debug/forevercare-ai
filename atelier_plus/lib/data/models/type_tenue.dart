/// Modèle miroir de la table `types_tenue`.
///
/// `atelierId == null` signifie un gabarit par défaut fourni par
/// l'application (partagé, en lecture seule pour tous les ateliers).
class TypeTenue {
  const TypeTenue({
    required this.id,
    this.atelierId,
    required this.nom,
    required this.sexe,
    required this.updatedAt,
  });

  final String id;
  final String? atelierId;
  final String nom;
  final String sexe;
  final DateTime updatedAt;

  bool get estGabaritParDefaut => atelierId == null;

  factory TypeTenue.depuisJson(Map<String, dynamic> json) {
    return TypeTenue(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String?,
      nom: json['nom'] as String,
      sexe: json['sexe'] as String,
      // Repli sur l'heure actuelle si absent (voir Mesure.depuisJson).
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now().toUtc(),
    );
  }
}
