/// Modèle miroir de la table `permissions_apprenti`.
///
/// Volontairement AUCUN champ ne donne accès à commandes/paiements (le
/// suivi financier d'un client) — un apprenti ne peut jamais se voir
/// accorder cet accès, même par erreur d'UI, puisque le droit n'existe même
/// pas dans ce modèle (défense en profondeur avec la RLS qui applique la
/// même règle côté serveur). `ventes`/`stock`/`enregistrerDepenses` sont un
/// choix distinct et explicite du propriétaire : les ventes/dépenses
/// globales de l'atelier, pas le suivi financier d'un client en particulier.
class PermissionsApprenti {
  const PermissionsApprenti({
    required this.utilisateurId,
    required this.creerClient,
    required this.modifierClient,
    required this.prendreMesures,
    required this.ajouterPhotos,
    required this.modifierGabarits,
    required this.ventes,
    required this.stock,
    required this.enregistrerDepenses,
  });

  final String utilisateurId;
  final bool creerClient;
  final bool modifierClient;
  final bool prendreMesures;
  final bool ajouterPhotos;
  final bool modifierGabarits;
  final bool ventes;
  final bool stock;
  final bool enregistrerDepenses;

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
      ventes: false,
      stock: false,
      enregistrerDepenses: false,
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
      ventes: json['ventes'] as bool,
      stock: json['stock'] as bool,
      enregistrerDepenses: json['enregistrer_depenses'] as bool,
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'creer_client': creerClient,
      'modifier_client': modifierClient,
      'prendre_mesures': prendreMesures,
      'ajouter_photos': ajouterPhotos,
      'modifier_gabarits': modifierGabarits,
      'ventes': ventes,
      'stock': stock,
      'enregistrer_depenses': enregistrerDepenses,
    };
  }

  PermissionsApprenti copierAvec({
    bool? creerClient,
    bool? modifierClient,
    bool? prendreMesures,
    bool? ajouterPhotos,
    bool? modifierGabarits,
    bool? ventes,
    bool? stock,
    bool? enregistrerDepenses,
  }) {
    return PermissionsApprenti(
      utilisateurId: utilisateurId,
      creerClient: creerClient ?? this.creerClient,
      modifierClient: modifierClient ?? this.modifierClient,
      prendreMesures: prendreMesures ?? this.prendreMesures,
      ajouterPhotos: ajouterPhotos ?? this.ajouterPhotos,
      modifierGabarits: modifierGabarits ?? this.modifierGabarits,
      ventes: ventes ?? this.ventes,
      stock: stock ?? this.stock,
      enregistrerDepenses: enregistrerDepenses ?? this.enregistrerDepenses,
    );
  }
}
