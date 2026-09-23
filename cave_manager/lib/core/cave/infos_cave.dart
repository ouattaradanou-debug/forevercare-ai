import '../constants/type_cave.dart';

/// Informations de la cave modifiables après création (icône ⚙️ de
/// l'écran d'accueil) : nom, téléphone, ville, type de cave et logo.
class InfosCave {
  const InfosCave({
    required this.nom,
    required this.telephone,
    required this.localisation,
    required this.typeCave,
    this.logoUrl,
  });

  final String nom;
  final String telephone;
  final String localisation;
  final TypeCave typeCave;
  final String? logoUrl;

  factory InfosCave.depuisJson(Map<String, dynamic> json) {
    return InfosCave(
      nom: json['nom'] as String,
      telephone: json['telephone'] as String,
      localisation: json['localisation'] as String,
      typeCave: TypeCave.depuisPostgres(json['type_cave'] as String),
      logoUrl: json['logo_url'] as String?,
    );
  }
}
