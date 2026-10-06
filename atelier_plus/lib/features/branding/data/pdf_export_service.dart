import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/formatters.dart';
import '../../../data/models/atelier.dart';
import '../../../data/models/client.dart';
import '../../../data/models/commande.dart';
import '../../../data/models/paiement.dart';
import 'donnees_export_client.dart';

final _bleuSeda = PdfColor.fromInt(0xFF1B4FA0);
final _orangeSeda = PdfColor.fromInt(0xFFF5821F);

/// Génère les PDF de fiche client et de facture, avec le nom et le logo de
/// l'atelier en en-tête (personnalisation de marque, Phase 4).
class PdfExportService {
  Future<Uint8List> genererFicheClientPdf({
    required Atelier atelier,
    required Client client,
    required List<GroupeMesureExport> groupesMesures,
  }) async {
    final document = pw.Document();
    final logo = await _telechargerImage(atelier.logoUrl);

    document.addPage(
      pw.MultiPage(
        build: (context) => [
          _entete(atelier, logo),
          pw.SizedBox(height: 20),
          _infosClient(client),
          pw.SizedBox(height: 20),
          if (groupesMesures.isEmpty)
            pw.Text('Aucune mesure enregistrée.')
          else
            for (final groupe in groupesMesures) _tableauMesures(groupe),
          pw.SizedBox(height: 24),
          pw.Text(
            'Document généré le ${Formatters.dateHeure(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    return document.save();
  }

  /// Génère la facture d'une commande : informations de l'atelier mises en
  /// avant (bannière de couleur), QR code de vérification et signature
  /// manuscrite du tailleur (dessinée une fois dans Paramètres).
  Future<Uint8List> genererFacturePdf({
    required Atelier atelier,
    required Client client,
    required Commande commande,
    required List<Paiement> paiements,
  }) async {
    final document = pw.Document();
    final logo = await _telechargerImage(atelier.logoUrl);
    final signature = await _telechargerImage(atelier.signatureUrl);

    final sommePaiements = paiements.fold<double>(0, (total, p) => total + p.montant);
    final paiementRecu = commande.avance + sommePaiements;
    final reste = commande.montantTotal - paiementRecu;
    final numero = 'FACT-${commande.id.substring(0, 8).toUpperCase()}';

    final contenuQr = 'FACTURE $numero\n'
        'Atelier : ${atelier.nom}\n'
        'Client : ${client.nomComplet}\n'
        'Téléphone : ${client.telephone}\n'
        'Date : ${Formatters.dateCourte(commande.createdAt)}\n'
        'Montant total : ${Formatters.montant(commande.montantTotal)}\n'
        'Payé : ${Formatters.montant(paiementRecu)}\n'
        'Reste à payer : ${Formatters.montant(reste > 0 ? reste : 0.0)}';

    document.addPage(
      pw.MultiPage(
        build: (context) => [
          _enteteFacture(atelier, logo, numero, commande),
          pw.SizedBox(height: 24),
          _infosClient(client),
          pw.SizedBox(height: 20),
          _tableauMontants(commande, sommePaiements, paiementRecu, reste),
          pw.SizedBox(height: 32),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _blocSignature(signature),
              _blocQrCode(contenuQr),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Document généré le ${Formatters.dateHeure(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _entete(Atelier atelier, pw.MemoryImage? logo) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (logo != null) ...[
          pw.Container(height: 48, width: 48, child: pw.Image(logo)),
          pw.SizedBox(width: 12),
        ],
        pw.Text(
          atelier.nom,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  /// Bannière de couleur SEDA mettant en avant le nom et le logo de
  /// l'atelier, avec le numéro et la date de la facture.
  pw.Widget _enteteFacture(
    Atelier atelier,
    pw.MemoryImage? logo,
    String numero,
    Commande commande,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _bleuSeda,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logo != null) ...[
            pw.Container(height: 56, width: 56, child: pw.Image(logo)),
            pw.SizedBox(width: 14),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  atelier.nom,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Atelier de couture',
                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.white),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'FACTURE',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: _orangeSeda,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(numero, style: const pw.TextStyle(fontSize: 11, color: PdfColors.white)),
              pw.Text(
                Formatters.dateCourte(commande.createdAt),
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _infosClient(Client client) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Fiche client — ${client.nomComplet}',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        if (client.telephone != null) pw.Text('Téléphone : ${client.telephone}'),
        if (client.sexe != null) pw.Text('Sexe : ${client.sexe == 'Femme' ? 'Femme' : 'Homme'}'),
      ],
    );
  }

  /// Tableau des montants de la facture (en-tête colorée SEDA), suivi d'un
  /// bandeau "Reste à payer" mis en évidence pour rester bien visible même
  /// à une lecture rapide du document imprimé.
  pw.Widget _tableauMontants(
    Commande commande,
    double sommePaiements,
    double paiementRecu,
    double reste,
  ) {
    final resteAffiche = reste > 0 ? reste : 0.0;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Table.fromTextArray(
          headers: const ['Désignation', 'Montant'],
          data: [
            ['Montant total', Formatters.montant(commande.montantTotal)],
            ['Avance reçue', Formatters.montant(commande.avance)],
            ['Paiements reçus', Formatters.montant(sommePaiements)],
            ['Total payé', Formatters.montant(paiementRecu)],
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: pw.BoxDecoration(color: _bleuSeda),
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          cellStyle: const pw.TextStyle(fontSize: 11),
          cellAlignments: const {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight},
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: pw.BoxDecoration(
            color: resteAffiche > 0 ? _orangeSeda : PdfColors.green700,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                resteAffiche > 0 ? 'Reste à payer' : 'Facture soldée',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.Text(
                Formatters.montant(resteAffiche),
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bloc de signature du tailleur : l'image enregistrée dans Paramètres si
  /// elle existe, sinon une ligne vide à signer à la main sur l'impression.
  pw.Widget _blocSignature(pw.MemoryImage? signature) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 160,
          height: 70,
          alignment: pw.Alignment.bottomCenter,
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey600)),
          ),
          child: signature != null
              ? pw.Image(signature, fit: pw.BoxFit.contain)
              : null,
        ),
        pw.SizedBox(height: 4),
        pw.Text('Signature du tailleur', style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  /// QR code encodant un résumé de la facture (atelier, client, montants),
  /// pour une vérification rapide du document imprimé.
  pw.Widget _blocQrCode(String contenu) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: contenu,
          width: 90,
          height: 90,
          drawText: false,
        ),
        pw.SizedBox(height: 4),
        pw.Text('Scanner pour vérifier', style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _tableauMesures(GroupeMesureExport groupe) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${groupe.nomTypeTenue} — ${Formatters.dateCourte(groupe.datePrise)}',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Table.fromTextArray(
            headers: const ['Mesure', 'Valeur'],
            data: [
              for (final ligne in groupe.lignes)
                [ligne.nomChamp, '${ligne.valeur} ${ligne.unite}'],
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          ),
        ],
      ),
    );
  }

  Future<pw.MemoryImage?> _telechargerImage(String? url) async {
    if (url == null) return null;
    try {
      final reponse = await http.get(Uri.parse(url));
      if (reponse.statusCode != 200) return null;
      return pw.MemoryImage(reponse.bodyBytes);
    } catch (_) {
      return null;
    }
  }
}
