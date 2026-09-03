import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/database.dart';
import '../models/client.dart';
import '../models/commande.dart';
import '../models/mesure.dart';
import '../models/paiement.dart';
import '../models/rendez_vous.dart';

/// Rejoue la file d'attente de synchronisation (`SyncQueueEntries`) vers
/// Supabase : c'est le cœur de la couche "Drift ↔ Supabase" de la Phase 3.
///
/// Principe : chaque tâche en attente porte une opération ('insert' ou
/// 'update') et son payload JSON déjà au format des colonnes Supabase (même
/// format que ce que les repositories envoient directement lors d'un envoi
/// immédiat réussi). Pour une 'update', on compare d'abord `updated_at`
/// local et serveur : si le serveur a une version plus récente (modifiée
/// entre-temps par un autre appareil/utilisateur), c'est elle qui l'emporte
/// ("dernière modification gagne") — la tâche locale est abandonnée et le
/// cache local est réaligné sur la version serveur, avec une entrée dans
/// `journal_actions`. Sinon, la mise à jour locale est poussée normalement.
class SyncEngine {
  SyncEngine({required SupabaseClient client, required AppDatabase baseLocale})
      : _client = client,
        _baseLocale = baseLocale;

  final SupabaseClient _client;
  final AppDatabase _baseLocale;

  bool _enCours = false;

  /// Tables dont les mises à jour peuvent entrer en conflit (donc pour
  /// lesquelles on compare les horodatages avant d'écraser le serveur).
  /// Les tables "insert-only" (mesures, paiements) n'ont pas besoin de
  /// cette vérification : chaque ligne n'est jamais modifiée après coup.
  static const _tablesAvecConflitPossible = {'clients', 'rendez_vous', 'commandes'};

  Future<void> traiterFileAttente() async {
    if (_enCours) return; // évite les passes concurrentes (plusieurs triggers rapprochés)
    _enCours = true;
    try {
      final taches = await _baseLocale.tachesEnAttente();
      for (final tache in taches) {
        await _traiterUneTache(tache);
      }
    } finally {
      _enCours = false;
    }
  }

  Future<void> _traiterUneTache(TacheSyncEntry tache) async {
    try {
      final payload = jsonDecode(tache.payloadJson) as Map<String, dynamic>;

      if (tache.operation == 'update' && _tablesAvecConflitPossible.contains(tache.nomTable)) {
        final ligneServeur = await _client
            .from(tache.nomTable)
            .select()
            .eq('id', tache.recordId)
            .maybeSingle();

        if (ligneServeur != null) {
          final updatedAtServeur = DateTime.parse(ligneServeur['updated_at'] as String);
          final updatedAtLocal = DateTime.parse(payload['updated_at'] as String);

          if (updatedAtServeur.isAfter(updatedAtLocal)) {
            await _appliquerLocalement(tache.nomTable, ligneServeur);
            await _journaliser(
              action: 'conflit_resolu_serveur_conserve',
              table: tache.nomTable,
              cibleId: tache.recordId,
              details: {
                'updated_at_local': updatedAtLocal.toIso8601String(),
                'updated_at_serveur': updatedAtServeur.toIso8601String(),
              },
            );
            await _baseLocale.retirerTacheSync(tache.id);
            return;
          }
        }
      }

      if (tache.operation == 'insert') {
        await _client.from(tache.nomTable).insert(payload);
      } else {
        await _client.from(tache.nomTable).update(payload).eq('id', tache.recordId);
      }
      await _baseLocale.retirerTacheSync(tache.id);
    } on PostgrestException catch (e) {
      if (tache.operation == 'insert' && e.code == '23505') {
        // Violation de contrainte d'unicité sur un insert : la ligne existe
        // déjà côté serveur (ex. un envoi précédent avait en fait réussi
        // avant que la tâche ne soit retirée de la file, coupure au
        // mauvais moment). On considère la tâche déjà appliquée plutôt que
        // de la retenter indéfiniment.
        await _baseLocale.retirerTacheSync(tache.id);
      } else {
        await _baseLocale.enregistrerEchecSync(tache.id, e.message);
      }
    } catch (e) {
      await _baseLocale.enregistrerEchecSync(tache.id, e.toString());
    }
  }

  Future<void> _appliquerLocalement(String nomTable, Map<String, dynamic> json) async {
    switch (nomTable) {
      case 'clients':
        final c = Client.depuisJson(json);
        await _baseLocale.enregistrerClient(
          id: c.id,
          atelierId: c.atelierId,
          nom: c.nom,
          prenom: c.prenom,
          telephone: c.telephone,
          sexe: c.sexe,
          updatedAt: c.updatedAt,
        );
        break;
      case 'rendez_vous':
        final r = RendezVous.depuisJson(json);
        await _baseLocale.enregistrerRendezVous(
          id: r.id,
          atelierId: r.atelierId,
          clientId: r.clientId,
          dateHeure: r.dateHeure,
          type: r.type,
          statut: r.statut,
          updatedAt: r.updatedAt,
        );
        break;
      case 'commandes':
        final c = Commande.depuisJson(json);
        await _baseLocale.enregistrerCommande(
          id: c.id,
          atelierId: c.atelierId,
          clientId: c.clientId,
          montantTotal: c.montantTotal,
          avance: c.avance,
          updatedAt: c.updatedAt,
        );
        break;
      case 'mesures':
        final m = Mesure.depuisJson(json);
        await _baseLocale.enregistrerMesure(
          id: m.id,
          atelierId: m.atelierId,
          clientId: m.clientId,
          typeTenueId: m.typeTenueId,
          datePrise: m.datePrise,
          valeursJson: jsonEncode(m.valeurs),
          prisePar: m.prisePar,
          updatedAt: m.updatedAt,
        );
        break;
      case 'paiements':
        final p = Paiement.depuisJson(json);
        await _baseLocale.enregistrerPaiement(
          id: p.id,
          atelierId: p.atelierId,
          commandeId: p.commandeId,
          montant: p.montant,
          datePaiement: p.datePaiement,
        );
        break;
    }
  }

  Future<void> _journaliser({
    required String action,
    required String table,
    required String cibleId,
    Map<String, dynamic>? details,
  }) async {
    final utilisateurId = _client.auth.currentUser?.id;
    if (utilisateurId == null) return;
    try {
      await _client.from('journal_actions').insert({
        'utilisateur_id': utilisateurId,
        'action': action,
        'cible_table': table,
        'cible_id': cibleId,
        'details': details,
      });
    } catch (_) {
      // Le journal est un historique d'audit best-effort : une entrée
      // manquée ne doit jamais empêcher la synchronisation elle-même de se
      // terminer correctement.
    }
  }
}
