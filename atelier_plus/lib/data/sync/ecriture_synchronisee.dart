import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/database.dart';

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
  } catch (_) {
    await baseLocale.enfilerSync(
      nomTable: table,
      recordId: recordId,
      operation: operation,
      payloadJson: jsonEncode(payload),
    );
  }
}
