/// Un client optionnel rattaché à une commande (vente comptoir anonyme si
/// aucun client n'est choisi).
class Client {
  const Client({
    required this.id,
    required this.caveId,
    required this.nom,
    this.telephone,
  });

  final String id;
  final String caveId;
  final String nom;
  final String? telephone;

  factory Client.depuisJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      caveId: json['cave_id'] as String,
      nom: json['nom'] as String,
      telephone: json['telephone'] as String?,
    );
  }
}
