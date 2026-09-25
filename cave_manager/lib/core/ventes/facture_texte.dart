import '../cave/infos_cave.dart';
import '../utils/fcfa_formatter.dart';
import '../utils/paiement_calculator.dart';
import 'client.dart';
import 'commande.dart';
import 'commande_ligne.dart';

/// Génère le texte d'une facture (fonction pure, testable sans widget ni
/// réseau — même principe que `calculerResteAPayer`). Utilisé à la fois
/// pour l'affichage à l'écran et pour le message pré-rempli envoyé via
/// WhatsApp (Phase 5).
String genererTexteFacture({
  required InfosCave? cave,
  required Commande commande,
  required List<CommandeLigne> lignes,
  Client? client,
}) {
  final buffer = StringBuffer();
  buffer.writeln(cave?.nom ?? 'Ma Cave');
  if (cave != null) buffer.writeln('Tél : ${cave.telephone}');
  buffer.writeln('---');
  buffer.writeln('Facture du ${_formaterDate(commande.createdAt)}');
  if (client != null) buffer.writeln('Client : ${client.nom}');
  buffer.writeln('---');
  for (final ligne in lignes) {
    final quantite =
        ligne.quantiteCartons > 0 ? ligne.quantiteCartons : ligne.quantiteBouteilles;
    buffer.writeln(
        '${ligne.produitNom} x$quantite : ${formaterFcfa(ligne.sousTotal)}');
  }
  buffer.writeln('---');
  buffer.writeln('Total : ${formaterFcfa(commande.total)}');
  buffer.writeln('Encaissé : ${formaterFcfa(commande.montantEncaisse)}');
  final paiement = calculerResteAPayer(
    totalACharger: commande.total,
    montantEspeces: commande.montantEncaisseEspeces,
    montantMobileMoney: commande.montantEncaisseMobile,
  );
  if (!paiement.estSolde) {
    buffer.writeln('Reste à payer : ${formaterFcfa(paiement.resteAPayer)}');
  }
  buffer.writeln('Statut : ${commande.statut.libelle}');
  buffer.writeln('Merci de votre confiance.');
  return buffer.toString();
}

String _formaterDate(DateTime dateUtc) {
  final d = dateUtc.toLocal();
  String deuxChiffres(int n) => n.toString().padLeft(2, '0');
  return '${deuxChiffres(d.day)}/${deuxChiffres(d.month)}/${d.year}';
}
