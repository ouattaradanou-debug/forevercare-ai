import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Fabrique un petit .xlsx (comme Excel) : textes en « chaînes partagées »,
/// nombres tels quels, cellules vides absentes du fichier.
Uint8List fabriquerXlsx(List<List<Object?>> lignes) {
  final partages = <String>[];
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

  String echapper(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
  final rows = StringBuffer();
  for (final (i, l) in lignes.indexed) {
    if (l.every((c) => c == null)) continue; // ligne vide : absente
    rows.write('<row r="${i + 1}">');
    for (final (j, c) in l.indexed) {
      if (c == null) continue;
      final ref = '${col(j)}${i + 1}';
      if (c is num) {
        rows.write('<c r="$ref"><v>$c</v></c>');
      } else {
        var k = partages.indexOf('$c');
        if (k < 0) {
          partages.add('$c');
          k = partages.length - 1;
        }
        rows.write('<c r="$ref" t="s"><v>$k</v></c>');
      }
    }
    rows.write('</row>');
  }
  final a = Archive()
    ..addFile(
      ArchiveFile.string(
        'xl/workbook.xml',
        '<workbook xmlns:r="$_rel"> <sheets><sheet name="Élèves" '
            'sheetId="1" r:id="rId1"/></sheets></workbook>',
      ),
    )
    ..addFile(
      ArchiveFile.string(
        'xl/_rels/workbook.xml.rels',
        '<Relationships><Relationship Id="rId1" Target="worksheets/feuille.xml"/></Relationships>',
      ),
    )
    ..addFile(
      ArchiveFile.string(
        'xl/sharedStrings.xml',
        '<sst>${partages.map((s) => '<si><t>${echapper(s)}</t></si>').join()}</sst>',
      ),
    )
    ..addFile(
      ArchiveFile.string(
        'xl/worksheets/feuille.xml',
        '<worksheet><sheetData>$rows</sheetData></worksheet>',
      ),
    );
  return Uint8List.fromList(ZipEncoder().encode(a));
}

const _rel =
    'http://schemas.openxmlformats.org/officeDocument/2006/relationships';

Uint8List csvUtf8(String s) => Uint8List.fromList(utf8.encode(s));
