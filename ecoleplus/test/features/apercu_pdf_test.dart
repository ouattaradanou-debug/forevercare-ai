import 'dart:convert';
import 'dart:typed_data';

import 'package:ecoleplus/features/forms/presentation/apercu_pdf_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Image PNG de 1 × 1 point (une « page »).
final Uint8List page = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYA'
  'AjCB0C8AAAAASUVORK5CYII=',
);

void main() {
  testWidgets('aperçu : les pages s’affichent et s’agrandissent (boutons + '
      'et −, jusqu’à 5 fois)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          rendrePagesProvider.overrideWithValue((_) async => [page, page]),
        ],
        child: MaterialApp(
          home: ApercuPdfPage(ApercuPdf(Uint8List(0), 'essai.pdf')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsNWidgets(2));
    expect(find.text('Imprimer'), findsOneWidget);
    expect(find.text('Partager'), findsOneWidget);

    double echelle() => tester
        .widget<InteractiveViewer>(find.byKey(const Key('apercu-zoom')))
        .transformationController!
        .value
        .getMaxScaleOnAxis();
    expect(echelle(), 1);
    await tester.tap(find.byKey(const Key('apercu-plus')));
    await tester.pump();
    expect(echelle(), 1.5);
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.byKey(const Key('apercu-plus')));
      await tester.pump();
    }
    expect(echelle(), 5, reason: 'pas plus de 5 fois');
    await tester.tap(find.byKey(const Key('apercu-moins')));
    await tester.pump();
    expect(echelle(), closeTo(5 / 1.5, 0.001));
  });
}
