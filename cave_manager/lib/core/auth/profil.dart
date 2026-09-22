import '../constants/roles.dart';

/// Modèle applicatif d'un profil connecté (miroir de `public.profiles`).
class Profil {
  const Profil({
    required this.id,
    required this.caveId,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.role,
    required this.actif,
  });

  final String id;
  final String caveId;
  final String nom;
  final String prenom;
  final String telephone;
  final RoleUtilisateur role;
  final bool actif;

  String get nomComplet => '$prenom $nom';

  factory Profil.depuisJson(Map<String, dynamic> json) {
    return Profil(
      id: json['id'] as String,
      caveId: json['cave_id'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      telephone: json['telephone'] as String,
      role: RoleUtilisateur.depuisPostgres(json['role'] as String),
      actif: json['actif'] as bool,
    );
  }
}
