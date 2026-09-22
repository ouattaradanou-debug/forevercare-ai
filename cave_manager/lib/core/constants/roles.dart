/// Les 4 profils utilisateurs (point 2 du cahier des charges).
///
/// Les valeurs `nomPostgres` doivent rester synchronisées avec le type
/// `public.role_utilisateur` défini dans
/// `supabase/migrations/0001_phase1_fondations.sql`.
enum RoleUtilisateur {
  proprietaire('proprietaire', 'Propriétaire'),
  proprietaireGerant('proprietaire_gerant', 'Propriétaire/Gérant'),
  gerant('gerant', 'Gérant'),
  agentVente('agent_vente', 'Agent de vente');

  const RoleUtilisateur(this.nomPostgres, this.libelle);

  /// Valeur exacte de l'enum côté base de données.
  final String nomPostgres;

  /// Libellé affiché à l'écran (vocabulaire du cahier des charges,
  /// respecté à l'identique — voir critères de qualité du prompt).
  final String libelle;

  static RoleUtilisateur depuisPostgres(String valeur) {
    return RoleUtilisateur.values.firstWhere(
      (r) => r.nomPostgres == valeur,
      orElse: () => throw ArgumentError('Rôle inconnu : $valeur'),
    );
  }

  /// Un responsable peut contrôler, valider, encaisser et clôturer.
  bool get estResponsable =>
      this == RoleUtilisateur.proprietaire ||
      this == RoleUtilisateur.proprietaireGerant ||
      this == RoleUtilisateur.gerant;

  /// Seuls ces rôles peuvent gérer les utilisateurs et les produits.
  bool get estAdministrateur =>
      this == RoleUtilisateur.proprietaire ||
      this == RoleUtilisateur.proprietaireGerant;

  /// Contrainte de sécurité non négociable : l'agent de vente ne doit
  /// jamais avoir accès au stock global, aux bénéfices, aux clôtures, aux
  /// rapports financiers ou aux paramètres. Ce booléen sert uniquement à
  /// adapter l'UI (raccourci de confort) ; le blocage réel et non
  /// contournable est appliqué par les policies RLS côté Supabase.
  bool get estAgentDeVente => this == RoleUtilisateur.agentVente;
}
