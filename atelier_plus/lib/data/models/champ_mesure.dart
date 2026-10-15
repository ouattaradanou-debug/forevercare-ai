/// Statut d'un champ de mesure. Un champ utilisé par au moins une mesure
/// existante ne doit jamais être supprimé, seulement masqué — voir
/// `GabaritsRepository.masquerChamp` pour la vérification correspondante.
enum StatutChamp {
  actif,
  masque;

  static StatutChamp depuisTexte(String valeur) {
    return StatutChamp.values.firstWhere(
      (statut) => statut.name == valeur,
      orElse: () => throw ArgumentError('Statut de champ inconnu : $valeur'),
    );
  }
}

/// Modèle miroir de la table `champs_mesure`.
class ChampMesure {
  const ChampMesure({
    required this.id,
    required this.typeTenueId,
    required this.nom,
    required this.unite,
    required this.statut,
    required this.ordre,
    required this.updatedAt,
  });

  final String id;
  final String typeTenueId;
  final String nom;
  final String unite;
  final StatutChamp statut;
  final int ordre;
  final DateTime updatedAt;

  factory ChampMesure.depuisJson(Map<String, dynamic> json) {
    return ChampMesure(
      id: json['id'] as String,
      typeTenueId: json['type_tenue_id'] as String,
      nom: json['nom'] as String,
      unite: json['unite'] as String,
      statut: StatutChamp.depuisTexte(json['statut'] as String),
      ordre: json['ordre'] as int,
      // Repli sur l'heure actuelle si absent (voir Mesure.depuisJson).
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now().toUtc(),
    );
  }
}
