import 'package:ecoleplus/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("l'application démarre sur l'écran d'accueil", (tester) async {
    await tester.pumpWidget(const ProviderScope(child: EcolePlusApp()));
    await tester.pumpAndSettle();

    expect(find.text(appName), findsOneWidget);
    expect(find.text('Bienvenue'), findsOneWidget);
  });
}
