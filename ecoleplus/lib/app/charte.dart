import 'package:flutter/material.dart';

/// Charte graphique d'EcolePlus (A28) : la palette, les rayons et les
/// espacements utilisés par TOUS les écrans. Aucune couleur ne doit être
/// codée en dur ailleurs : on passe par ces constantes ou par le thème.
abstract final class Charte {
  // ------------------------------ Palette ------------------------------

  /// Bleu marine : en-têtes, titres importants, éléments structurants.
  static const marine = Color(0xFF13315C);

  /// Bleu marine foncé : texte principal sur fond clair.
  static const marineFonce = Color(0xFF0B2545);

  /// Bleu moyen : liens, icônes actives, éléments interactifs secondaires.
  static const bleu = Color(0xFF2563B5);

  /// Bleu clair : cartes et surfaces complémentaires.
  static const bleuClair = Color(0xFFEAF1FB);

  /// Orange : actions importantes, sélection, mise en évidence.
  static const orange = Color(0xFFF28C28);

  /// Orange foncé : texte orange lisible sur fond blanc.
  static const orangeFonce = Color(0xFFB35C00);

  /// Orange pâle : fond des éléments sélectionnés, lignes de total.
  static const orangePale = Color(0xFFFFF1E0);

  /// Blanc : surfaces dominantes.
  static const blanc = Color(0xFFFFFFFF);

  /// Gris très clair : arrière-plan de l'application.
  static const fond = Color(0xFFF4F6FA);

  /// Gris des bordures et séparateurs.
  static const bordure = Color(0xFFE2E7EF);

  /// Gris du texte secondaire.
  static const texteSecondaire = Color(0xFF5B6576);

  /// Vert : réussite, situation positive.
  static const vert = Color(0xFF1E8E4E);
  static const vertPale = Color(0xFFE6F5EC);

  /// Rouge : erreur, alerte.
  static const rouge = Color(0xFFD03A3A);
  static const rougePale = Color(0xFFFDECEC);

  /// Ambre : attention (en attente, en retard).
  static const ambre = Color(0xFFB7791F);
  static const ambrePale = Color(0xFFFFF6E0);

  /// Violet et turquoise : couleurs complémentaires des modules.
  static const violet = Color(0xFF6D4ED8);
  static const violetPale = Color(0xFFF0ECFE);
  static const turquoise = Color(0xFF0E9AA7);
  static const turquoisePale = Color(0xFFE2F6F7);

  // ------------------------------ Formes ------------------------------

  /// Rayon des cartes et des tableaux.
  static const rayon = 14.0;

  /// Rayon des boutons et des champs.
  static const rayonBouton = 12.0;

  /// Rayon des fenêtres de dialogue.
  static const rayonDialogue = 20.0;

  /// Ombre discrète des cartes.
  static const ombre = [
    BoxShadow(color: Color(0x14132F5C), blurRadius: 10, offset: Offset(0, 3)),
  ];

  /// Marge latérale des écrans.
  static const marge = 16.0;
}

/// Couleur d'un module (icône + fond doux) : chaque module garde la même
/// couleur partout (accueil, page du module, tableau de bord).
class CouleurModule {
  const new(this.couleur, this.fond);
  final Color couleur;
  final Color fond;

  static const eleves = CouleurModule(Charte.bleu, Charte.bleuClair);
  static const pedagogie = CouleurModule(
    Charte.turquoise,
    Charte.turquoisePale,
  );
  static const administration = CouleurModule(Charte.violet, Charte.violetPale);
  static const finances = CouleurModule(Charte.vert, Charte.vertPale);
  static const rapports = CouleurModule(Charte.orangeFonce, Charte.orangePale);
  static const bibliotheque = CouleurModule(
    Color(0xFF8A4FBF),
    Color(0xFFF5EDFB),
  );
  static const ecole = CouleurModule(Charte.marine, Color(0xFFE7ECF4));
  static const bord = CouleurModule(Charte.marine, Color(0xFFE7ECF4));
  static const recherche = CouleurModule(Charte.orangeFonce, Charte.orangePale);

  /// Couleur d'un thème de l'accueil (par son identifiant).
  static CouleurModule duTheme(String id) => switch (id) {
    'eleves' || 'classe' => eleves,
    'pedagogie' || 'notes' => pedagogie,
    'administration' => administration,
    'finances' => finances,
    'rapports' => rapports,
    'bibliotheque' || 'ia' => bibliotheque,
    _ => ecole,
  };
}

/// Statut à afficher en pastille (même apparence dans tous les modules).
enum TonStatut {
  succes(Charte.vert, Charte.vertPale, Icons.check_circle),
  attention(Charte.ambre, Charte.ambrePale, Icons.schedule),
  erreur(Charte.rouge, Charte.rougePale, Icons.error),
  info(Charte.bleu, Charte.bleuClair, Icons.info),
  neutre(Charte.texteSecondaire, Color(0xFFEFF2F6), Icons.circle_outlined);

  new(this.couleur, this.fond, this.icone);
  final Color couleur;
  final Color fond;
  final IconData icone;
}
