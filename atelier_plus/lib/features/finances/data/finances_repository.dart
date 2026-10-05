import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../data/models/commande.dart';
import '../../../data/models/depense.dart';
import '../../../data/models/paiement.dart';
import '../../../data/sync/ecriture_synchronisee.dart';
import '../../abonnement/data/abonnement_guard.dart';

/// Gestion des commandes et paiements — données financières.
///
/// N'est appelé QUE depuis des écrans déjà réservés au propriétaire
/// (EcranFinancesClient vérifie le rôle avant même de solliciter ce
/// repository) : défense en profondeur avec la RLS Supabase, qui refuse de
/// toute façon toute lecture/écriture de ces tables à un apprenti, quelle
/// que soit sa permission (aucune colonne financière n'existe même dans
/// permissions_apprenti).
///
/// Un seul enregistrement `commandes` par client dans ce modèle simplifié
/// (montant total + avance ajustables), conforme à l'écran "finances par
/// client" décrit au cahier des charges plutôt qu'une liste de commandes
/// distinctes.
class FinancesRepository {
  FinancesRepository({required SupabaseClient client, required AppDatabase baseLocale})
      : _client = client,
        _baseLocale = baseLocale;

  final SupabaseClient _client;
  final AppDatabase _baseLocale;
  static const _uuid = Uuid();

  Future<Commande?> commandeDuClient(String clientId) async {
    final ligne = await _baseLocale.commandeDuClient(clientId);
    if (ligne == null) return null;
    return Commande(
      id: ligne.id,
      atelierId: ligne.atelierId,
      clientId: ligne.clientId,
      montantTotal: ligne.montantTotal,
      avance: ligne.avance,
      tenueRetiree: ligne.tenueRetiree,
      updatedAt: ligne.updatedAt,
    );
  }

  /// Crée la commande du client si elle n'existe pas encore, sinon met à
  /// jour son montant total et son avance.
  Future<Commande> definirCommande({
    required String atelierId,
    required String clientId,
    required double montantTotal,
    required double avance,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final existante = await commandeDuClient(clientId);
    final commande = Commande(
      id: existante?.id ?? _uuid.v4(),
      atelierId: atelierId,
      clientId: clientId,
      montantTotal: montantTotal,
      avance: avance,
      tenueRetiree: existante?.tenueRetiree ?? false,
      updatedAt: DateTime.now().toUtc(),
    );

    await _mettreEnCacheCommande(commande);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'commandes',
      recordId: commande.id,
      operation: existante == null ? 'insert' : 'update',
      payload: commande.versJson(),
    );
    return commande;
  }

  /// Marque (ou démarque) la tenue d'un client comme retirée — ne fait rien
  /// si le client n'a pas encore de commande (rien à marquer).
  Future<void> definirTenueRetiree({
    required String atelierId,
    required String clientId,
    required bool tenueRetiree,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final existante = await commandeDuClient(clientId);
    if (existante == null) return;

    final commande = Commande(
      id: existante.id,
      atelierId: existante.atelierId,
      clientId: existante.clientId,
      montantTotal: existante.montantTotal,
      avance: existante.avance,
      tenueRetiree: tenueRetiree,
      updatedAt: DateTime.now().toUtc(),
    );

    await _mettreEnCacheCommande(commande);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'commandes',
      recordId: commande.id,
      operation: 'update',
      payload: commande.versJson(),
    );
  }

  Future<Paiement> ajouterPaiement({
    required String atelierId,
    required String commandeId,
    required double montant,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final paiement = Paiement(
      id: _uuid.v4(),
      atelierId: atelierId,
      commandeId: commandeId,
      montant: montant,
      datePaiement: DateTime.now().toUtc(),
    );

    await _mettreEnCachePaiement(paiement);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'paiements',
      recordId: paiement.id,
      operation: 'insert',
      payload: paiement.versJson(),
    );
    return paiement;
  }

  Stream<List<Paiement>> observerPaiements(String commandeId) {
    return _baseLocale.observerPaiementsDeLaCommande(commandeId).map(
          (lignes) => lignes
              .map(
                (ligne) => Paiement(
                  id: ligne.id,
                  atelierId: ligne.atelierId,
                  commandeId: ligne.commandeId,
                  montant: ligne.montant,
                  datePaiement: ligne.datePaiement,
                ),
              )
              .toList(),
        );
  }

  Future<Depense> ajouterDepense({
    required String atelierId,
    required double montant,
    String? description,
    required DateTime date,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final depense = Depense(
      id: _uuid.v4(),
      atelierId: atelierId,
      montant: montant,
      description: description,
      date: date,
      createdAt: DateTime.now().toUtc(),
    );

    await _mettreEnCacheDepense(depense);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'depenses',
      recordId: depense.id,
      operation: 'insert',
      payload: depense.versJson(),
    );
    return depense;
  }

  /// Historique des dépenses, du plus récent au plus ancien — pour l'écran
  /// "Historique des dépenses".
  Stream<List<Depense>> observerDepenses(String atelierId) {
    return _baseLocale.observerDepensesDeLAtelier(atelierId).map(
          (lignes) => lignes
              .map(
                (l) => Depense(
                  id: l.id,
                  atelierId: l.atelierId,
                  montant: l.montant,
                  description: l.description,
                  date: l.date,
                  createdAt: l.createdAt,
                ),
              )
              .toList(),
        );
  }

  /// Paiements et dépenses de tout l'atelier (tous clients confondus),
  /// utilisés pour le récapitulatif global de l'écran "Suivi des finances".
  Future<({List<Paiement> paiements, List<Depense> depenses})> recapitulatifBrut(
    String atelierId,
  ) async {
    final lignesPaiements = await _baseLocale.tousPaiementsDeLAtelier(atelierId);
    final lignesDepenses = await _baseLocale.toutesDepensesDeLAtelier(atelierId);
    return (
      paiements: lignesPaiements
          .map(
            (l) => Paiement(
              id: l.id,
              atelierId: l.atelierId,
              commandeId: l.commandeId,
              montant: l.montant,
              datePaiement: l.datePaiement,
            ),
          )
          .toList(),
      depenses: lignesDepenses
          .map(
            (l) => Depense(
              id: l.id,
              atelierId: l.atelierId,
              montant: l.montant,
              description: l.description,
              date: l.date,
              createdAt: l.createdAt,
            ),
          )
          .toList(),
    );
  }

  /// Rapatrie TOUS les paiements et dépenses de l'atelier (contrairement à
  /// [chargerDepuisServeur], limité à un client) — nécessaire pour que le
  /// récapitulatif global reste exact même sans avoir visité chaque fiche
  /// client individuellement.
  Future<void> chargerRecapitulatifDepuisServeur(String atelierId) async {
    try {
      final lignesPaiements =
          await _client.from('paiements').select().eq('atelier_id', atelierId);
      for (final ligne in lignesPaiements) {
        await _mettreEnCachePaiement(Paiement.depuisJson(ligne));
      }

      final lignesDepenses =
          await _client.from('depenses').select().eq('atelier_id', atelierId);
      for (final ligne in lignesDepenses) {
        await _mettreEnCacheDepense(Depense.depuisJson(ligne));
      }
    } catch (_) {
      // Hors-ligne : le cache existant reste utilisable.
    }
  }

  /// Rapatriement initial best-effort — appelé uniquement par l'écran
  /// finances, déjà réservé au propriétaire.
  Future<void> chargerDepuisServeur(String clientId) async {
    try {
      final ligneCommande = await _client
          .from('commandes')
          .select()
          .eq('client_id', clientId)
          .maybeSingle();
      if (ligneCommande == null) return;

      final commande = Commande.depuisJson(ligneCommande);
      await _mettreEnCacheCommande(commande);

      final lignesPaiements =
          await _client.from('paiements').select().eq('commande_id', commande.id);
      for (final lignePaiement in lignesPaiements) {
        await _mettreEnCachePaiement(Paiement.depuisJson(lignePaiement));
      }
    } catch (_) {
      // Hors-ligne : le cache existant reste utilisable.
    }
  }

  Future<void> _mettreEnCacheCommande(Commande commande) {
    return _baseLocale.enregistrerCommande(
      id: commande.id,
      atelierId: commande.atelierId,
      clientId: commande.clientId,
      montantTotal: commande.montantTotal,
      avance: commande.avance,
      tenueRetiree: commande.tenueRetiree,
      updatedAt: commande.updatedAt,
    );
  }

  Future<void> _mettreEnCachePaiement(Paiement paiement) {
    return _baseLocale.enregistrerPaiement(
      id: paiement.id,
      atelierId: paiement.atelierId,
      commandeId: paiement.commandeId,
      montant: paiement.montant,
      datePaiement: paiement.datePaiement,
    );
  }

  Future<void> _mettreEnCacheDepense(Depense depense) {
    return _baseLocale.enregistrerDepense(
      id: depense.id,
      atelierId: depense.atelierId,
      montant: depense.montant,
      description: depense.description,
      date: depense.date,
      createdAt: depense.createdAt,
    );
  }
}
