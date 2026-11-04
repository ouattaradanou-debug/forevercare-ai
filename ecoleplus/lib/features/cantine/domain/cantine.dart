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

/// La famille de l'élève paie-t-elle la cantine ?
bool participe(String mode, CanteenBeneficiaryRow? b) {
  if (b == null || b.deletedAt != null || !b.isBeneficiary) return false;
  return switch (mode) {
    'avec_participation' => true,
    'mixte' => b.contributes,
    _ => false,
  };
}

/// Lignes de la grille d'un élève : la cotisation de cantine ne s'applique
/// qu'aux bénéficiaires qui participent, et seulement si le module est actif.
List<FeeItemRow> avecCantine(
  List<FeeItemRow> lignes, {
  required bool actif,
  required bool participeAuxFrais,
}) => [
  for (final l in lignes)
    if (l.rubric != rubriqueCantine || (actif && participeAuxFrais)) l,
];

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
