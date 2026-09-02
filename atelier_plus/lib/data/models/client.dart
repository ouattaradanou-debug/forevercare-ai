/// Modèle miroir de la table `clients`.
class Client {
  const Client({
    required this.id,
    required this.atelierId,
    required this.nom,
    this.prenom,
    this.telephone,
    this.sexe,
    required this.updatedAt,
  });

  final String id;
  final String atelierId;
  final String nom;
  final String? prenom;
  final String? telephone;
  final String? sexe;
  final DateTime updatedAt;

  String get nomComplet => prenom == null || prenom!.isEmpty ? nom : '$nom $prenom';

  factory Client.depuisJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String?,
      telephone: json['telephone'] as String?,
      sexe: json['sexe'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'atelier_id': atelierId,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'sexe': sexe,
    };
  }
}
