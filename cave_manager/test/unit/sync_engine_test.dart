import 'package:test/test.dart';
import 'package:cave_manager/core/sync/remote_writer.dart';
import 'package:cave_manager/core/sync/sync_conflict_resolver.dart';
import 'package:cave_manager/core/sync/sync_engine.dart';
import 'package:cave_manager/core/sync/sync_queue_entry.dart';

/// Double de test de [RemoteWriter] : enregistre les appels reçus, sans
/// toucher au réseau. Permet de simuler "retour de connexion" (succès) et
/// "coupure réseau" (échec) sans dépendance à Supabase.
class _RemoteWriterDeTest implements RemoteWriter {
  _RemoteWriterDeTest({this.doitEchouer = false});

  final bool doitEchouer;
  final List<Map<String, dynamic>> appelsRecus = [];

  @override
  Future<void> envoyer({
    required String table,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    if (doitEchouer) {
      throw Exception('Réseau indisponible (simulation coupure)');
    }
    appelsRecus.add({'table': table, 'operation': operation, 'payload': payload});
  }
}

void main() {
  group('SyncEngine — cycle hors ligne puis synchronisation', () {
    test(
        'une écriture créée hors ligne (statut enAttente) est bien envoyée '
        'au serveur et marquée "synchronise" au retour de connexion', () async {
      // Étape 1 : l'utilisateur modifie la configuration de sa cave hors
      // ligne. L'app enfile l'écriture au lieu de la perdre.
      final entree = SyncQueueEntry(
        id: 'sync-1',
        table: 'caves',
        entiteId: 'cave-123',
        operation: OperationSync.modification,
        payload: {'id': 'cave-123', 'nom': 'Cave du Centre', 'telephone': '70000000'},
        creeLe: DateTime(2026, 1, 1, 8, 0),
      );
      expect(entree.statut, StatutSync.enAttente);

      // Étape 2 : retour de connexion -> traitement de la file.
      final remoteWriter = _RemoteWriterDeTest();
      final moteur = SyncEngine(remoteWriter);
      final resultats = await moteur.traiterFile([entree]);

      // Étape 3 : la donnée créée hors ligne a bien atteint le serveur.
      expect(remoteWriter.appelsRecus, hasLength(1));
      expect(remoteWriter.appelsRecus.single['table'], 'caves');
      expect(remoteWriter.appelsRecus.single['payload'], entree.payload);

      expect(resultats.single.statut, StatutSync.synchronise);
      expect(resultats.single.messageErreur, isNull);
    });

    test('une entrée déjà synchronisée n\'est pas renvoyée une seconde fois', () async {
      final entreeDejaEnvoyee = SyncQueueEntry(
        id: 'sync-2',
        table: 'profiles',
        entiteId: 'profil-1',
        operation: OperationSync.modification,
        payload: {'id': 'profil-1'},
        creeLe: DateTime(2026, 1, 1),
        statut: StatutSync.synchronise,
      );

      final remoteWriter = _RemoteWriterDeTest();
      final moteur = SyncEngine(remoteWriter);
      final resultats = await moteur.traiterFile([entreeDejaEnvoyee]);

      expect(resultats, isEmpty);
      expect(remoteWriter.appelsRecus, isEmpty);
    });

    test(
        'une coupure réseau pendant la synchronisation ne fait PAS perdre '
        'la donnée : l\'entrée repasse en erreur et reste en file pour être '
        'retentée (aucune perte de donnée financière ou opérationnelle)', () async {
      final entree = SyncQueueEntry(
        id: 'sync-3',
        table: 'caves',
        entiteId: 'cave-123',
        operation: OperationSync.modification,
        payload: {'id': 'cave-123', 'nom': 'Cave du Centre'},
        creeLe: DateTime(2026, 1, 1),
      );

      final remoteWriterEnPanne = _RemoteWriterDeTest(doitEchouer: true);
      final moteur = SyncEngine(remoteWriterEnPanne);
      final resultats = await moteur.traiterFile([entree]);

      expect(resultats.single.statut, StatutSync.erreur);
      expect(resultats.single.tentatives, 1);
      expect(resultats.single.messageErreur, isNotNull);

      // Nouvelle tentative après reconnexion : cette fois ça passe.
      final remoteWriterRetabli = _RemoteWriterDeTest();
      final moteurRetabli = SyncEngine(remoteWriterRetabli);
      final secondEssai = await moteurRetabli.traiterFile(resultats);

      expect(secondEssai.single.statut, StatutSync.synchronise);
      expect(remoteWriterRetabli.appelsRecus, hasLength(1));
    });
  });

  group('resoudreConflitDerniereEcriture', () {
    test('la modification locale la plus récente gagne', () {
      final resolution = resoudreConflitDerniereEcriture(
        localModifieLe: DateTime(2026, 1, 1, 10, 0),
        distantModifieLe: DateTime(2026, 1, 1, 9, 0),
      );
      expect(resolution.gagnant, GagnantConflit.local);
    });

    test('la modification distante la plus récente gagne', () {
      final resolution = resoudreConflitDerniereEcriture(
        localModifieLe: DateTime(2026, 1, 1, 9, 0),
        distantModifieLe: DateTime(2026, 1, 1, 10, 0),
      );
      expect(resolution.gagnant, GagnantConflit.distant);
    });

    test('horodatages identiques -> aucun gagnant nécessaire', () {
      final instant = DateTime(2026, 1, 1, 9, 0);
      final resolution = resoudreConflitDerniereEcriture(
        localModifieLe: instant,
        distantModifieLe: instant,
      );
      expect(resolution.gagnant, GagnantConflit.identique);
    });
  });
}
