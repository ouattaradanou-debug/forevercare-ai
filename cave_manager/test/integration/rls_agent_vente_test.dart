// Test d'intégration obligatoire de la Phase 1 (voir PHASE1.md) :
// un Agent de vente authentifié doit être bloqué par la base de données
// elle-même (RLS), pas seulement par l'interface Flutter, s'il tente
// d'interroger directement `stock` ou `clotures` via l'API Supabase.
//
// Nuance Postgres importante (documentée aussi dans PHASE1.md) :
// - En LECTURE (SELECT), une policy RLS qui ne matche pas ne renvoie pas
//   une erreur mais un résultat VIDE (comportement standard de Postgres :
//   RLS filtre les lignes, il ne "refuse" pas la requête). C'est un vrai
//   blocage côté serveur (aucun client, y compris curl/Postman, ne peut
//   contourner cela), mais ce n'est pas littéralement un code d'erreur.
// - En ÉCRITURE (INSERT/UPDATE/DELETE), une policy qui échoue déclenche
//   une vraie erreur Postgres "new row violates row-level security policy"
//   (code 42501), renvoyée telle quelle par PostgREST. C'est le test le
//   plus fidèle à l'exigence du prompt ("reçoit une erreur d'autorisation").
//
// Ce test nécessite un projet Supabase réel avec la migration
// `0001_phase1_fondations.sql` appliquée, ainsi que deux comptes de test
// pré-provisionnés (voir supabase/README.md). Il est automatiquement
// ignoré si les variables d'environnement ne sont pas fournies, pour ne
// pas casser `dart test` en local/CI sans backend configuré :
//
//   dart test test/integration/rls_agent_vente_test.dart \
//     --define=SUPABASE_URL=... \
//     --define=SUPABASE_ANON_KEY=... \
//     --define=AGENT_TEST_EMAIL=... \
//     --define=AGENT_TEST_PASSWORD=... \
//     --define=CAVE_TEST_ID=...
//
// (ou via des variables d'environnement système, selon le runner CI utilisé)

import 'dart:io';

import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

String? _env(String cle) {
  final valeur = Platform.environment[cle];
  return (valeur == null || valeur.isEmpty) ? null : valeur;
}

void main() {
  final url = _env('SUPABASE_URL');
  final anonKey = _env('SUPABASE_ANON_KEY');
  final agentEmail = _env('AGENT_TEST_EMAIL');
  final agentPassword = _env('AGENT_TEST_PASSWORD');
  final caveId = _env('CAVE_TEST_ID');

  final configureComplet =
      url != null && anonKey != null && agentEmail != null && agentPassword != null && caveId != null;

  group('RLS — Agent de vente bloqué sur les tables sensibles', () {
    late SupabaseClient client;

    setUpAll(() async {
      if (!configureComplet) return;
      client = SupabaseClient(url, anonKey);
      await client.auth.signInWithPassword(email: agentEmail, password: agentPassword);
    });

    test(
      'un Agent de vente authentifié ne reçoit AUCUNE ligne de `clotures` '
      '(RLS : aucune policy select ne le concerne)',
      () async {
        final lignes = await client.from('clotures').select();
        expect(lignes, isEmpty);
      },
      skip: configureComplet ? false : 'Backend Supabase de test non configuré (voir en-tête du fichier).',
    );

    test(
      'un Agent de vente authentifié reçoit une ERREUR d\'autorisation '
      '(pas un masquage UI) s\'il tente d\'écrire dans `stock`',
      () async {
        expect(
          () => client.from('stock').insert({
            'cave_id': caveId,
            'produit_id': '00000000-0000-0000-0000-000000000000',
            'quantite_cartons': 5,
          }),
          throwsA(
            isA<PostgrestException>().having((e) => e.code, 'code', '42501'),
          ),
        );
      },
      skip: configureComplet ? false : 'Backend Supabase de test non configuré (voir en-tête du fichier).',
    );

    test(
      'un Agent de vente authentifié reçoit une ERREUR d\'autorisation '
      's\'il tente d\'écrire dans `clotures`',
      () async {
        expect(
          () => client.from('clotures').insert({
            'cave_id': caveId,
            'date_cloture': '2026-01-01',
            'cloture_par': '00000000-0000-0000-0000-000000000000',
          }),
          throwsA(
            isA<PostgrestException>().having((e) => e.code, 'code', '42501'),
          ),
        );
      },
      skip: configureComplet ? false : 'Backend Supabase de test non configuré (voir en-tête du fichier).',
    );
  });
}
