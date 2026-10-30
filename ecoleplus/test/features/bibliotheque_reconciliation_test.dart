import 'dart:io';

import 'package:ecoleplus/features/bibliotheque/data/bibliotheque_repository.dart';
import 'package:ecoleplus/features/bibliotheque/domain/document.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/device.dart';
import '../helpers/fake_server.dart';
import 'phase9_bibliotheque_test.dart' show fichiersDeTest;

void main() {
  test(
    'un document effacé ou devenu inaccessible disparaît des autres '
    'téléphones à la synchronisation ; un ajout pas encore envoyé reste',
    () async {
      final server = FakeServer();
      final tmp = Directory.systemTemp.createTempSync('reconcilier');
      final dir = TestDevice(server);
      final ens = TestDevice(server);
      await dir.initSession();
      await ens.initSession();
      BibliothequeRepository repo(TestDevice t, String nom) =>
          BibliothequeRepository(
            t.store,
            remote: t.remote,
            mediaDir: Directory('${tmp.path}/$nom')..createSync(),
          );
      final rDir = repo(dir, 'dir');
      final rEns = repo(ens, 'ens');

      final r = await rDir.ajouter(
        schoolId: 's',
        espace: Espace.bibliotheque,
        fichiers: fichiersDeTest(Directory('${tmp.path}/lot'), 3, taille: 2000),
        fiche: const FicheDocument(commun: true),
        gestionnaire: true,
      );
      await dir.engine.syncNow();
      await rDir.envoyer();
      await ens.engine.syncNow();
      expect(await ens.db.select(ens.db.documents).get(), hasLength(3));
      // L'enseignant garde le 2e sur son téléphone.
      final deux = (await ens.db.select(ens.db.documents).get()).firstWhere(
        (d) => d.id == r.ids[1],
      );
      await rEns.epingler(deux, garder: true);

      // 1er effacé définitivement ; 2e plus accessible (corbeille, droits).
      server.tables['documents']![r.ids[0]]!['deleted_at'] =
          '2026-10-30T10:00:00Z';
      server.visible = (t, row) => row['id'] != r.ids[1];
      // Ajout de l'enseignant pas encore envoyé : jamais retiré.
      ens.online = false;
      await rEns.ajouter(
        schoolId: 's',
        espace: Espace.bibliotheque,
        fichiers: fichiersDeTest(Directory('${tmp.path}/lot2'), 1, taille: 900),
        fiche: const FicheDocument(classes: ['c']),
        gestionnaire: false,
      );
      ens.online = true;
      expect(await rEns.reconcilier(), 2);
      final restes = await ens.db.select(ens.db.documents).get();
      expect(restes.map((d) => d.id), contains(r.ids[2]));
      expect(restes.map((d) => d.id), isNot(contains(r.ids[0])));
      expect(restes.map((d) => d.id), isNot(contains(r.ids[1])));
      expect(restes, hasLength(2), reason: 'le 3e et l’ajout non envoyé');
      // Fichier gardé du document devenu inaccessible : retiré aussi.
      expect(
        (await ens.db.select(ens.db.documentFiles).get()).map(
          (f) => f.documentId,
        ),
        isNot(contains(r.ids[1])),
      );
      await dir.db.close();
      await ens.db.close();
      tmp.deleteSync(recursive: true);
    },
  );
}
