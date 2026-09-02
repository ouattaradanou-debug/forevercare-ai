/// Rôle d'un utilisateur applicatif. Les valeurs doivent rester
/// synchronisées avec le CHECK constraint `utilisateurs.role` du schéma SQL.
enum RoleUtilisateur {
  proprietaire,
  apprenti;

  static RoleUtilisateur depuisTexte(String valeur) {
    return RoleUtilisateur.values.firstWhere(
      (role) => role.name == valeur,
      orElse: () => throw ArgumentError('Rôle utilisateur inconnu : $valeur'),
    );
  }
}
