import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../local/app_database.dart';
import '../models/commande.dart';
import '../models/paiement.dart';

/// Finances d'un client : montant total convenu, avance versée et
/// historique des paiements (voir supabase/schema.sql, tables
/// `commandes`/`paiements`). Réservé au propriétaire — RLS l'impose déjà
/// côté serveur, et l'interface ne doit jamais exposer ces écrans à un
/// apprenti (voir PermissionsApprenti, dépourvue de toute permission
/// financière par construction).
///
/// Un seul enregistrement `commandes` par client (voir décision produit :
/// "un solde par client" plutôt que plusieurs commandes distinctes dans le
/// temps).
class FinancesRepository {
  FinancesRepository(this._client, this._db);

  final SupabaseClient _client;
  final AppDatabase _db;
  static final Uuid _uuid = Uuid();

  Future<bool> _estEnLigne() async {
    final List<ConnectivityResult> resultats = await Connectivity()
        .checkConnectivity();
    return !resultats.contains(ConnectivityResult.none);
  }

  Future<Commande?> _commandeClient(String clientId) async {
    final CommandeLocal? ligne =
        await (_db.select(_db.commandes)
              ..where((t) => t.clientId.equals(clientId)))
            .getSingleOrNull();
    return ligne == null ? null : Commande.depuisLigneLocale(ligne);
  }

  Stream<Commande?> observerCommandeClient(String clientId) {
    final query = _db.select(_db.commandes)
      ..where((t) => t.clientId.equals(clientId));
    return query.watchSingleOrNull().map(
      (ligne) => ligne == null ? null : Commande.depuisLigneLocale(ligne),
    );
  }

  Stream<List<Paiement>> observerPaiementsCommande(String commandeId) {
    final query = _db.select(_db.paiements)
      ..where((t) => t.commandeId.equals(commandeId))
      ..orderBy([(t) => OrderingTerm.desc(t.datePaiement)]);
    return query.watch().map(
      (lignes) => lignes.map(Paiement.depuisLigneLocale).toList(),
    );
  }

  /// Crée le solde du client s'il n'en a pas encore, ou met à jour son
  /// montant total convenu. Refuse de descendre sous l'avance déjà versée
  /// (la contrainte `avance <= montant_total` existe aussi côté base, mais
  /// on veut un message clair côté application plutôt qu'une erreur SQL).
  Future<void> definirMontantTotal({
    required String clientId,
    required double montantTotal,
  }) async {
    final DateTime maintenant = DateTime.now();
    final Commande? existante = await _commandeClient(clientId);

    if (existante != null && montantTotal < existante.avance) {
      throw Exception(
        'Le montant total ne peut pas être inférieur à ce qui a déjà été '
        'versé (${existante.avance.toStringAsFixed(0)} FCFA).',
      );
    }

    final Commande commande = Commande(
      id: existante?.id ?? _uuid.v4(),
      clientId: clientId,
      montantTotal: montantTotal,
      avance: existante?.avance ?? 0,
      createdAt: existante?.createdAt ?? maintenant,
      updatedAt: maintenant,
    );
    await _db
        .into(_db.commandes)
        .insertOnConflictUpdate(commande.versCompagnonLocal());

    if (await _estEnLigne()) {
      try {
        if (existante == null) {
          await _client.from('commandes').insert({
            'id': commande.id,
            'client_id': commande.clientId,
            'montant_total': commande.montantTotal,
            'avance': commande.avance,
          });
        } else {
          await _client
              .from('commandes')
              .update({'montant_total': commande.montantTotal})
              .eq('id', commande.id);
        }
      } catch (_) {
        // Best-effort : voir ClientRepository pour la même approche —
        // resynchronisé plus tard par le moteur de synchronisation.
      }
    }
  }

  /// Enregistre un paiement et met à jour l'avance de la commande d'un
  /// coup (les deux écritures locales sont atomiques). Refuse un paiement
  /// qui dépasserait le montant total convenu.
  Future<void> ajouterPaiement({
    required String clientId,
    required double montant,
  }) async {
    if (montant <= 0) {
      throw ArgumentError('Le montant doit être supérieur à zéro.');
    }

    final Commande? commande = await _commandeClient(clientId);
    if (commande == null) {
      throw Exception(
        "Défini d'abord le montant total convenu avant d'enregistrer un "
        'paiement.',
      );
    }
    final double nouvelleAvance = commande.avance + montant;
    if (nouvelleAvance > commande.montantTotal) {
      throw Exception(
        'Il ne reste que ${commande.resteAPayer.toStringAsFixed(0)} FCFA à '
        'payer pour ce client.',
      );
    }

    final DateTime maintenant = DateTime.now();
    final Paiement paiement = Paiement(
      id: _uuid.v4(),
      commandeId: commande.id,
      montant: montant,
      datePaiement: maintenant,
      createdAt: maintenant,
    );
    final Commande commandeMiseAJour = Commande(
      id: commande.id,
      clientId: commande.clientId,
      montantTotal: commande.montantTotal,
      avance: nouvelleAvance,
      createdAt: commande.createdAt,
      updatedAt: maintenant,
    );

    await _db.transaction(() async {
      await _db
          .into(_db.paiements)
          .insertOnConflictUpdate(paiement.versCompagnonLocal());
      await _db
          .into(_db.commandes)
          .insertOnConflictUpdate(commandeMiseAJour.versCompagnonLocal());
    });

    if (await _estEnLigne()) {
      try {
        await _client.from('paiements').insert({
          'id': paiement.id,
          'commande_id': paiement.commandeId,
          'montant': paiement.montant,
          'date_paiement': paiement.datePaiement.toIso8601String(),
        });
        await _client
            .from('commandes')
            .update({'avance': commandeMiseAJour.avance})
            .eq('id', commande.id);
      } catch (_) {
        // Best-effort : voir ClientRepository.
      }
    }
  }
}
