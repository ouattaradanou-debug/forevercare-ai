/// Modèle miroir de la table `mesures`.
///
/// [valeurs] associe l'id d'un `ChampMesure` à la valeur saisie (texte, pour
/// rester simple et tolérant à la virgule/au point décimal). Chaque prise de
/// mesure crée une nouvelle ligne : jamais de mise à jour d'une mesure
/// existante depuis l'application (voir MesuresRepository).
class Mesure {
  const Mesure({
    required this.id,
    required this.atelierId,
    required this.clientId,
    required this.typeTenueId,
    required this.datePrise,
    required this.valeurs,
    this.prisePar,
    required this.updatedAt,
  });

  final String id;
  final String atelierId;
  final String clientId;
  final String typeTenueId;
  final DateTime datePrise;
  final Map<String, String> valeurs;
  final String? prisePar;
  final DateTime updatedAt;

  factory Mesure.depuisJson(Map<String, dynamic> json) {
    final valeursBrutes = json['valeurs'] as Map<String, dynamic>? ?? {};
    return Mesure(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      clientId: json['client_id'] as String,
      typeTenueId: json['type_tenue_id'] as String,
      datePrise: DateTime.parse(json['date_prise'] as String),
      valeurs: valeursBrutes.map((cle, valeur) => MapEntry(cle, valeur.toString())),
      prisePar: json['prise_par'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'atelier_id': atelierId,
      'client_id': clientId,
      'type_tenue_id': typeTenueId,
      'date_prise': datePrise.toIso8601String(),
      'valeurs': valeurs,
      'prise_par': prisePar,
    };
  }
}
