import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';

/// Rubrique des cotisations de cantine dans les Finances (mêmes reçus).
const rubriqueCantine = 'cantine';

/// Catégorie des dépenses de cantine dans le journal de caisse commun.
const categorieCantine = 'cantine';

/// Modes de fonctionnement (10.9).
const modesCantine = {
  'sans_participation':
      'Sans participation des familles (bénéficiaires '
      'seulement)',
  'avec_participation': 'Avec participation financière des familles',
  'mixte': 'Mixte (certaines familles participent, d’autres non)',
};

/// Provenance des entrées de vivres.
const provenances = {
  'parents': 'Contribution des parents',
  'produits_locaux': 'Produits locaux (communauté)',
  'don': 'Don',
  'achat': 'Achat',
  'partenaire': 'Partenaire',
  'autre': 'Autre',
};

/// Motifs des sorties de vivres.
const motifsSortie = {'repas': 'Repas', 'perte': 'Perte', 'autre': 'Autre'};

/// Unités proposées (texte libre possible).
const unitesProposees = ['kg', 'sac', 'litre', 'bidon', 'boîte', 'sachet'];

/// Exemples de dépenses de cantine (texte libre).
const exemplesDepensesCantine = [
  'Bois de chauffe / combustible',
  'Condiments',
  'Main-d’œuvre (cuisinières)',
  'Entretien du matériel',
  'Eau',
];

String libelleMouvement(StockMovementRow m) => switch (m.kind) {
  'entree' => 'Entrée — ${provenances[m.provenance] ?? m.provenance ?? ''}',
  'sortie' => 'Sortie — ${motifsSortie[m.outReason] ?? m.outReason ?? ''}',
  'ajustement' => 'Inventaire — ${m.reason ?? ''}',
  _ => 'Annulation — ${m.reason ?? ''}',
};

/// Quantité arrondie au millième (les quantités du serveur ont 3 décimales).
double arrondiQte(double q) => (q * 1000).round() / 1000;

/// « 12,5 », « 3 », « 0,25 » (virgule, sans zéros inutiles).
String qte(double q) {
  final r = arrondiQte(q);
  if (r == r.roundToDouble()) return fcfa(r.round());
  final s = r.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '');
  final (entier, dec) = (s.split('.').first, s.split('.').last);
  final e = int.parse(entier.replaceAll('-', ''));
  return '${r < 0 ? '−' : ''}${fcfa(e)},$dec';
}

/// Lit une quantité saisie (« 12,5 », « 12.5 », « 3 ») ; null si invalide.
double? lireQte(String texte) {
  final t = texte.trim().replaceAll(' ', '').replaceAll(' ', '');
  if (t.isEmpty) return null;
  final v = double.tryParse(t.replaceAll(',', '.'));
  if (v == null || v.isNaN || v.isInfinite) return null;
  return arrondiQte(v);
}

/// Stock courant d'un produit : somme des mouvements (entrées positives,
/// sorties négatives, inventaires et annulations).
double stockCourant(Iterable<StockMovementRow> mouvements, String produitId) =>
    arrondiQte(
      mouvements
          .where((m) => m.productId == produitId)
          .fold<double>(0, (s, m) => s + m.quantityDelta),
    );

/// État d'un produit (liste du stock).
class EtatProduit {
  const new(this.produit, this.stock);
  final StockProductRow produit;
  final double stock;

  /// Stock au seuil d'alerte ou en dessous.
  bool get alerte =>
      produit.alertThreshold != null && stock <= produit.alertThreshold!;

  /// Ne devrait jamais arriver sur un seul téléphone ; possible après la
  /// fusion de sorties saisies hors ligne sur deux téléphones.
  bool get negatif => stock < 0;
}

List<EtatProduit> etatsStock(
  List<StockProductRow> produits,
  List<StockMovementRow> mouvements,
) => [
  for (final p in produits)
    if (p.deletedAt == null) EtatProduit(p, stockCourant(mouvements, p.id)),
];

/// Contrôle d'une sortie : refusée au-delà du stock (choix du directeur
/// pilote, 04/11/2026). Renvoie le message d'erreur, ou null.
String? controleSortie({
  required double stock,
  required double quantite,
  required String unite,
}) {
  if (quantite <= 0) return 'La quantité doit être supérieure à zéro.';
  if (quantite > stock + 1e-9) {
    return stock <= 0
        ? 'Stock épuisé : aucune sortie possible.'
        : 'Il ne reste que ${qte(stock)} $unite : la sortie de '
              '${qte(quantite)} $unite est refusée.';
  }
  return null;
}

/// Situation réduite à une rubrique (cantine) ou privée de celle-ci
/// (impayés de scolarité, distincts de ceux de cantine).
SituationEleve filtrerRubrique(
  SituationEleve s,
  String rubrique, {
  required bool garder,
}) => SituationEleve(
  studentId: s.studentId,
  autresRecettes: garder ? 0 : s.autresRecettes,
  lignes: [
    for (final l in s.lignes)
      if ((l.ligne.rubric == rubrique) == garder) l,
  ],
);

/// Lundi de la semaine d'une date ISO (« 2026-11-05 » → « 2026-11-02 »).
String lundi(String jour) {
  final d = DateTime.parse(jour);
  final l = d.subtract(Duration(days: d.weekday - 1));
  return _iso(l);
}

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Jours ouvrés (lundi à vendredi) de la semaine qui commence [lundiIso].
List<String> joursSemaine(String lundiIso) {
  final d = DateTime.parse(lundiIso);
  return [for (var i = 0; i < 5; i++) _iso(d.add(Duration(days: i)))];
}

/// Repas servis par jour (toutes classes), pour un mois « 2026-11 » ou tout.
Map<String, int> repasParJour(
  Iterable<MealServiceRow> pointages, {
  String? mois,
}) {
  final out = <String, int>{};
  for (final p in pointages) {
    if (p.deletedAt != null) continue;
    if (mois != null && !p.day.startsWith(mois)) continue;
    out[p.day] = (out[p.day] ?? 0) + p.mealsCount;
  }
  return Map.fromEntries(
    out.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

int totalRepas(Iterable<MealServiceRow> pointages, {String? mois}) =>
    repasParJour(pointages, mois: mois).values.fold(0, (s, n) => s + n);

/// Dépenses de cantine nettes (annulations déduites) d'un mois.
int depensesCantine(Iterable<ExpenseRow> depenses, {String? mois}) => depenses
    .where(
      (d) =>
          d.category == categorieCantine &&
          (mois == null || d.spentOn.startsWith(mois)),
    )
    .fold(0, (s, d) => s + d.amount);

/// Coût moyen par repas = dépenses de cantine ÷ repas servis (formule
/// affichée). Sans repas servi : pas de coût (jamais de division par zéro).
class CoutMoyen {
  const new(this.depenses, this.repas);
  final int depenses;
  final int repas;
  double? get valeur => repas == 0 ? null : depenses / repas;

  /// Arrondi au franc le plus proche.
  int? get arrondi => valeur?.round();

  String get formule => repas == 0
      ? 'Coût moyen par repas = dépenses de cantine ÷ repas servis : aucun '
            'repas pointé, pas de coût moyen.'
      : 'Coût moyen par repas = dépenses de cantine ÷ repas servis = '
            '${fcfa(depenses)} ÷ ${fcfa(repas)} = ${fcfa(arrondi!)}';
}

/// Entrées, sorties (inventaires et annulations compris) d'un produit sur
/// un mois, et stock à la fin du mois.
class MouvementsMois {
  const new({
    required this.produit,
    required this.entrees,
    required this.sorties,
    required this.ajustements,
    required this.stockFin,
  });
  final StockProductRow produit;
  final double entrees;

  /// Quantité sortie (positive).
  final double sorties;

  /// Inventaires et annulations (signés).
  final double ajustements;
  final double stockFin;
  double get stockDebut =>
      arrondiQte(stockFin - entrees + sorties - ajustements);
}

List<MouvementsMois> mouvementsDuMois(
  List<StockProductRow> produits,
  List<StockMovementRow> mouvements,
  String mois,
) {
  // Fin du mois : tout ce qui date d'avant le mois suivant.
  final fin = '$mois-32';
  return [
    for (final p in produits)
      if (p.deletedAt == null)
        () {
          var e = 0.0;
          var s = 0.0;
          var a = 0.0;
          var total = 0.0;
          for (final m in mouvements) {
            if (m.productId != p.id || m.occurredOn.compareTo(fin) > 0) {
              continue;
            }
            total += m.quantityDelta;
            if (!m.occurredOn.startsWith(mois)) continue;
            switch (m.kind) {
              case 'entree':
                e += m.quantityDelta;
              case 'sortie':
                s -= m.quantityDelta;
              default:
                a += m.quantityDelta;
            }
          }
          return MouvementsMois(
            produit: p,
            entrees: arrondiQte(e),
            sorties: arrondiQte(s),
            ajustements: arrondiQte(a),
            stockFin: arrondiQte(total),
          );
        }(),
  ];
}

/// Bénéficiaires d'une classe (ou de l'école).
class EffectifCantine {
  const new(this.classe, this.beneficiaires, this.effectif);
  final String classe;
  final int beneficiaires;
  final int effectif;
}

/// Bilan mensuel de la cantine.
class BilanCantine {
  const new({
    required this.mois,
    required this.repas,
    required this.joursServis,
    required this.beneficiaires,
    required this.cout,
    required this.cotisations,
    required this.impayes,
    required this.stock,
  });
  final String mois;
  final int repas;
  final int joursServis;
  final int beneficiaires;
  final CoutMoyen cout;

  /// Cotisations de cantine encaissées dans le mois (annulations déduites).
  final int cotisations;

  /// Impayés de cantine à ce jour (échéances passées).
  final int impayes;
  final List<MouvementsMois> stock;

  /// Moyenne de repas par jour de service.
  int get moyenneParJour =>
      joursServis == 0 ? 0 : (repas / joursServis).round();
}

/// Cotisations de cantine encaissées : détail des reçus (A23) sur la
/// rubrique cantine, ou reçus d'une seule rubrique cantine (sans détail).
int cotisationsCantine(
  List<PaymentRow> paiements,
  List<PaymentAllocationRow> details, {
  String? mois,
}) {
  final avecDetail = {for (final a in details) a.paymentId};
  final parId = {for (final p in paiements) p.id: p};
  var total = 0;
  for (final a in details) {
    final p = parId[a.paymentId];
    if (p == null || a.rubric != rubriqueCantine) continue;
    if (mois != null && !p.paidAt.startsWith(mois)) continue;
    total += a.amount;
  }
  for (final p in paiements) {
    if (avecDetail.contains(p.id) || p.rubric != rubriqueCantine) continue;
    if (mois != null && !p.paidAt.startsWith(mois)) continue;
    total += p.amount;
  }
  return total;
}

/// Date « 2026-11-05 » → « jeu. 05/11 ».
String jourCourt(String jour) {
  const j = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];
  final d = DateTime.parse(jour);
  return '${j[d.weekday - 1]} ${jour.substring(8, 10)}/${jour.substring(5, 7)}';
}

// ----------------------------------------------------------------------
// A26 : abonnement mensuel payé d'avance
// ----------------------------------------------------------------------

/// Statut d'un élève pour un mois de cantine.
enum StatutMois {
  /// Payé en entier (ou exonéré) : repas autorisés.
  abonne,

  /// Avance enregistrée, mois pas encore payé en entier : repas non
  /// autorisés.
  partiel,

  /// Aucun abonnement payé : repas non autorisés, aucune dette.
  nonAbonne,
}

String libelleStatutMois(StatutMois s) => switch (s) {
  StatutMois.abonne => 'ABONNÉ',
  StatutMois.partiel => 'PAIEMENT PARTIEL',
  StatutMois.nonAbonne => 'NON ABONNÉ',
};

const _nomsMois = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', //
  'août', 'septembre', 'octobre', 'novembre', 'décembre',
];

/// « 2026-11-01 » ou « 2026-11 » → « novembre 2026 ».
String libelleMoisCantine(String mois, {bool annee = true}) {
  final m = int.tryParse(mois.substring(5, 7)) ?? 1;
  final nom = _nomsMois[(m - 1).clamp(0, 11)];
  return annee ? '$nom ${mois.substring(0, 4)}' : nom;
}

/// Premier jour du mois : « 2026-11-15 » ou « 2026-11 » → « 2026-11-01 ».
String debutMois(String jour) => '${jour.substring(0, 7)}-01';

/// Mois proposés par défaut pour une année « 2025-2026 » : d'octobre à
/// juin (à adapter dans les réglages).
List<String> moisParDefaut(String annee) {
  final debut = int.tryParse(annee.substring(0, 4)) ?? DateTime.now().year;
  return [
    for (final m in [10, 11, 12]) '$debut-${m.toString().padLeft(2, '0')}-01',
    for (final m in [1, 2, 3, 4, 5, 6])
      '${debut + 1}-${m.toString().padLeft(2, '0')}-01',
  ];
}

/// Tarif applicable à un mois : le dernier tarif « à partir de » ce mois
/// ou d'un mois antérieur ; null si aucun tarif n'est encore fixé.
int? tarifDuMois(Iterable<CanteenRateRow> tarifs, String mois) {
  CanteenRateRow? retenu;
  for (final t in tarifs) {
    if (t.deletedAt != null || t.fromMonth.compareTo(mois) > 0) continue;
    if (retenu == null || t.fromMonth.compareTo(retenu.fromMonth) > 0) {
      retenu = t;
    }
  }
  return retenu?.amount;
}

/// Montant dû pour un mois selon la fiche de l'élève (exonération,
/// réduction mensuelle), jamais négatif.
int duPourEleve(int tarif, CanteenBeneficiaryRow? fiche) {
  if (fiche != null && fiche.deletedAt == null && !fiche.contributes) return 0;
  final r = fiche?.deletedAt == null ? (fiche?.monthlyReduction ?? 0) : 0;
  return tarif - r < 0 ? 0 : tarif - r;
}

/// L'élève est-il exonéré (ne paie pas la cantine) ?
bool exonere(CanteenBeneficiaryRow? fiche) =>
    fiche != null && fiche.deletedAt == null && !fiche.contributes;

/// Situation d'un élève pour un mois de fonctionnement.
class MoisEleve {
  const new({
    required this.mois,
    required this.tarif,
    required this.abonnement,
    required this.paye,
  });

  /// « 2026-11-01 ».
  final String mois;

  /// Tarif applicable aujourd'hui pour ce mois (élève non encore abonné).
  final int? tarif;
  final CanteenSubscriptionRow? abonnement;

  /// Encaissé net sur ce mois (annulations déduites).
  final int paye;

  /// Montant du mois : celui figé à l'abonnement, sinon le tarif actuel.
  int get montant => abonnement?.amountDue ?? tarif ?? 0;

  bool get exempt => abonnement?.exempt ?? false;

  /// Abonnement réellement engagé : payé (même en partie) ou exonéré. Un
  /// mois non engagé n'est jamais une dette.
  bool get engage => abonnement != null && (paye > 0 || exempt);

  StatutMois get statut {
    if (abonnement == null) return StatutMois.nonAbonne;
    if (exempt || (paye >= montant && paye > 0)) return StatutMois.abonne;
    return paye > 0 ? StatutMois.partiel : StatutMois.nonAbonne;
  }

  /// Dû retenu dans les totaux (0 si non engagé).
  int get du => engage ? montant : 0;

  /// Encaissé affecté au mois (un trop-perçu n'est pas compté).
  int get encaisse => paye < 0 ? 0 : (paye > du ? du : paye);

  int get reste => du - encaisse;

  /// Payé au-delà du mois (deux téléphones hors ligne, par exemple).
  int get tropPercu => paye > montant && montant >= 0 ? paye - montant : 0;

  /// Encore payable : pas déjà payé en entier, et un montant connu.
  bool get payable =>
      statut != StatutMois.abonne && (abonnement != null || tarif != null);

  /// Ce qu'il reste à verser pour être abonné.
  int get aVerser => payable ? montant - (paye > 0 ? paye : 0) : 0;
}

/// Situation d'un élève pour l'année (un mois par mois de fonctionnement).
class SituationCantine {
  const new(this.studentId, this.mois);
  final String studentId;
  final List<MoisEleve> mois;

  MoisEleve? duMois(String m) => mois.where((x) => x.mois == m).firstOrNull;
  int get moisAbonnes =>
      mois.where((m) => m.statut == StatutMois.abonne).length;
  int get moisNonAbonnes =>
      mois.where((m) => m.statut == StatutMois.nonAbonne).length;
  int get du => mois.fold(0, (s, m) => s + m.du);
  int get encaisse => mois.fold(0, (s, m) => s + m.encaisse);
  int get reste => mois.fold(0, (s, m) => s + m.reste);
}

/// Encaissé net par abonnement (détail des reçus).
Map<String, int> payeParAbonnement(Iterable<PaymentAllocationRow> details) {
  final out = <String, int>{};
  for (final a in details) {
    final s = a.canteenSubscriptionId;
    if (s == null) continue;
    out[s] = (out[s] ?? 0) + a.amount;
  }
  return out;
}

SituationCantine situationCantine({
  required String studentId,
  required List<String> mois,
  required List<CanteenRateRow> tarifs,
  required Iterable<CanteenSubscriptionRow> abonnements,
  required Map<String, int> payes,
  CanteenBeneficiaryRow? fiche,
}) {
  final siens = {
    for (final a in abonnements)
      if (a.studentId == studentId && a.deletedAt == null) a.month: a,
  };
  return SituationCantine(studentId, [
    for (final m in mois)
      () {
        final t = tarifDuMois(tarifs, m);
        final a = siens[m];
        return MoisEleve(
          mois: m,
          tarif: t == null ? null : duPourEleve(t, fiche),
          abonnement: a,
          paye: a == null ? 0 : (payes[a.id] ?? 0),
        );
      }(),
  ]);
}

/// Répartit un montant reçu sur les mois choisis, dans l'ordre des mois :
/// chaque mois reçoit au plus ce qu'il lui reste à verser. Montant plus
/// petit : le dernier mois servi reste en paiement partiel (avance).
List<(MoisEleve, int)> repartir(int recu, List<MoisEleve> choisis) {
  final tries = [...choisis]..sort((a, b) => a.mois.compareTo(b.mois));
  var reste = recu;
  return [
    for (final m in tries)
      () {
        final part = reste < m.aVerser ? reste : m.aVerser;
        reste -= part;
        return (m, part);
      }(),
  ];
}

/// Indicateurs d'un mois (école ou classe).
class TableauBordCantine {
  const new({
    required this.abonnes,
    required this.partiels,
    required this.nonAbonnes,
    required this.attendu,
    required this.encaisse,
  });

  factory depuis(Iterable<MoisEleve> mois) {
    var a = 0;
    var p = 0;
    var n = 0;
    var du = 0;
    var enc = 0;
    for (final m in mois) {
      switch (m.statut) {
        case StatutMois.abonne:
          a++;
        case StatutMois.partiel:
          p++;
        case StatutMois.nonAbonne:
          n++;
      }
      du += m.du;
      enc += m.encaisse;
    }
    return TableauBordCantine(
      abonnes: a,
      partiels: p,
      nonAbonnes: n,
      attendu: du,
      encaisse: enc,
    );
  }

  final int abonnes;
  final int partiels;
  final int nonAbonnes;

  /// Attendu des abonnements engagés seulement (les non-abonnés ne doivent
  /// rien).
  final int attendu;
  final int encaisse;
  int get restant => attendu - encaisse;
  double? get taux => attendu == 0 ? null : encaisse * 100 / attendu;
}
