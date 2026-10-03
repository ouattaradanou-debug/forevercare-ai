/// Modèle miroir de la table `membres_groupe_uniforme`.
class MembreGroupeUniforme {
  const MembreGroupeUniforme({
    required this.id,
    required this.groupeId,
    this.nom,
    this.prenom,
    this.sexe,
    required this.tenueTerminee,
    required this.updatedAt,
  });

  final String id;
  final String groupeId;
  final String? nom;
  final String? prenom;
  final String? sexe;
  final bool tenueTerminee;
  final DateTime updatedAt;

  String get nomComplet {
    final morceaux = [nom, prenom].whereType<String>().where((m) => m.isNotEmpty);
    return morceaux.isEmpty ? 'Sans nom' : morceaux.join(' ');
  }

  factory MembreGroupeUniforme.depuisJson(Map<String, dynamic> json) {
    return MembreGroupeUniforme(
      id: json['id'] as String,
      groupeId: json['groupe_id'] as String,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      sexe: json['sexe'] as String?,
      tenueTerminee: json['tenue_terminee'] as bool,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'id': id,
      'groupe_id': groupeId,
      'nom': nom,
      'prenom': prenom,
      'sexe': sexe,
      'tenue_terminee': tenueTerminee,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MembreGroupeUniforme copierAvec({bool? tenueTerminee}) {
    return MembreGroupeUniforme(
      id: id,
      groupeId: groupeId,
      nom: nom,
      prenom: prenom,
      sexe: sexe,
      tenueTerminee: tenueTerminee ?? this.tenueTerminee,
      updatedAt: DateTime.now().toUtc(),
    );
  }
}
