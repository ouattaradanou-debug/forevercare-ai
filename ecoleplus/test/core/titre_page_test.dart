import 'dart:io';

import 'package:ecoleplus/core/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('nom d’école long : affiché en entier sur deux lignes sur un '
      'téléphone étroit', (tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Vraie police (Roboto, celle d'Android) : la police des tests dessine
    // chaque lettre comme un carré et fausserait la largeur.
    final roboto = FontLoader('Roboto')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('assets/fonts/Roboto-Regular.ttf').readAsBytesSync(),
          ),
        ),
      );
    await roboto.load();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(fontFamily: 'Roboto'),
          home: const EcoleScaffold(
            title: 'École Publique Primaire de Douré',
            showSync: false,
            body: SizedBox(),
          ),
        ),
      ),
    );
    final texte = tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.byKey(const Key('titre-page')),
        matching: find.byType(RichText),
      ),
    );
    expect(texte.didExceedMaxLines, isFalse, reason: 'pas de « … »');
    expect(find.text('École Publique Primaire de Douré'), findsOneWidget);
  });
}
