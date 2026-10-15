/// Modèle miroir de la table `mesures_uniforme` — même principe que
/// [Mesure], mais rattachée à un membre de groupe plutôt qu'à un client.
class MesureUniforme {
  const MesureUniforme({
    required this.id,
    required this.membreId,
    required this.typeTenueId,
    required this.datePrise,
    required this.valeurs,
    this.prisePar,
  });

  final String id;
  final String membreId;
  final String typeTenueId;
  final DateTime datePrise;
  final Map<String, String> valeurs;
  final String? prisePar;

  factory MesureUniforme.depuisJson(Map<String, dynamic> json) {
    final valeursBrutes = json['valeurs'] as Map<String, dynamic>? ?? {};
    return MesureUniforme(
      id: json['id'] as String,
      membreId: json['membre_id'] as String,
      typeTenueId: json['type_tenue_id'] as String,
      datePrise: DateTime.parse(json['date_prise'] as String),
      valeurs: valeursBrutes.map((cle, valeur) => MapEntry(cle, valeur.toString())),
      prisePar: json['prise_par'] as String?,
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'membre_id': membreId,
      'type_tenue_id': typeTenueId,
      'date_prise': datePrise.toIso8601String(),
      'valeurs': valeurs,
      'prise_par': prisePar,
    };
  }
}
