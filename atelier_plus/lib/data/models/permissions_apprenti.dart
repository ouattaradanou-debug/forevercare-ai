/// Modèle miroir de la table `permissions_apprenti`.
///
/// Volontairement AUCUN champ financier — un apprenti ne peut jamais se voir
/// accorder un accès à commandes/paiements, même par erreur d'UI, puisque
/// le droit n'existe même pas dans ce modèle (défense en profondeur avec la
/// RLS qui applique la même règle côté serveur).
class PermissionsApprenti {
  const PermissionsApprenti({
    required this.utilisateurId,
    required this.creerClient,
    required this.modifierClient,
    required this.prendreMesures,
    required this.ajouterPhotos,
    required this.modifierGabarits,
  });

  final String utilisateurId;
  final bool creerClient;
  final bool modifierClient;
  final bool prendreMesures;
  final bool ajouterPhotos;
  final bool modifierGabarits;

  /// Aucune permission active — état par défaut garanti aussi côté base de
  /// données par le déclencheur `creer_permissions_apprenti_par_defaut`.
  factory PermissionsApprenti.aucunePermission(String utilisateurId) {
    return PermissionsApprenti(
      utilisateurId: utilisateurId,
      creerClient: false,
      modifierClient: false,
      prendreMesures: false,
      ajouterPhotos: false,
      modifierGabarits: false,
    );
  }

  factory PermissionsApprenti.depuisJson(Map<String, dynamic> json) {
    return PermissionsApprenti(
      utilisateurId: json['utilisateur_id'] as String,
      creerClient: json['creer_client'] as bool,
      modifierClient: json['modifier_client'] as bool,
      prendreMesures: json['prendre_mesures'] as bool,
      ajouterPhotos: json['ajouter_photos'] as bool,
      modifierGabarits: json['modifier_gabarits'] as bool,
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'creer_client': creerClient,
      'modifier_client': modifierClient,
      'prendre_mesures': prendreMesures,
      'ajouter_photos': ajouterPhotos,
      'modifier_gabarits': modifierGabarits,
    };
  }

  PermissionsApprenti copierAvec({
    bool? creerClient,
    bool? modifierClient,
    bool? prendreMesures,
    bool? ajouterPhotos,
    bool? modifierGabarits,
  }) {
    return PermissionsApprenti(
      utilisateurId: utilisateurId,
      creerClient: creerClient ?? this.creerClient,
      modifierClient: modifierClient ?? this.modifierClient,
      prendreMesures: prendreMesures ?? this.prendreMesures,
      ajouterPhotos: ajouterPhotos ?? this.ajouterPhotos,
      modifierGabarits: modifierGabarits ?? this.modifierGabarits,
    );
  }
}
