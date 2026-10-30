import 'dart:math' as math;

import 'package:ecoleplus/core/db/app_database.dart';

/// Rubriques de la grille (la cantine arrive avec la phase 11).
const rubriques = {
  'inscription': 'Inscription',
  'scolarite': 'Scolarité',
  'cotisation': 'Cotisation',
  'fournitures': 'Fournitures',
  'autre': 'Autre',
};

/// Modes de paiement (10.2).
const modesPaiement = {
  'especes': 'Espèces',
  'orange_money': 'Orange Money',
  'moov_money': 'Moov Money',
  'coris_money': 'Coris Money',
  'virement': 'Virement',
  'cheque': 'Chèque',
};

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

String libelleRubrique(String code) => rubriques[code] ?? code;
String libelleMode(String code) => modesPaiement[code] ?? code;
String libelleCategorie(String code) => categoriesDepenses[code] ?? code;

/// « 25 000 FCFA » (espace fine insécable entre les milliers).
String fcfa(int montant) {
  final signe = montant < 0 ? '−' : '';
  final s = montant.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return '$signe$b FCFA';
}

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
/// de classe remplace la ligne de même rubrique et même libellé de son
/// niveau (tarif ajusté pour une classe).
List<FeeItemRow> fraisApplicables(
  List<FeeItemRow> grille, {
  required String? niveau,
  required String? classe,
}) {
  String cle(FeeItemRow f) => '${f.rubric}|${f.label.trim().toLowerCase()}';
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
  final vues = <String>{};
  final out = <FeeItemRow>[];
  for (final f in [...deClasse, ...deNiveau, ...generales]) {
    if (vues.add(cle(f))) out.add(f);
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

/// Situation d'un élève pour une ligne de la grille.
class LigneSituation {
  const new({
    required this.ligne,
    required this.du,
    required this.reduction,
    required this.paye,
    required this.echu,
  });
  final FeeItemRow ligne;

  /// Montant dû après remise.
  final int du;
  final int reduction;

  /// Encaissé net (annulations déduites).
  final int paye;

  /// Dû à la date du jour selon l'échéancier (après remise).
  final int echu;

  int get reste => math.max(0, du - paye);

  /// Retard : échu et pas encore payé.
  int get impaye => math.max(0, math.min(echu, du) - paye);

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

/// Calcule la situation d'un élève.
SituationEleve situation({
  required String studentId,
  required List<FeeItemRow> lignes,
  required List<FeeInstallmentRow> tranches,
  required List<(DiscountRow, StudentDiscountRow)> remises,
  required List<PaymentRow> paiements,
  required String aujourdhui,
}) {
  final siens = [
    for (final p in paiements)
      if (p.studentId == studentId) p,
  ];
  final parLigne = <String, int>{};
  var autres = 0;
  for (final p in siens) {
    final f = p.feeItemId;
    if (f != null && lignes.any((l) => l.id == f)) {
      parLigne[f] = (parLigne[f] ?? 0) + p.amount;
    } else {
      autres += p.amount;
    }
  }
  return SituationEleve(
    studentId: studentId,
    autresRecettes: autres,
    lignes: [
      for (final l in lignes)
        () {
          final red = reduction(l, [
            for (final r in remises)
              if (r.$2.studentId == studentId) r,
          ]);
          final du = l.amount - red;
          return LigneSituation(
            ligne: l,
            du: du,
            reduction: red,
            paye: parLigne[l.id] ?? 0,
            echu: echuA(l, du, tranches, aujourdhui),
          );
        }(),
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
    'Bonjour, l’école $ecole vous informe qu’un montant de ${fcfa(impaye)} '
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
              : '${libelleRubrique(p.rubric)} — ${nomEleve(p.studentId)}',
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
