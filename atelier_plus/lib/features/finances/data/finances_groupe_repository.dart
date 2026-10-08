import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../data/models/commande_groupe.dart';
import '../../../data/models/paiement.dart';
import '../../../data/sync/ecriture_synchronisee.dart';
import '../../abonnement/data/abonnement_guard.dart';

/// Gestion de la commande et des paiements d'un groupe d'uniformes —
/// équivalent de `FinancesRepository` pour un client, mais sur des tables
/// dédiées (`commandes_groupe`/`paiements_groupe`) : un groupe a une seule
/// commande globale plutôt qu'une par membre, et cette séparation évite
/// toute modification des tables `commandes`/`paiements` déjà utilisées par
/// les clients.
///
/// N'est appelé QUE depuis des écrans déjà réservés au propriétaire, comme
/// FinancesRepository — même garantie RLS côté serveur.
class FinancesGroupeRepository {
  FinancesGroupeRepository({required SupabaseClient client, required AppDatabase baseLocale})
      : _client = client,
        _baseLocale = baseLocale;

  final SupabaseClient _client;
  final AppDatabase _baseLocale;
  static const _uuid = Uuid();

  CommandeGroupe _depuisLigne(CommandeGroupeEntry ligne) => CommandeGroupe(
        id: ligne.id,
        atelierId: ligne.atelierId,
        groupeId: ligne.groupeId,
        montantTotal: ligne.montantTotal,
        avance: ligne.avance,
        createdAt: ligne.createdAt,
        updatedAt: ligne.updatedAt,
      );

  /// Toutes les commandes du groupe, de la plus récente à la plus ancienne
  /// — la première est "la commande en cours".
  Future<List<CommandeGroupe>> commandesDuGroupe(String groupeId) async {
    final lignes = await _baseLocale.commandesDuGroupe(groupeId);
    return lignes.map(_depuisLigne).toList();
  }

  Future<CommandeGroupe> creerNouvelleCommande({
    required String atelierId,
    required String groupeId,
    required double montantTotal,
    required double avance,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final maintenant = DateTime.now().toUtc();
    final commande = CommandeGroupe(
      id: _uuid.v4(),
      atelierId: atelierId,
      groupeId: groupeId,
      montantTotal: montantTotal,
      avance: avance,
      createdAt: maintenant,
      updatedAt: maintenant,
    );

    await _mettreEnCacheCommande(commande);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'commandes_groupe',
      recordId: commande.id,
      operation: 'insert',
      payload: commande.versJson(),
    );
    return commande;
  }

  /// Corrige le montant total et l'avance de la commande en cours (erreur
  /// de saisie), sans en créer une nouvelle.
  Future<CommandeGroupe> modifierCommande({
    required String atelierId,
    required CommandeGroupe commande,
    required double montantTotal,
    required double avance,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final miseAJour = CommandeGroupe(
      id: commande.id,
      atelierId: commande.atelierId,
      groupeId: commande.groupeId,
      montantTotal: montantTotal,
      avance: avance,
      createdAt: commande.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );

    await _mettreEnCacheCommande(miseAJour);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'commandes_groupe',
      recordId: miseAJour.id,
      operation: 'update',
      payload: miseAJour.versJson(),
    );
    return miseAJour;
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
      table: 'paiements_groupe',
      recordId: paiement.id,
      operation: 'insert',
      payload: paiement.versJson(),
    );
    return paiement;
  }

  /// Corrige directement le total "Paiement reçu" d'une commande, plutôt
  /// que d'ajouter un paiement de plus — même principe que
  /// FinancesRepository.definirPaiementTotal.
  Future<void> definirPaiementTotal({
    required String atelierId,
    required CommandeGroupe commande,
    required double nouveauTotal,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);

    final anciens = await observerPaiements(commande.id).first;
    for (final ancien in anciens) {
      await _baseLocale.retirerTachesPourEnregistrement('paiements_groupe', ancien.id);
    }

    await _client.from('paiements_groupe').delete().eq('commande_id', commande.id);
    await _baseLocale.supprimerPaiementsDeLaCommandeGroupe(commande.id);

    if (nouveauTotal > 0) {
      final paiement = Paiement(
        id: _uuid.v4(),
        atelierId: atelierId,
        commandeId: commande.id,
        montant: nouveauTotal,
        datePaiement: DateTime.now().toUtc(),
      );
      await _client.from('paiements_groupe').insert(paiement.versJson());
      await _mettreEnCachePaiement(paiement);
    }
  }

  Stream<List<Paiement>> observerPaiements(String commandeId) {
    return _baseLocale.observerPaiementsDeLaCommandeGroupe(commandeId).map(
          (lignes) => lignes
              .map(
                (ligne) => Paiement(
                  id: ligne.id,
                  atelierId: ligne.atelierId,
                  commandeId: ligne.commandeGroupeId,
                  montant: ligne.montant,
                  datePaiement: ligne.datePaiement,
                ),
              )
              .toList(),
        );
  }

  /// Rapatriement initial best-effort — même principe que
  /// FinancesRepository.chargerDepuisServeur.
  Future<void> chargerDepuisServeur(String groupeId) async {
    try {
      final lignesCommandes =
          await _client.from('commandes_groupe').select().eq('groupe_id', groupeId);
      for (final ligneCommande in lignesCommandes) {
        final commande = CommandeGroupe.depuisJson(ligneCommande);
        await _mettreEnCacheCommande(commande);

        final lignesPaiements =
            await _client.from('paiements_groupe').select().eq('commande_id', commande.id);
        for (final lignePaiement in lignesPaiements) {
          await _mettreEnCachePaiement(Paiement.depuisJson(lignePaiement));
        }
      }
    } catch (_) {
      // Hors-ligne : le cache existant reste utilisable.
    }
  }

  /// Rapatriement best-effort des paiements de TOUS les groupes de
  /// l'atelier (et non d'un seul groupe) — utilisé par
  /// `FinancesRepository.chargerRecapitulatifDepuisServeur` pour que les
  /// paiements de groupe soient comptabilisés dans "Suivi des finances" au
  /// même titre que les paiements clients (voir `recapitulatifBrut`).
  Future<void> chargerTousPaiementsDepuisServeur(String atelierId) async {
    try {
      final lignes =
          await _client.from('paiements_groupe').select().eq('atelier_id', atelierId);
      for (final ligne in lignes) {
        await _mettreEnCachePaiement(Paiement.depuisJson(ligne));
      }
    } catch (_) {
      // Hors-ligne : le cache existant reste utilisable.
    }
  }

  Future<void> _mettreEnCacheCommande(CommandeGroupe commande) {
    return _baseLocale.enregistrerCommandeGroupe(
      id: commande.id,
      atelierId: commande.atelierId,
      groupeId: commande.groupeId,
      montantTotal: commande.montantTotal,
      avance: commande.avance,
      createdAt: commande.createdAt,
      updatedAt: commande.updatedAt,
    );
  }

  Future<void> _mettreEnCachePaiement(Paiement paiement) {
    return _baseLocale.enregistrerPaiementGroupe(
      id: paiement.id,
      atelierId: paiement.atelierId,
      commandeGroupeId: paiement.commandeId,
      montant: paiement.montant,
      datePaiement: paiement.datePaiement,
    );
  }
}
