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
    final datePrise = DateTime.parse(json['date_prise'] as String);
    return Mesure(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      clientId: json['client_id'] as String,
      typeTenueId: json['type_tenue_id'] as String,
      datePrise: datePrise,
      valeurs: valeursBrutes.map((cle, valeur) => MapEntry(cle, valeur.toString())),
      prisePar: json['prise_par'] as String?,
      // Repli sur date_prise si absent : certaines mesures plus anciennes
      // n'ont pas de valeur pour cette colonne côté serveur — sans ce
      // repli, une seule ligne de ce type faisait échouer tout le
      // rapatriement (y compris les mesures des AUTRES clients dans le
      // même lot), les faisant paraître perdues alors qu'elles existaient
      // bien côté serveur.
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : datePrise,
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
