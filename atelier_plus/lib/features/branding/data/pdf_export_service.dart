import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/formatters.dart';
import '../../../data/models/atelier.dart';
import '../../../data/models/client.dart';
import 'donnees_export_client.dart';

/// Génère le PDF de fiche client, avec le nom et le logo de l'atelier en
/// en-tête (personnalisation de marque, Phase 4).
class PdfExportService {
  Future<Uint8List> genererFicheClientPdf({
    required Atelier atelier,
    required Client client,
    required List<GroupeMesureExport> groupesMesures,
  }) async {
    final document = pw.Document();
    final logo = await _telechargerLogo(atelier.logoUrl);

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

  Future<pw.MemoryImage?> _telechargerLogo(String? logoUrl) async {
    if (logoUrl == null) return null;
    try {
      final reponse = await http.get(Uri.parse(logoUrl));
      if (reponse.statusCode != 200) return null;
      return pw.MemoryImage(reponse.bodyBytes);
    } catch (_) {
      // Logo indisponible (hors-ligne, URL invalide) : le PDF est quand
      // même généré, seulement sans logo.
      return null;
    }
  }
}
