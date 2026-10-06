/// Modèle miroir de la table `ateliers`.
class Atelier {
  const Atelier({
    required this.id,
    required this.nom,
    this.logoUrl,
    this.signatureUrl,
    required this.updatedAt,
  });

  final String id;
  final String nom;
  final String? logoUrl;
  final String? signatureUrl;
  final DateTime updatedAt;

  factory Atelier.depuisJson(Map<String, dynamic> json) {
    return Atelier(
      id: json['id'] as String,
      nom: json['nom'] as String,
      logoUrl: json['logo_url'] as String?,
      signatureUrl: json['signature_url'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> versJson() {
    return {'id': id, 'nom': nom, 'logo_url': logoUrl, 'signature_url': signatureUrl};
  }
}
