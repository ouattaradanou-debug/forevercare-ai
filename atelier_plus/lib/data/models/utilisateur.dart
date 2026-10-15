import 'role_utilisateur.dart';

/// Modèle miroir de la table `utilisateurs`.
class Utilisateur {
  const Utilisateur({
    required this.id,
    required this.atelierId,
    required this.nom,
    required this.telephone,
    required this.role,
    required this.updatedAt,
  });

  final String id;
  final String atelierId;
  final String nom;
  final String telephone;
  final RoleUtilisateur role;
  final DateTime updatedAt;

  bool get estProprietaire => role == RoleUtilisateur.proprietaire;
  bool get estApprenti => role == RoleUtilisateur.apprenti;

  factory Utilisateur.depuisJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      nom: json['nom'] as String,
      telephone: json['telephone'] as String,
      role: RoleUtilisateur.depuisTexte(json['role'] as String),
      // Repli sur l'heure actuelle si absent (voir Mesure.depuisJson) :
      // aucune autre colonne de date fiable à utiliser ici.
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now().toUtc(),
    );
  }
}
