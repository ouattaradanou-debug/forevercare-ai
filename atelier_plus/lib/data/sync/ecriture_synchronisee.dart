import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/database.dart';
import 'sync_engine.dart';

/// Tentative d'envoi immédiat vers Supabase ; en cas d'échec (hors-ligne,
/// coupure réseau), dépose la même écriture dans la file d'attente de
/// synchronisation locale pour qu'elle soit rejouée par `SyncEngine` dès
/// qu'une connexion est détectée.
///
/// Utilisé par tous les repositories qui écrivent "en local d'abord" :
/// clients, mesures, rendez-vous, commandes, paiements.
Future<void> ecrireEtSynchroniser({
  required SupabaseClient client,
  required AppDatabase baseLocale,
  required String table,
  required String recordId,
  required String operation,
  required Map<String, dynamic> payload,
}) async {
  try {
    if (operation == 'insert') {
      await client.from(table).insert(payload);
    } else {
      await client.from(table).update(payload).eq('id', recordId);
    }
  } catch (e) {
    // Diagnostic temporaire (voir le terminal `flutter run`) : la cause
    // réelle d'un échec d'envoi immédiat était jusqu'ici invisible, la
    // tâche étant silencieusement mise en file d'attente dans tous les cas.
    debugPrint('ecrireEtSynchroniser: échec immédiat sur $table ($operation) : $e');
    await baseLocale.enfilerSync(
      nomTable: table,
      recordId: recordId,
      operation: operation,
      payloadJson: jsonEncode(payload),
    );
  }
}

/// Exécute [ecrire] (une écriture Supabase directe, sans passage par la
/// file d'attente — typiquement un upload de photo, impossible à mettre en
/// cache hors-ligne) ; si elle échoue précisément parce que le client
/// référencé n'existe pas encore côté serveur (violation de clé étrangère,
/// code Postgres 23503 : le client vient d'être créé "en local d'abord" —
/// voir `ClientsRepository.creerClient` — et sa propre synchronisation est
/// peut-être encore dans la file d'attente, par exemple si le premier essai
/// a échoué à cause d'un réseau mobile lent), on force le rejeu de la file
/// d'attente et on retente, avec un court délai entre chaque essai pour
/// laisser le temps à une connexion encore instable de se stabiliser.
Future<T> avecRejeuSiClientPasEncoreSynchronise<T>({
  required SyncEngine syncEngine,
  required Future<T> Function() ecrire,
  int tentativesMax = 4,
}) async {
  for (var tentative = 1; tentative <= tentativesMax; tentative++) {
    try {
      return await ecrire();
    } on PostgrestException catch (e) {
      if (e.code != '23503' || tentative == tentativesMax) rethrow;
      await syncEngine.traiterFileAttente();
      await Future<void>.delayed(Duration(milliseconds: 800 * tentative));
    }
  }
  // Inatteignable (la dernière itération de la boucle fait toujours
  // return ou rethrow), mais requis par l'analyseur Dart.
  throw StateError('avecRejeuSiClientPasEncoreSynchronise: boucle de tentatives épuisée');
}
