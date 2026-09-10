import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../local/app_database.dart';
import '../models/commande.dart';
import '../models/depense.dart';
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
///
/// Comme ClientRepository, chaque écriture locale part avec `synced:
/// false` et n'est marquée `true` qu'après confirmation de Supabase —
/// SyncEngine retente le reste plus tard.
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

  /// Toutes les commandes de l'atelier (tous clients confondus) — pour
  /// savoir, sur l'accueil, quels clients ont une commande soldée (voir
  /// Commande.estSoldee) et ne plus les afficher parmi les rendez-vous à
  /// suivre.
  Stream<List<Commande>> observerCommandesAtelier(String atelierId) {
    final query = _db.select(_db.commandes).join([
      innerJoin(
        _db.clients,
        _db.clients.id.equalsExp(_db.commandes.clientId),
      ),
    ])..where(_db.clients.atelierId.equals(atelierId));
    return query.watch().map(
      (lignes) => lignes
          .map(
            (ligne) =>
                Commande.depuisLigneLocale(ligne.readTable(_db.commandes)),
          )
          .toList(),
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

  /// Tous les paiements reçus par l'atelier (tous clients confondus) —
  /// pour le suivi des recettes journalières/hebdomadaires/mensuelles/
  /// annuelles (voir SuiviFinancesPage). Passe par une double jointure
  /// (paiements -> commandes -> clients), `paiements` ne connaissant pas
  /// directement l'atelier.
  Stream<List<Paiement>> observerPaiementsAtelier(String atelierId) {
    final query = _db.select(_db.paiements).join([
      innerJoin(
        _db.commandes,
        _db.commandes.id.equalsExp(_db.paiements.commandeId),
      ),
      innerJoin(
        _db.clients,
        _db.clients.id.equalsExp(_db.commandes.clientId),
      ),
    ])..where(_db.clients.atelierId.equals(atelierId));
    return query.watch().map(
      (lignes) => lignes
          .map(
            (ligne) =>
                Paiement.depuisLigneLocale(ligne.readTable(_db.paiements)),
          )
          .toList(),
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
      tenueRetiree: existante?.tenueRetiree ?? false,
      createdAt: existante?.createdAt ?? maintenant,
      updatedAt: maintenant,
      synced: false,
    );
    await _db
        .into(_db.commandes)
        .insertOnConflictUpdate(commande.versCompagnonLocal());

    if (await _estEnLigne()) {
      try {
        await pousserCommande(commande);
      } catch (_) {
        // Best-effort : voir ClientRepository — resynchronisé plus tard
        // par SyncEngine.
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
      synced: false,
    );
    final Commande commandeMiseAJour = Commande(
      id: commande.id,
      clientId: commande.clientId,
      montantTotal: commande.montantTotal,
      avance: nouvelleAvance,
      tenueRetiree: commande.tenueRetiree,
      createdAt: commande.createdAt,
      updatedAt: maintenant,
      synced: false,
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
        await pousserPaiement(paiement);
        await pousserCommande(commandeMiseAJour);
      } catch (_) {
        // Best-effort : voir ClientRepository.
      }
    }
  }

  /// Marque (ou démarque) la tenue d'un client comme retirée. Sans effet
  /// si le client n'a pas encore de commande (rien à marquer).
  Future<void> definirTenueRetiree({
    required String clientId,
    required bool retiree,
  }) async {
    final Commande? commande = await _commandeClient(clientId);
    if (commande == null) return;

    final Commande commandeMiseAJour = Commande(
      id: commande.id,
      clientId: commande.clientId,
      montantTotal: commande.montantTotal,
      avance: commande.avance,
      tenueRetiree: retiree,
      createdAt: commande.createdAt,
      updatedAt: DateTime.now(),
      synced: false,
    );
    await _db
        .into(_db.commandes)
        .insertOnConflictUpdate(commandeMiseAJour.versCompagnonLocal());

    if (await _estEnLigne()) {
      try {
        await pousserCommande(commandeMiseAJour);
      } catch (_) {
        // Best-effort : voir ClientRepository.
      }
    }
  }

  /// Envoie (ou met à jour) une commande sur Supabase, puis marque la
  /// ligne locale comme synchronisée. `upsert` gère aussi bien la
  /// création que la modification en un seul appel.
  Future<void> pousserCommande(Commande commande) async {
    await _client.from('commandes').upsert({
      'id': commande.id,
      'client_id': commande.clientId,
      'montant_total': commande.montantTotal,
      'avance': commande.avance,
      'tenue_retiree': commande.tenueRetiree,
    });
    await (_db.update(_db.commandes)..where((t) => t.id.equals(commande.id)))
        .write(const CommandesCompanion(synced: Value(true)));
  }

  Future<void> pousserPaiement(Paiement paiement) async {
    await _client.from('paiements').upsert({
      'id': paiement.id,
      'commande_id': paiement.commandeId,
      'montant': paiement.montant,
      'date_paiement': paiement.datePaiement.toIso8601String(),
    });
    await (_db.update(
      _db.paiements,
    )..where((t) => t.id.equals(paiement.id))).write(
      const PaiementsCompanion(synced: Value(true)),
    );
  }

  /// Toutes les dépenses de l'atelier — pour l'écran "Suivi des dépenses"
  /// (dépenses journalières/hebdomadaires/mensuelles/annuelles).
  Stream<List<Depense>> observerDepensesAtelier(String atelierId) {
    final query = _db.select(_db.depenses)
      ..where((t) => t.atelierId.equals(atelierId))
      ..orderBy([(t) => OrderingTerm.desc(t.dateDepense)]);
    return query.watch().map(
      (lignes) => lignes.map(Depense.depuisLigneLocale).toList(),
    );
  }

  /// Enregistre une nouvelle dépense de l'atelier.
  Future<void> ajouterDepense({
    required String atelierId,
    required double montant,
    String? description,
    DateTime? date,
  }) async {
    if (montant <= 0) {
      throw ArgumentError('Le montant doit être supérieur à zéro.');
    }

    final DateTime maintenant = DateTime.now();
    final Depense depense = Depense(
      id: _uuid.v4(),
      atelierId: atelierId,
      montant: montant,
      description: description,
      dateDepense: date ?? maintenant,
      createdAt: maintenant,
      synced: false,
    );
    await _db
        .into(_db.depenses)
        .insertOnConflictUpdate(depense.versCompagnonLocal());

    if (await _estEnLigne()) {
      try {
        await pousserDepense(depense);
      } catch (_) {
        // Best-effort : voir ClientRepository.
      }
    }
  }

  Future<void> pousserDepense(Depense depense) async {
    await _client.from('depenses').upsert({
      'id': depense.id,
      'atelier_id': depense.atelierId,
      'montant': depense.montant,
      'description': depense.description,
      'date_depense': depense.dateDepense.toIso8601String(),
    });
    await (_db.update(
      _db.depenses,
    )..where((t) => t.id.equals(depense.id))).write(
      const DepensesCompanion(synced: Value(true)),
    );
  }
}
