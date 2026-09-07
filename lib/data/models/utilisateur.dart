import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';

/// Les deux seuls rôles possibles dans un atelier.
enum RoleUtilisateur {
  proprietaire,
  apprenti;

  static RoleUtilisateur depuisTexte(String valeur) {
    return RoleUtilisateur.values.firstWhere(
      (r) => r.name == valeur,
      orElse: () => RoleUtilisateur.apprenti,
    );
  }
}

class Utilisateur {
  const Utilisateur({
    required this.id,
    required this.atelierId,
    required this.nom,
    required this.telephone,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String atelierId;
  final String nom;
  final String telephone;
  final RoleUtilisateur role;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get estProprietaire => role == RoleUtilisateur.proprietaire;

  factory Utilisateur.depuisSupabase(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] as String,
      atelierId: json['atelier_id'] as String,
      nom: json['nom'] as String,
      telephone: json['telephone'] as String,
      role: RoleUtilisateur.depuisTexte(json['role'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory Utilisateur.depuisLigneLocale(UtilisateurLocal ligne) {
    return Utilisateur(
      id: ligne.id,
      atelierId: ligne.atelierId,
      nom: ligne.nom,
      telephone: ligne.telephone,
      role: RoleUtilisateur.depuisTexte(ligne.role),
      createdAt: ligne.createdAt,
      updatedAt: ligne.updatedAt,
    );
  }

  UtilisateursCompanion versCompagnonLocal() {
    return UtilisateursCompanion(
      id: Value(id),
      atelierId: Value(atelierId),
      nom: Value(nom),
      telephone: Value(telephone),
      role: Value(role.name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
