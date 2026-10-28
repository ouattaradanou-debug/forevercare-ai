import 'dart:io';

import 'package:ecoleplus/features/bibliotheque/data/bibliotheque_repository.dart';
import 'package:ecoleplus/features/bibliotheque/domain/document.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/device.dart';
import '../helpers/fake_server.dart';
import 'phase9_bibliotheque_test.dart' show fichiersDeTest;

void main() {
  test('mesure : 200 documents ajoutés d’un coup, catalogués et cherchables '
      'sans Internet, puis tous envoyés', () async {
    final server = FakeServer();
    final tel = TestDevice(server);
    await tel.initSession();
    final tmp = Directory.systemTemp.createTempSync('mesure200');
    final media = Directory('${tmp.path}/media')..createSync();
    final fichiers = fichiersDeTest(
      Directory('${tmp.path}/lot'),
      200,
      taille: 40 * 1024,
    );
    final repo = BibliothequeRepository(
      tel.store,
      remote: tel.remote,
      mediaDir: media,
    );
    tel.online = false;

    final chrono = Stopwatch()..start();
    final r = await repo.ajouter(
      schoolId: 's',
      espace: Espace.bibliotheque,
      fichiers: fichiers,
      fiche: const FicheDocument(commun: true, motsCles: ['géographie']),
      gestionnaire: true,
    );
    final ajout = chrono.elapsedMilliseconds;
    expect(r.ajoutes, 200);

    // Catalogue et recherche par titre / mot-clé, sans Internet.
    chrono.reset();
    final docs = await repo.watchDocuments('s', Espace.bibliotheque).first;
    final q = sansAccents('fiche 137');
    final trouves = docs
        .where((d) => sansAccents(d.texteRecherche).contains(q))
        .toList();
    final parMotCle = docs
        .where((d) => sansAccents(d.texteRecherche).contains('geographie'))
        .length;
    final recherche = chrono.elapsedMilliseconds;
    expect(docs, hasLength(200));
    expect(trouves.map((d) => d.title), ['Fiche 137']);
    expect(parMotCle, 200);

    // Retour du réseau : fiches puis fichiers.
    tel.online = true;
    chrono.reset();
    await tel.engine.syncNow();
    await repo.envoyer();
    await tel.engine.syncNow();
    final envoi = chrono.elapsedMilliseconds;
    expect(await tel.db.select(tel.db.documentUploads).get(), isEmpty);
    expect(
      server.files.keys.where((k) => k.startsWith('documents/')),
      hasLength(200),
    );
    expect(
      server.tables['documents']!.values.where(
        (d) => d['uploaded_at'] != null,
      ),
      hasLength(200),
    );
    // ignore: avoid_print, mesures reprises dans TESTS_PHASE_9.md.
    print(
      'MESURE 200 documents (40 Ko) : ajout $ajout ms ; catalogue + '
      'recherche $recherche ms ; envoi (serveur simulé) $envoi ms',
    );
    await tel.db.close();
    tmp.deleteSync(recursive: true);
  });
}
