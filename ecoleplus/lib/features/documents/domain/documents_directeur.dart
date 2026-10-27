/// Documents délivrés par le directeur (A17), d'après les modèles fournis
/// par le porteur (école de Barkouitenga) : attestation de prise de
/// service, certificat de scolarité (page entière ou demi-page), attestation
/// de niveau, certificat de non redevance.
library;

/// Code du document (`issued_documents.doc_code`).
enum CodeDocument {
  priseService('prise_service', 'Attestation de prise de service'),
  certificatScolarite('certificat_scolarite', 'Certificat de scolarité'),
  attestationNiveau('attestation_niveau', 'Attestation de niveau'),
  nonRedevance('non_redevance', 'Certificat de non redevance');

  new(this.code, this.titre);
  final String code;
  final String titre;
  bool get pourEnseignant => this == priseService;

  static CodeDocument? depuis(String code) =>
      values.where((c) => c.code == code).firstOrNull;
}

/// Le directeur qui signe : « Je soussignée Madame … Directrice … ».
class Signataire {
  const new({this.civilite, this.nom, this.grade});

  /// « madame », « monsieur » ou null (inconnu).
  final String? civilite;
  final String? nom;

  /// « Professeur Certifié des Écoles »…
  final String? grade;

  bool get femme => civilite == 'madame';
  bool get connu => civilite != null;
  String get fonction =>
      connu ? (femme ? 'Directrice' : 'Directeur') : 'Directeur/Directrice';
  String get soussigne =>
      connu ? (femme ? 'soussignée' : 'soussigné') : 'soussigné(e)';
  String get civiliteTexte => switch (civilite) {
    'madame' => 'Madame',
    'monsieur' => 'Monsieur',
    _ => '',
  };

  /// « La Directrice », « Le Directeur ».
  String get titreSignature =>
      connu ? (femme ? 'La Directrice' : 'Le Directeur') : 'Le Directeur';
}

/// Accords selon le sexe de l'élève ou de l'enseignant.
class Accords {
  const new(this.sexe);

  /// « F », « M » ou null.
  final String? sexe;
  bool get fille => sexe == 'F';
  bool get garcon => sexe == 'M';
  String _choix(String f, String m, String inconnu) =>
      fille ? f : (garcon ? m : inconnu);

  String get filsFille => _choix('Fille', 'Fils', 'Fils/Fille');
  String get ne => _choix('née', 'né', 'né(e)');
  String get il => _choix('elle', 'il', 'il/elle');
  String get inscrit => _choix('inscrite', 'inscrit', 'inscrit(e)');
  String get affecte => _choix('affectée', 'affecté', 'affecté(e)');
  String get monsieurMadame => _choix('Mme', 'M.', 'M./Mme');
}

/// « de l'École Primaire Publique de X » / « de l'école X ».
String deLEcole(String nom) {
  final n = nom.trim();
  final debut = n.toLowerCase();
  return debut.startsWith('école') || debut.startsWith('ecole')
      ? 'de l’$n'
      : 'de l’école $n';
}

/// En-tête des documents (en-têtes administratifs de l'année).
class EnteteDocument {
  const new({
    required this.ecole,
    this.ministere,
    this.directionRegionale,
    this.directionProvinciale,
    this.ceb,
    this.pays = 'BURKINA FASO',
    this.devise,
    this.anneeScolaire,
  });
  final String ecole;
  final String? ministere;
  final String? directionRegionale;
  final String? directionProvinciale;

  /// Circonscription d'éducation de base (nom seul, ex. « Ziniaré II »).
  final String? ceb;
  final String pays;
  final String? devise;
  final String? anneeScolaire;

  /// Colonne de gauche du grand en-tête (page entière), en majuscules.
  List<String> get lignesLongues => [
    if (ministere != null) ministere!.toUpperCase(),
    if (directionRegionale != null) directionRegionale!.toUpperCase(),
    if (directionProvinciale != null) directionProvinciale!.toUpperCase(),
    if (ceb != null)
      'CIRCONSCRIPTION D’ÉDUCATION DE BASE DE ${ceb!.toUpperCase()}',
    ecole.toUpperCase(),
  ];

  /// Colonne de gauche du petit en-tête (demi-page).
  List<String> get lignesCourtes => [
    if (ceb != null) 'Circonscription d’Éducation de Base de $ceb',
    ecole,
  ];
}

/// Élève concerné par un certificat ou une attestation.
class EleveDocument {
  const new({
    required this.nom,
    this.sexe,
    this.neLe,
    this.lieuNaissance,
    this.pere,
    this.professionPere,
    this.mere,
    this.professionMere,
    this.matricule,
    this.classe,
    this.niveau,
    this.entreLe,
  });
  final String nom;
  final String? sexe;
  final String? neLe;
  final String? lieuNaissance;
  final String? pere;
  final String? professionPere;
  final String? mere;
  final String? professionMere;
  final String? matricule;

  /// Nom de la classe (« CM2 A ») et niveau (« CM2 »).
  final String? classe;
  final String? niveau;
  final String? entreLe;
  Accords get accords => Accords(sexe);
}

/// Enseignant concerné par l'attestation de prise de service.
class EnseignantDocument {
  const new({
    required this.nom,
    this.sexe,
    this.matricule,
    this.emploi,
    this.decisionNumero,
    this.decisionDate,
    this.priseDeService,
  });
  final String nom;
  final String? sexe;
  final String? matricule;

  /// « Instituteur Certifié »…
  final String? emploi;
  final String? decisionNumero;
  final String? decisionDate;
  final String? priseDeService;
  Accords get accords => Accords(sexe);
}

/// Ce qui manque pour un document complet (affiché avant l'impression ;
/// l'impression reste possible : les blancs sont imprimés en pointillés).
List<String> manquesDocument(
  CodeDocument code, {
  required Signataire signataire,
  EleveDocument? eleve,
  EnseignantDocument? enseignant,
}) => [
  if (signataire.nom == null) 'nom du directeur (Mon école)',
  if (!signataire.connu) 'Madame ou Monsieur (Mon école)',
  if (eleve != null) ...[
    if (eleve.neLe == null) 'date de naissance',
    if (code != CodeDocument.attestationNiveau && eleve.lieuNaissance == null)
      'lieu de naissance',
    if (eleve.pere == null && eleve.mere == null) 'parents',
    if (code == CodeDocument.certificatScolarite && eleve.matricule == null)
      'N° matricule',
    if (eleve.classe == null) 'classe de cette année',
  ],
  if (enseignant != null) ...[
    if (enseignant.matricule == null) 'matricule',
    if (enseignant.emploi == null) 'emploi',
    if (enseignant.decisionNumero == null) 'n° de la décision d’affectation',
    if (enseignant.priseDeService == null) 'date de prise de service',
  ],
];

/// Tout ce qu'il faut pour imprimer un document.
class DocumentDirecteur {
  const new({
    required this.code,
    required this.entete,
    required this.signataire,
    this.eleve,
    this.enseignant,
    this.lieu,
    this.date,
    this.niveau,
    this.court = false,
  });
  final CodeDocument code;
  final EnteteDocument entete;
  final Signataire signataire;
  final EleveDocument? eleve;
  final EnseignantDocument? enseignant;

  /// « Fait à … » (commune de l'école par défaut) et date (jj/mm/aaaa).
  final String? lieu;
  final String? date;

  /// Attestation de niveau : « a le niveau de la classe de … ».
  final String? niveau;

  /// Certificat de scolarité : modèle demi-page (sinon page entière).
  final bool court;
}
