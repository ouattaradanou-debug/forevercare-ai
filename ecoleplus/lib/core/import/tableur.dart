import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

/// Lecture d'un tableur pour l'import : .xlsx (Excel, LibreOffice, Google
/// Sheets) ou .csv. Renvoie les lignes de la PREMIÈRE feuille, chaque cellule
/// en texte (null si vide), colonnes alignées (A, B, C…).
///
/// Lecteur volontairement minimal (pas de formules recalculées, pas de mise
/// en forme) : un .xlsx est une archive zip de fichiers XML.
List<List<String?>> lireTableur(Uint8List octets) {
  final estZip =
      octets.length > 4 && octets[0] == 0x50 && octets[1] == 0x4B; // « PK »
  return estZip ? _lireXlsx(octets) : lireCsv(_texte(octets));
}

class TableurIllisible implements Exception {
  const new(this.message);
  final String message;
  @override
  String toString() => message;
}

String _texte(Uint8List octets) {
  try {
    return utf8.decode(octets);
  } on FormatException {
    // Fichiers CSV enregistrés par Excel en Windows-1252 : on garde les
    // caractères latins (équivalents pour les lettres accentuées usuelles).
    return latin1.decode(octets);
  }
}

List<List<String?>> _lireXlsx(Uint8List octets) {
  final Archive zip;
  try {
    zip = ZipDecoder().decodeBytes(octets);
  } on Object {
    throw const TableurIllisible('Ce fichier n’est pas un tableur lisible.');
  }
  String? fichier(String nom) {
    final f = zip.findFile(nom);
    return f == null ? null : utf8.decode(f.content);
  }

  // Première feuille : workbook.xml + ses relations.
  final classeur = fichier('xl/workbook.xml');
  final relations = fichier('xl/_rels/workbook.xml.rels');
  var cheminFeuille = 'xl/worksheets/sheet1.xml';
  if (classeur != null && relations != null) {
    final premiere = XmlDocument.parse(classeur)
        .findAllElements('sheet')
        .firstOrNull;
    final rid = premiere?.attributes
        .where((a) => a.name.local == 'id')
        .firstOrNull
        ?.value;
    final cible = XmlDocument.parse(relations)
        .findAllElements('Relationship')
        .where((r) => r.getAttribute('Id') == rid)
        .firstOrNull
        ?.getAttribute('Target');
    if (cible != null) {
      cheminFeuille = cible.startsWith('/')
          ? cible.substring(1)
          : 'xl/${cible.replaceFirst(RegExp(r'^\./'), '')}';
    }
  }
  final feuille = fichier(cheminFeuille);
  if (feuille == null) {
    throw const TableurIllisible('Aucune feuille trouvée dans ce fichier.');
  }

  final partages = <String>[
    for (final si in XmlDocument.parse(
      fichier('xl/sharedStrings.xml') ?? '<sst/>',
    ).findAllElements('si'))
      si.findAllElements('t').map((t) => t.innerText).join(),
  ];

  final lignes = <List<String?>>[];
  for (final row in XmlDocument.parse(feuille).findAllElements('row')) {
    final numero = int.tryParse(row.getAttribute('r') ?? '');
    // Lignes absentes du fichier (entièrement vides) : conservées vides pour
    // que les numéros de ligne du rapport correspondent à Excel.
    while (numero != null && lignes.length < numero - 1) {
      lignes.add(const []);
    }
    final cellules = <String?>[];
    for (final c in row.findElements('c')) {
      final ref = c.getAttribute('r');
      final col = ref == null ? cellules.length : _colonne(ref);
      while (cellules.length < col) {
        cellules.add(null);
      }
      final type = c.getAttribute('t');
      final v = c.getElement('v')?.innerText;
      final valeur = switch (type) {
        's' => v == null ? null : partages.elementAtOrNull(int.parse(v)),
        'inlineStr' => c.findAllElements('t').map((t) => t.innerText).join(),
        'b' => v == '1' ? 'VRAI' : 'FAUX',
        _ => v,
      };
      cellules.add(
        valeur == null || valeur.trim().isEmpty ? null : valeur.trim(),
      );
    }
    lignes.add(cellules);
  }
  return lignes;
}

/// « C12 » → 2 (colonnes numérotées à partir de 0).
int _colonne(String ref) {
  var n = 0;
  for (final c in ref.codeUnits) {
    if (c < 65 || c > 90) break;
    n = n * 26 + (c - 64);
  }
  return n - 1;
}

/// CSV avec séparateur « ; » (Excel en français) ou « , », guillemets gérés.
List<List<String?>> lireCsv(String texte) {
  final propre = texte.startsWith('﻿') ? texte.substring(1) : texte;
  final premiere = propre.split('\n').first;
  final sep = ';'.allMatches(premiere).length >= ','.allMatches(premiere).length
      ? ';'
      : ',';
  final lignes = <List<String?>>[];
  var ligne = <String?>[];
  final champ = StringBuffer();
  var guillemets = false;
  void finChamp() {
    final v = champ.toString().trim();
    ligne.add(v.isEmpty ? null : v);
    champ.clear();
  }

  for (var i = 0; i < propre.length; i++) {
    final c = propre[i];
    if (guillemets) {
      if (c == '"') {
        if (i + 1 < propre.length && propre[i + 1] == '"') {
          champ.write('"');
          i++;
        } else {
          guillemets = false;
        }
      } else {
        champ.write(c);
      }
    } else if (c == '"') {
      guillemets = true;
    } else if (c == sep) {
      finChamp();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < propre.length && propre[i + 1] == '\n') i++;
      finChamp();
      lignes.add(ligne);
      ligne = <String?>[];
    } else {
      champ.write(c);
    }
  }
  if (champ.isNotEmpty || ligne.isNotEmpty) {
    finChamp();
    lignes.add(ligne);
  }
  return lignes;
}

/// Date d'une cellule : « 14/03/2017 », « 2017-03-14 » ou numéro de série
/// Excel (jours depuis le 30/12/1899). Renvoie « 2017-03-14 » ou null.
String? dateDeCellule(String? v) {
  if (v == null) return null;
  final t = v.trim();
  final fr = RegExp(r'^(\d{1,2})[/.\-](\d{1,2})[/.\-](\d{2,4})$').firstMatch(t);
  DateTime? d;
  if (fr != null) {
    var annee = int.parse(fr[3]!);
    if (annee < 100) annee += annee > 50 ? 1900 : 2000;
    d = DateTime.utc(annee, int.parse(fr[2]!), int.parse(fr[1]!));
    if (d.day != int.parse(fr[1]!)) return null; // ex. 31/02
  } else if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(t)) {
    d = DateTime.tryParse(t.substring(0, 10));
  } else if (RegExp(r'^\d{4,5}(\.0+)?$').hasMatch(t)) {
    d = DateTime.utc(1899, 12, 30).add(Duration(days: double.parse(t).toInt()));
  }
  if (d == null || d.year < 1900 || d.year > 2100) return null;
  String deux(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${deux(d.month)}-${deux(d.day)}';
}
