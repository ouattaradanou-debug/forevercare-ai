import 'dart:math' as math;

import 'package:ecoleplus/core/db/app_database.dart';

/// Rubriques proposées à chaque école (A22 : l'école peut en ajouter, les
/// renommer ou les retirer ; la cantine arrive avec la phase 11).
const rubriquesParDefaut = {
  'scolarite': 'Scolarité',
  'cotisation': 'Cotisation',
  'assurance': 'Assurance',
  'carte_scolaire': 'Carte scolaire',
  'fournitures': 'Fournitures',
};

/// Rubriques des anciennes grilles (toujours lisibles).
const _anciennesRubriques = {'inscription': 'Inscription'};

/// Rubrique toujours disponible (recette sans élève, don…), jamais retirée.
const rubriqueAutre = 'autre';

/// Rubrique d'un reçu qui règle plusieurs rubriques (le détail est dans
/// payment_allocations).
const rubriquePlusieurs = 'plusieurs';

/// Code d'une nouvelle rubrique tiré de son libellé : « Frais d'examen » →
/// « frais_d_examen ».
String codeRubrique(String libelle) {
  final s = sansAccentsRubrique(libelle.trim().toLowerCase())
      .replaceAll(RegExp('[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  final c = s.length > 40 ? s.substring(0, 40) : s;
  return c.length < 2 || c == rubriqueAutre ? 'r_$c' : c;
}

String sansAccentsRubrique(String s) {
  const a = 'àâäéèêëîïôöùûüçœ';
  const b = 'aaaeeeeiioouuuco';
  return s.split('').map((c) {
    final i = a.indexOf(c);
    return i < 0 ? c : b[i];
  }).join();
}

/// Modes de paiement (A23) ; « Autre » se précise (Wave, Coris Money…).
const modesPaiement = {
  'especes': 'Espèces',
  'orange_money': 'Orange Money',
  'moov_money': 'Moov Money',
  'virement': 'Virement bancaire',
  'cheque': 'Chèque',
  'autre': 'Autre',
};

/// Modes des anciens reçus (toujours lisibles).
const _anciensModes = {'coris_money': 'Coris Money'};

/// Catégories de dépenses proposées (texte libre possible).
const categoriesDepenses = {
  'fournitures': 'Fournitures et matériel',
  'entretien': 'Entretien et réparations',
  'eau_electricite': 'Eau, électricité',
  'salaires': 'Salaires et indemnités',
  'transport': 'Transport et déplacements',
  'communication': 'Communication',
  'autre': 'Autre',
};

/// Libellé d'une rubrique : celui de l'école ([noms]), sinon celui proposé.
String libelleRubrique(String code, [Map<String, String>? noms]) =>
    noms?[code] ??
    rubriquesParDefaut[code] ??
    _anciennesRubriques[code] ??
    (code == rubriquePlusieurs ? 'Plusieurs rubriques' : null) ??
    (code == rubriqueAutre ? 'Autre' : code.replaceAll('_', ' '));
String libelleMode(String code, [String? precise]) =>
    code == 'autre' && (precise ?? '').isNotEmpty
    ? precise!
    : modesPaiement[code] ?? _anciensModes[code] ?? code;
String libelleCategorie(String code) => categoriesDepenses[code] ?? code;

/// « 25 000 » (espace fine insécable entre les milliers). Sans « FCFA »
/// (A25 : plus de place pour les chiffres) : la devise est indiquée une
/// fois par écran ou document.
String fcfa(int montant) {
  final signe = montant < 0 ? '−' : '';
  final s = montant.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return '$signe$b';
}

/// « 25 000 FCFA » : pour un texte envoyé hors de l'application (relance).
String fcfaTexte(int montant) => '${fcfa(montant)} FCFA';

/// Numéro de reçu, identique au contrôle du serveur
/// (`app.format_receipt_number`) : « 2025-2026 », série « A », 12 →
/// « R2526-A-00012 ».
String numeroRecu(String annee, String serie, int numero) =>
    'R${_aa(annee)}-$serie-${numero.toString().padLeft(5, '0')}';

/// Numéro de pièce de dépense : « D2526-A-00003 ».
String numeroPiece(String annee, String serie, int numero) =>
    'D${_aa(annee)}-$serie-${numero.toString().padLeft(5, '0')}';

String _aa(String annee) =>
    annee.length >= 9 ? annee.substring(2, 4) + annee.substring(7, 9) : annee;

/// Lignes de la grille qui s'appliquent à un élève : celles de sa classe ;
/// puis celles de son niveau ; puis celles de tous les niveaux. Une ligne
/// de classe remplace, pour sa rubrique, les lignes du niveau et de tous
/// les niveaux (A23 : chaque classe a son propre paramétrage).
List<FeeItemRow> fraisApplicables(
  List<FeeItemRow> grille, {
  required String? niveau,
  required String? classe,
}) {
  final actives = grille.where((f) => f.deletedAt == null).toList();
  final deClasse = [
    for (final f in actives)
      if (classe != null && f.classId == classe) f,
  ];
  final deNiveau = [
    for (final f in actives)
      if (f.classId == null && niveau != null && f.levelCode == niveau) f,
  ];
  final generales = [
    for (final f in actives)
      if (f.classId == null && f.levelCode == null) f,
  ];
  final pris = {for (final f in deClasse) f.rubric};
  final out = [...deClasse];
  final duNiveau = <String>{};
  for (final f in deNiveau) {
    if (!pris.contains(f.rubric)) {
      out.add(f);
      duNiveau.add(f.rubric);
    }
  }
  pris.addAll(duNiveau);
  for (final f in generales) {
    if (!pris.contains(f.rubric)) out.add(f);
  }
  return out;
}

/// Réduction accordée sur une ligne : pourcentages puis montants fixes,
/// arrondie au franc inférieur, jamais plus que le montant de la ligne.
/// Une remise s'applique à la ligne si elle vise cette ligne, sinon si sa
/// rubrique est celle de la ligne, sinon (ni ligne ni rubrique) à tout.
int reduction(
  FeeItemRow ligne,
  List<(DiscountRow, StudentDiscountRow)> remises,
) {
  var pourcent = 0.0;
  var fixe = 0.0;
  for (final (r, attribution) in remises) {
    if (r.deletedAt != null || attribution.deletedAt != null) continue;
    final vise = attribution.feeItemId;
    final s = vise != null
        ? vise == ligne.id
        : r.rubric == null || r.rubric == ligne.rubric;
    if (!s) continue;
    if (r.kind == 'pourcentage') {
      pourcent += r.value;
    } else {
      fixe += r.value;
    }
  }
  final total =
      (ligne.amount * math.min(pourcent, 100) / 100).floor() + fixe.floor();
  return math.min(total, ligne.amount);
}

/// Statut d'un versement ou d'une rubrique (couleurs discrètes à l'écran).
enum Statut { paye, partiel, impaye }

/// Statut financier d'un élève (A24).
enum StatutEleve { solde, partiel, impaye, aucunFrais }

/// Indicateurs d'un groupe d'élèves (école ou classe), calculés à partir
/// des situations individuelles : les totaux sont toujours la somme des
/// lignes.
class Synthese {
  const new({
    required this.du,
    required this.encaisse,
    required this.nbImpayes,
    required this.nbEleves,
  });

  factory depuis(Iterable<SituationEleve> eleves) {
    var du = 0;
    var encaisse = 0;
    var impayes = 0;
    var n = 0;
    for (final e in eleves) {
      du += e.du;
      encaisse += e.encaisse;
      if (e.reste > 0) impayes++;
      n++;
    }
    return Synthese(
      du: du,
      encaisse: encaisse,
      nbImpayes: impayes,
      nbEleves: n,
    );
  }

  final int du;
  final int encaisse;

  /// Élèves dont le montant restant est strictement positif.
  final int nbImpayes;
  final int nbEleves;

  int get restant => du - encaisse;

  /// Taux de recouvrement en % ; null quand rien n'est dû (pas de division
  /// par zéro).
  double? get taux => du == 0 ? null : encaisse * 100 / du;
}

/// « 72 % », « 66,7 % », « — » (rien de dû).
String texteTaux(double? taux) {
  if (taux == null) return '—';
  final arrondi = (taux * 10).round() / 10;
  final s = arrondi == arrondi.roundToDouble()
      ? arrondi.toStringAsFixed(0)
      : arrondi.toStringAsFixed(1).replaceAll('.', ',');
  return '$s %';
}

/// Un versement d'une ligne de la grille (A23) : le 1er, 2e, 3e versement
/// de la scolarité, ou la rubrique entière quand elle n'a pas de versements.
class VersementSituation {
  const new({
    required this.ligne,
    required this.libelle,
    required this.montant,
    required this.du,
    required this.paye,
    required this.echu,
    this.tranche,
    this.debut,
    this.echeance,
  });
  final FeeItemRow ligne;

  /// null : la rubrique n'a pas de versements (un seul paiement).
  final FeeInstallmentRow? tranche;
  final String libelle;

  /// Montant prévu (avant remise).
  final int montant;

  /// Dû après remise (répartie au prorata des versements).
  final int du;
  final int paye;
  final String? debut;

  /// Date limite ; null : à l'inscription (dû tout de suite).
  final String? echeance;

  /// Date limite passée (ou à l'inscription).
  final bool echu;

  int get reste => math.max(0, du - paye);
  int get impaye => echu ? reste : 0;

  /// Encaissé affecté à ce versement (un trop-perçu n'est pas compté :
  /// restant = dû − encaissé, toujours).
  int get encaisse => math.max(0, math.min(paye, du));
  bool get partielAutorise => ligne.paymentTerms != 'integral';
  Statut get statut => reste == 0
      ? Statut.paye
      : paye > 0
      ? Statut.partiel
      : Statut.impaye;

  /// Identifiant stable (case à cocher, détail du reçu).
  String get cle => tranche?.id ?? ligne.id;
}

/// Situation d'un élève pour une ligne de la grille.
class LigneSituation {
  const new({
    required this.ligne,
    required this.reduction,
    required this.versements,
  });
  final FeeItemRow ligne;
  final int reduction;
  final List<VersementSituation> versements;

  /// Montant dû après remise.
  int get du => versements.fold(0, (s, v) => s + v.du);

  /// Encaissé net (annulations déduites).
  int get paye => versements.fold(0, (s, v) => s + v.paye);

  /// Dû à la date du jour selon les dates limites (après remise).
  int get echu => versements.where((v) => v.echu).fold(0, (s, v) => s + v.du);

  int get reste => math.max(0, du - paye);

  /// Retard : échu et pas encore payé.
  int get impaye => versements.fold(0, (s, v) => s + v.impaye);

  /// Payé au-delà du dû (à rembourser ou à reporter).
  int get tropPercu => math.max(0, paye - du);
}

/// Situation financière d'un élève pour l'année.
class SituationEleve {
  const new({
    required this.studentId,
    required this.lignes,
    required this.autresRecettes,
  });
  final String studentId;
  final List<LigneSituation> lignes;

  /// Encaissements sans ligne de la grille (rubrique « autre »…).
  final int autresRecettes;

  int get du => lignes.fold(0, (s, l) => s + l.du);
  int get paye => lignes.fold(0, (s, l) => s + l.paye);
  int get reste => lignes.fold(0, (s, l) => s + l.reste);
  int get impaye => lignes.fold(0, (s, l) => s + l.impaye);
  bool get aJour => impaye == 0;

  /// Encaissé affecté aux frais (A24) : restant = dû − encaissé.
  int get encaisse => versements.fold(0, (s, v) => s + v.encaisse);

  /// Montant en retard : versements échus non réglés.
  int get enRetard => impaye;

  /// Autres versements : restant dû dont l'échéance n'est pas arrivée.
  int get aVenir => reste - enRetard;

  /// Soldé, partiellement payé, impayé (ou aucun frais).
  StatutEleve get statut => du == 0
      ? StatutEleve.aucunFrais
      : reste == 0
      ? StatutEleve.solde
      : encaisse > 0
      ? StatutEleve.partiel
      : StatutEleve.impaye;

  /// Tous les versements, dans l'ordre de la grille (tableau
  /// d'encaissement).
  List<VersementSituation> get versements => [
    for (final l in lignes) ...l.versements,
  ];
}

/// Montant dû à une date selon l'échéancier (tranches échues), après
/// remise répartie au prorata ; sans échéancier, tout est dû tout de suite.
int echuA(
  FeeItemRow ligne,
  int du,
  List<FeeInstallmentRow> tranches,
  String aujourdhui,
) {
  final t = [
    for (final x in tranches)
      if (x.feeItemId == ligne.id && x.deletedAt == null) x,
  ];
  if (t.isEmpty) return du;
  final brut = t
      .where((x) => x.dueOn == null || x.dueOn!.compareTo(aujourdhui) <= 0)
      .fold<int>(0, (s, x) => s + x.amount);
  if (ligne.amount == 0) return 0;
  return math.min(du, (brut * du / ligne.amount).round());
}

/// Calcule la situation d'un élève. Le détail des reçus ([allocations])
/// indique le versement réglé ; un reçu sans détail (avant A23) est imputé
/// aux versements de sa ligne dans l'ordre.
SituationEleve situation({
  required String studentId,
  required List<FeeItemRow> lignes,
  required List<FeeInstallmentRow> tranches,
  required List<(DiscountRow, StudentDiscountRow)> remises,
  required List<PaymentRow> paiements,
  required String aujourdhui,
  List<PaymentAllocationRow> allocations = const [],
}) {
  final siens = {
    for (final p in paiements)
      if (p.studentId == studentId) p.id: p,
  };
  final parPaiement = <String, List<PaymentAllocationRow>>{};
  for (final a in allocations) {
    if (siens.containsKey(a.paymentId)) {
      (parPaiement[a.paymentId] ??= []).add(a);
    }
  }
  final idsLignes = {for (final l in lignes) l.id};
  final parTranche = <String, int>{};
  final parLigne = <String, int>{};
  var autres = 0;
  for (final p in siens.values) {
    final detail = parPaiement[p.id];
    if (detail == null) {
      final f = p.feeItemId;
      if (f != null && idsLignes.contains(f)) {
        parLigne[f] = (parLigne[f] ?? 0) + p.amount;
      } else {
        autres += p.amount;
      }
      continue;
    }
    for (final a in detail) {
      final f = a.feeItemId;
      if (f == null || !idsLignes.contains(f)) {
        autres += a.amount;
      } else if (a.installmentId != null) {
        parTranche[a.installmentId!] =
            (parTranche[a.installmentId!] ?? 0) + a.amount;
      } else {
        parLigne[f] = (parLigne[f] ?? 0) + a.amount;
      }
    }
  }
  final miennes = [
    for (final r in remises)
      if (r.$2.studentId == studentId) r,
  ];
  return SituationEleve(
    studentId: studentId,
    autresRecettes: autres,
    lignes: [
      for (final l in lignes)
        _ligneSituation(
          l,
          reduction(l, miennes),
          [
            for (final t in tranches)
              if (t.feeItemId == l.id && t.deletedAt == null) t,
          ],
          parTranche,
          parLigne[l.id] ?? 0,
          aujourdhui,
        ),
    ],
  );
}

LigneSituation _ligneSituation(
  FeeItemRow l,
  int red,
  List<FeeInstallmentRow> tranches,
  Map<String, int> parTranche,
  int sansDetail,
  String aujourdhui,
) {
  bool echu(String? d) => d == null || d.compareTo(aujourdhui) <= 0;
  if (tranches.isEmpty) {
    return LigneSituation(
      ligne: l,
      reduction: red,
      versements: [
        VersementSituation(
          ligne: l,
          libelle: l.label,
          montant: l.amount,
          du: l.amount - red,
          paye: sansDetail,
          echu: true,
        ),
      ],
    );
  }
  // Remise répartie au prorata ; l'arrondi va au dernier versement.
  final brut = tranches.fold<int>(0, (s, t) => s + t.amount);
  var reste = red;
  final dus = <int>[];
  for (final (i, t) in tranches.indexed) {
    final part = i == tranches.length - 1
        ? reste
        : (brut == 0 ? 0 : (red * t.amount / brut).floor());
    reste -= part;
    dus.add(t.amount - part);
  }
  // Paiements sans détail : imputés aux versements dans l'ordre.
  var aImputer = sansDetail;
  final payes = <int>[];
  for (final (i, t) in tranches.indexed) {
    var p = parTranche[t.id] ?? 0;
    if (aImputer != 0) {
      final place = i == tranches.length - 1
          ? aImputer
          : math.min(aImputer, math.max(0, dus[i] - p));
      p += place;
      aImputer -= place;
    }
    payes.add(p);
  }
  return LigneSituation(
    ligne: l,
    reduction: red,
    versements: [
      for (final (i, t) in tranches.indexed)
        VersementSituation(
          ligne: l,
          tranche: t,
          libelle: t.label,
          montant: t.amount,
          du: dus[i],
          paye: payes[i],
          debut: t.startsOn,
          echeance: t.dueOn,
          echu: echu(t.dueOn),
        ),
    ],
  );
}

/// Un reçu et son éventuelle annulation.
extension PaiementX on PaymentRow {
  bool get estAnnulation => reversesPaymentId != null;
}

/// Prochain numéro d'encaissement de ce téléphone pour l'année : les
/// numéros ne reviennent jamais en arrière (ni après synchronisation).
int prochainNumero(Iterable<int> dejaUtilises) =>
    dejaUtilises.fold(0, math.max) + 1;

/// Montant en toutes lettres (reçu) : 25 000 → « vingt-cinq mille francs
/// CFA ». Orthographe rectifiée de 1990 (traits d'union partout).
String enLettres(int montant) {
  if (montant == 0) return 'zéro franc CFA';
  final n = montant.abs();
  final mots = _nombre(n);
  final s = '${montant < 0 ? 'moins ' : ''}$mots';
  return '$s ${n > 1 ? 'francs' : 'franc'} CFA';
}

const _unites = [
  'zéro', 'un', 'deux', 'trois', 'quatre', 'cinq', 'six', 'sept', 'huit', //
  'neuf', 'dix', 'onze', 'douze', 'treize', 'quatorze', 'quinze', 'seize',
  'dix-sept', 'dix-huit', 'dix-neuf',
];
const _dizaines = [
  '', '', 'vingt', 'trente', 'quarante', 'cinquante', 'soixante', //
  'soixante', 'quatre-vingt', 'quatre-vingt',
];

String _moinsDeCent(int n) {
  if (n < 20) return _unites[n];
  final d = n ~/ 10;
  final u = n % 10;
  if (d == 7 || d == 9) {
    final reste = 10 + u;
    final et = d == 7 && u == 1 ? '-et-' : '-';
    return '${_dizaines[d]}$et${_unites[reste]}';
  }
  if (u == 0) return d == 8 ? 'quatre-vingts' : _dizaines[d];
  if (u == 1 && d != 8) return '${_dizaines[d]}-et-un';
  return '${_dizaines[d]}-${_unites[u]}';
}

String _moinsDeMille(int n) {
  final c = n ~/ 100;
  final r = n % 100;
  final parts = <String>[];
  if (c > 1) {
    parts.add(r == 0 ? '${_unites[c]}-cents' : '${_unites[c]}-cent');
  } else if (c == 1) {
    parts.add('cent');
  }
  if (r > 0) parts.add(_moinsDeCent(r));
  return parts.join('-');
}

String _nombre(int n) {
  if (n < 1000) return _moinsDeMille(n);
  const echelles = [(1000000000, 'milliard'), (1000000, 'million')];
  for (final (valeur, nom) in echelles) {
    if (n >= valeur) {
      final q = n ~/ valeur;
      final r = n % valeur;
      final tete = '${_nombre(q)}-$nom${q > 1 ? 's' : ''}';
      return r == 0 ? tete : '$tete-${_nombre(r)}';
    }
  }
  final milliers = n ~/ 1000;
  final r = n % 1000;
  var tete = milliers == 1 ? 'mille' : '${_moinsDeMille(milliers)}-mille';
  // « quatre-vingts » et « deux-cents » perdent leur s devant « mille ».
  tete = tete
      .replaceAll('vingts-mille', 'vingt-mille')
      .replaceAll('cents-mille', 'cent-mille');
  return r == 0 ? tete : '$tete-${_moinsDeMille(r)}';
}

/// Message de relance préparé (jamais envoyé automatiquement).
String messageRelance({
  required String ecole,
  required String eleve,
  required String classe,
  required int impaye,
  String? telephoneEcole,
}) =>
    'Bonjour, l’école $ecole vous informe qu’un montant de '
    '${fcfaTexte(impaye)} '
    'reste à régler pour la scolarité de $eleve ($classe). Merci de passer '
    'au secrétariat de l’école'
    '${telephoneEcole == null || telephoneEcole.isEmpty ? '' : ' ou '
              'd’appeler le $telephoneEcole'}. '
    'Si vous avez déjà réglé, merci de ne pas tenir compte de ce message.';

/// Ligne du journal de caisse (encaissements et dépenses, dans l'ordre).
class MouvementCaisse {
  const new({
    required this.date,
    required this.numero,
    required this.libelle,
    required this.montant,
    required this.mode,
    this.annulation = false,
  });
  final String date;
  final String numero;
  final String libelle;

  /// Positif : entrée ; négatif : sortie.
  final int montant;
  final String? mode;
  final bool annulation;
}

/// Journal de caisse d'une période (« 2026-10 » ou toute l'année).
List<MouvementCaisse> journalCaisse({
  required List<PaymentRow> paiements,
  required List<ExpenseRow> depenses,
  required String Function(String? studentId) nomEleve,
  String? mois,
  Map<String, String>? rubriques,
}) {
  bool dans(String date) => mois == null || date.startsWith(mois);
  final out = <MouvementCaisse>[
    for (final p in paiements)
      if (dans(p.paidAt))
        MouvementCaisse(
          date: p.paidAt,
          numero: p.receiptNumber,
          libelle: p.estAnnulation
              ? 'Annulation : ${p.reversalReason ?? ''}'
              : '${libelleRubrique(p.rubric, rubriques)} — '
                    '${nomEleve(p.studentId)}',
          montant: p.amount,
          mode: p.method,
          annulation: p.estAnnulation,
        ),
    for (final d in depenses)
      if (dans(d.spentOn))
        MouvementCaisse(
          date: d.spentOn,
          numero: d.voucherNumber ?? '',
          libelle: d.reversesExpenseId != null
              ? 'Annulation : ${d.reversalReason ?? ''}'
              : '${libelleCategorie(d.category)} — ${d.label}',
          montant: -d.amount,
          mode: d.method,
          annulation: d.reversesExpenseId != null,
        ),
  ];
  // Par jour ; dans une même journée, les encaissements avant les
  // dépenses (la date d'une dépense n'a pas d'heure).
  int ordre(MouvementCaisse m) => m.numero.startsWith('R') ? 0 : 1;
  return out..sort((a, b) {
    final d = a.date.substring(0, 10).compareTo(b.date.substring(0, 10));
    if (d != 0) return d;
    final k = ordre(a).compareTo(ordre(b));
    return k != 0 ? k : a.date.compareTo(b.date);
  });
}

/// Solde d'une liste de mouvements (tous modes, ou un seul mode).
int solde(List<MouvementCaisse> mouvements, {String? mode}) => mouvements
    .where((m) => mode == null || m.mode == mode)
    .fold(0, (s, m) => s + m.montant);
