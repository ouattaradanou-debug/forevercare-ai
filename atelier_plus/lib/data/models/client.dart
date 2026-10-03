/// Modèle miroir de la table `clients`.
class Client {
  const Client({
    required this.id,
    required this.atelierId,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.sexe,
    required this.datePriseMesures,
    required this.updatedAt,
  });

  final String id;
  final String atelierId;
  final String nom;
  final String prenom;
  final String telephone;
  final String sexe;
  final DateTime datePriseMesures;
  final DateTime updatedAt;

  /// `prenom` ne peut jamais être vide côté base (contrainte
  /// `clients_prenom_check`) : depuis la fusion des champs "Nom" et
  /// "Prénom" en un seul à l'écran, `prenom` reçoit systématiquement la
  /// même valeur que `nom` — on n'affiche donc le prénom séparément que
  /// s'il diffère réellement (fiches créées avant cette fusion).
  String get nomComplet => (prenom.isEmpty || prenom == nom) ? nom : '$nom $prenom';

  factory Client.depuisJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      telephone: json['telephone'] as String,
      sexe: json['sexe'] as String,
      datePriseMesures: DateTime.parse(json['date_prise_mesures'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Inclut `updated_at` bien que le déclencheur SQL `maj_updated_at` le
  /// réécrive de toute façon à chaque UPDATE côté serveur : c'est la valeur
  /// que `SyncEngine` compare à celle du serveur avant de rejouer une tâche
  /// en attente, pour détecter un conflit ("dernière modification gagne").
  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'atelier_id': atelierId,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'sexe': sexe,
      'date_prise_mesures': '${datePriseMesures.year.toString().padLeft(4, '0')}-'
          '${datePriseMesures.month.toString().padLeft(2, '0')}-'
          '${datePriseMesures.day.toString().padLeft(2, '0')}',
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
