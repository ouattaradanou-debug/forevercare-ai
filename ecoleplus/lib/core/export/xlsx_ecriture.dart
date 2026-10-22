// Le XML est découpé en morceaux sans espace entre eux, volontairement.
// ignore_for_file: missing_whitespace_between_adjacent_strings
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Écrit un classeur Excel (.xlsx) d'une seule feuille, lisible par Excel,
/// LibreOffice et Google Sheets. Textes en « chaînes en ligne », nombres tels
/// quels ; la première ligne (en-tête) est en gras.
Uint8List ecrireXlsx(String feuille, List<List<Object?>> lignes) {
  String col(int i) {
    var n = i + 1;
    var s = '';
    while (n > 0) {
      final r = (n - 1) % 26;
      s = String.fromCharCode(65 + r) + s;
      n = (n - 1) ~/ 26;
    }
    return s;
  }

  final rows = StringBuffer();
  for (final (i, l) in lignes.indexed) {
    rows.write('<row r="${i + 1}">');
    for (final (j, c) in l.indexed) {
      if (c == null) continue;
      final ref = '${col(j)}${i + 1}';
      final style = i == 0 ? ' s="1"' : '';
      if (c is num) {
        // 9.0 → « 9 » ; 7.8 → « 7.8 ».
        final v = c is double && c == c.truncateToDouble() ? c.toInt() : c;
        rows.write('<c r="$ref"$style><v>$v</v></c>');
      } else {
        rows.write(
          '<c r="$ref"$style t="inlineStr"><is><t xml:space="preserve">'
          '${_echapper('$c')}</t></is></c>',
        );
      }
    }
    rows.write('</row>');
  }
  final nomFeuille = _echapper(
    feuille.replaceAll(RegExp(r'[\\/?*\[\]:]'), ' '),
  );
  final a = Archive();
  void fichier(String chemin, String contenu) =>
      a.addFile(ArchiveFile.bytes(chemin, utf8.encode(_xml + contenu)));
  fichier(
    '[Content_Types].xml',
    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/'
        'content-types">'
        '<Default Extension="rels" ContentType="application/'
        'vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/xl/workbook.xml" ContentType="application/'
        'vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
        '<Override PartName="/xl/worksheets/sheet1.xml" '
        'ContentType="application/'
        'vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
        '<Override PartName="/xl/styles.xml" ContentType="application/'
        'vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
        '</Types>',
  );
  fichier(
    '_rels/.rels',
    '<Relationships xmlns="$_pkgRel">'
        '<Relationship Id="rId1" Type="$_docRel/officeDocument" '
        'Target="xl/workbook.xml"/></Relationships>',
  );
  fichier(
    'xl/workbook.xml',
    '<workbook xmlns="$_main" xmlns:r="$_docRel">'
        '<sheets><sheet name="$nomFeuille" sheetId="1" r:id="rId1"/>'
        '</sheets></workbook>',
  );
  fichier(
    'xl/_rels/workbook.xml.rels',
    '<Relationships xmlns="$_pkgRel">'
        '<Relationship Id="rId1" Type="$_docRel/worksheet" '
        'Target="worksheets/sheet1.xml"/>'
        '<Relationship Id="rId2" Type="$_docRel/styles" '
        'Target="styles.xml"/></Relationships>',
  );
  fichier(
    'xl/styles.xml',
    '<styleSheet xmlns="$_main">'
        '<fonts count="2"><font><sz val="11"/><name val="Calibri"/></font>'
        '<font><b/><sz val="11"/><name val="Calibri"/></font></fonts>'
        '<fills count="2"><fill><patternFill patternType="none"/></fill>'
        '<fill><patternFill patternType="gray125"/></fill></fills>'
        '<borders count="1"><border/></borders>'
        '<cellStyleXfs count="1"><xf fontId="0"/></cellStyleXfs>'
        '<cellXfs count="2"><xf fontId="0" xfId="0"/>'
        '<xf fontId="1" xfId="0" applyFont="1"/></cellXfs>'
        '<cellStyles count="1"><cellStyle name="Normal" xfId="0" '
        'builtinId="0"/></cellStyles>'
        '</styleSheet>',
  );
  fichier(
    'xl/worksheets/sheet1.xml',
    '<worksheet xmlns="$_main"><sheetData>$rows</sheetData></worksheet>',
  );
  return Uint8List.fromList(ZipEncoder().encode(a));
}

String _echapper(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

const _xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n';
const _main = 'http://schemas.openxmlformats.org/spreadsheetml/2006/main';
const _pkgRel = 'http://schemas.openxmlformats.org/package/2006/relationships';
const _docRel =
    'http://schemas.openxmlformats.org/officeDocument/2006/relationships';
