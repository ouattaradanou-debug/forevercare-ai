import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../data/models/categorie_vente.dart';
import '../../../data/models/commande.dart';
import '../../../data/models/depense.dart';
import '../../../data/models/paiement.dart';
import '../../../data/models/vente.dart';
import '../../../data/sync/ecriture_synchronisee.dart';
import '../../abonnement/data/abonnement_guard.dart';
import '../../ventes/data/ventes_repository.dart';

/// Gestion des commandes et paiements — données financières.
///
/// N'est appelé QUE depuis des écrans déjà réservés au propriétaire
/// (EcranFinancesClient vérifie le rôle avant même de solliciter ce
/// repository) : défense en profondeur avec la RLS Supabase, qui refuse de
/// toute façon toute lecture/écriture de ces tables à un apprenti, quelle
/// que soit sa permission (aucune colonne financière n'existe même dans
/// permissions_apprenti).
///
/// Un client peut avoir PLUSIEURS commandes (une par couture successive) :
/// revenir pour une nouvelle commande ne touche jamais au montant, à
/// l'avance ni à l'historique des paiements des précédentes — chacune
/// garde son propre enregistrement `commandes`, distingué par sa date de
/// création. La plus récente est "la commande en cours" affichée en
/// premier sur la fiche client ; les autres restent consultables comme
/// historique.
class FinancesRepository {
  FinancesRepository({
    required SupabaseClient client,
    required AppDatabase baseLocale,
    required VentesRepository ventesRepository,
  })  : _client = client,
        _baseLocale = baseLocale,
        _ventesRepository = ventesRepository;

  final SupabaseClient _client;
  final AppDatabase _baseLocale;
  final VentesRepository _ventesRepository;
  static const _uuid = Uuid();

  Commande _depuisLigne(CommandeEntry ligne) => Commande(
        id: ligne.id,
        atelierId: ligne.atelierId,
        clientId: ligne.clientId,
        groupeId: ligne.groupeId,
        montantTotal: ligne.montantTotal,
        avance: ligne.avance,
        tenueRetiree: ligne.tenueRetiree,
        createdAt: ligne.createdAt ?? ligne.updatedAt,
        updatedAt: ligne.updatedAt,
      );

  /// Toutes les commandes du client, de la plus récente à la plus
  /// ancienne.
  Future<List<Commande>> commandesDuClient(String clientId) async {
    final lignes = await _baseLocale.commandesDuClient(clientId);
    return lignes.map(_depuisLigne).toList();
  }

  /// Toutes les commandes d'un groupe d'uniformes — un groupe a une seule
  /// commande globale (pas une par membre).
  Future<List<Commande>> commandesDuGroupe(String groupeId) async {
    final lignes = await _baseLocale.commandesDuGroupe(groupeId);
    return lignes.map(_depuisLigne).toList();
  }

  /// Crée une toute nouvelle commande pour ce client OU ce groupe
  /// d'uniformes (exactement l'un des deux), sans jamais toucher aux
  /// commandes précédentes.
  Future<Commande> creerNouvelleCommande({
    required String atelierId,
    String? clientId,
    String? groupeId,
    required double montantTotal,
    required double avance,
  }) async {
    assert(
      (clientId != null) != (groupeId != null),
      'creerNouvelleCommande : fournir clientId OU groupeId, jamais les deux ni aucun.',
    );
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final maintenant = DateTime.now().toUtc();
    final commande = Commande(
      id: _uuid.v4(),
      atelierId: atelierId,
      clientId: clientId,
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
      table: 'commandes',
      recordId: commande.id,
      operation: 'insert',
      payload: commande.versJson(),
    );
    return commande;
  }

  /// Corrige le montant total et l'avance d'une commande déjà existante
  /// (sans en créer une nouvelle) — pour rectifier une erreur de saisie sur
  /// la commande en cours.
  Future<Commande> modifierCommande({
    required String atelierId,
    required Commande commande,
    required double montantTotal,
    required double avance,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final miseAJour = Commande(
      id: commande.id,
      atelierId: commande.atelierId,
      clientId: commande.clientId,
      groupeId: commande.groupeId,
      montantTotal: montantTotal,
      avance: avance,
      tenueRetiree: commande.tenueRetiree,
      createdAt: commande.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );

    await _mettreEnCacheCommande(miseAJour);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'commandes',
      recordId: miseAJour.id,
      operation: 'update',
      payload: miseAJour.versJson(),
    );
    return miseAJour;
  }

  /// Marque (ou démarque) la tenue d'une commande comme retirée.
  Future<void> definirTenueRetiree({
    required String atelierId,
    required Commande commande,
    required bool tenueRetiree,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final miseAJour = Commande(
      id: commande.id,
      atelierId: commande.atelierId,
      clientId: commande.clientId,
      groupeId: commande.groupeId,
      montantTotal: commande.montantTotal,
      avance: commande.avance,
      tenueRetiree: tenueRetiree,
      createdAt: commande.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );

    await _mettreEnCacheCommande(miseAJour);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'commandes',
      recordId: miseAJour.id,
      operation: 'update',
      payload: miseAJour.versJson(),
    );
  }

  /// Somme des paiements reçus pour une commande — utilisé pour afficher le
  /// reste à payer des commandes précédentes (lecture ponctuelle, pas
  /// besoin d'un flux réactif pour un historique figé).
  Future<double> sommePaiements(String commandeId) async {
    final paiements = await observerPaiements(commandeId).first;
    return paiements.fold<double>(0, (total, p) => total + p.montant);
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

  /// Corrige directement le total "Paiement reçu" d'une commande (depuis
  /// "Modifier Montant/Avance/Paiement"), plutôt que d'ajouter un paiement
  /// de plus : remplace tout l'historique détaillé des paiements de cette
  /// commande par une seule ligne correspondant au nouveau total (ou
  /// n'enregistre rien si le nouveau total est nul). Nécessite une
  /// connexion, comme la suppression d'un client : il n'existe pas
  /// d'opération "delete" dans la file d'attente de synchronisation.
  Future<void> definirPaiementTotal({
    required String atelierId,
    required Commande commande,
    required double nouveauTotal,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);

    // Retire d'abord toute tâche encore en file d'attente pour ces
    // paiements (ajout fait hors-ligne, jamais encore envoyé au serveur) :
    // sans ça, la suppression ci-dessous serait "ressuscitée" dès que la
    // file d'attente serait rejouée, le paiement réapparaissant comme si
    // de rien n'était.
    final anciens = await observerPaiements(commande.id).first;
    for (final ancien in anciens) {
      await _baseLocale.retirerTachesPourEnregistrement('paiements', ancien.id);
    }

    await _client.from('paiements').delete().eq('commande_id', commande.id);
    await _baseLocale.supprimerPaiementsDeLaCommande(commande.id);

    if (nouveauTotal > 0) {
      final paiement = Paiement(
        id: _uuid.v4(),
        atelierId: atelierId,
        commandeId: commande.id,
        montant: nouveauTotal,
        datePaiement: DateTime.now().toUtc(),
      );
      await _client.from('paiements').insert(paiement.versJson());
      await _mettreEnCachePaiement(paiement);
    }
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

  /// Paiements, ventes directes et dépenses de tout l'atelier (tous
  /// clients confondus), utilisés pour le récapitulatif global de l'écran
  /// "Suivi des finances" — toute recette ou dépense enregistrée dans
  /// l'application, quel que soit l'écran, doit s'y retrouver.
  Future<({List<Paiement> paiements, List<Vente> ventes, List<Depense> depenses})>
      recapitulatifBrut(String atelierId) async {
    final lignesPaiements = await _baseLocale.tousPaiementsDeLAtelier(atelierId);
    final lignesVentes = await _baseLocale.toutesVentesDeLAtelier(atelierId);
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
      ventes: lignesVentes
          .map(
            (l) => Vente(
              id: l.id,
              atelierId: l.atelierId,
              categorie: CategorieVente.depuisJson(l.categorie),
              designation: l.designation,
              quantite: l.quantite,
              prixUnitaire: l.prixUnitaire,
              montantTotal: l.montantTotal,
              date: l.date,
              createdAt: l.createdAt,
              articleId: l.articleId,
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

  /// Rapatrie TOUS les paiements, ventes et dépenses de l'atelier
  /// (contrairement à [chargerDepuisServeur], limité à un client) —
  /// nécessaire pour que le récapitulatif global reste exact même sans
  /// avoir visité chaque fiche client ou l'écran "Ventes" individuellement.
  Future<void> chargerRecapitulatifDepuisServeur(String atelierId) async {
    try {
      final lignesPaiements =
          await _client.from('paiements').select().eq('atelier_id', atelierId);
      for (final ligne in lignesPaiements) {
        await _mettreEnCachePaiement(Paiement.depuisJson(ligne));
      }

      await _ventesRepository.chargerDepuisServeur(atelierId);

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
  /// finances, déjà réservé au propriétaire. Toutes les commandes du
  /// client (pas seulement la plus récente), pour que l'historique des
  /// commandes précédentes reste consultable hors-ligne.
  Future<void> chargerDepuisServeur(String clientId) async {
    try {
      final lignesCommandes =
          await _client.from('commandes').select().eq('client_id', clientId);
      for (final ligneCommande in lignesCommandes) {
        final commande = Commande.depuisJson(ligneCommande);
        await _mettreEnCacheCommande(commande);

        final lignesPaiements =
            await _client.from('paiements').select().eq('commande_id', commande.id);
        for (final lignePaiement in lignesPaiements) {
          await _mettreEnCachePaiement(Paiement.depuisJson(lignePaiement));
        }
      }
    } catch (_) {
      // Hors-ligne : le cache existant reste utilisable.
    }
  }

  /// Équivalent de [chargerDepuisServeur] pour les commandes d'un groupe
  /// d'uniformes.
  Future<void> chargerDepuisGroupeServeur(String groupeId) async {
    try {
      final lignesCommandes =
          await _client.from('commandes').select().eq('groupe_id', groupeId);
      for (final ligneCommande in lignesCommandes) {
        final commande = Commande.depuisJson(ligneCommande);
        await _mettreEnCacheCommande(commande);

        final lignesPaiements =
            await _client.from('paiements').select().eq('commande_id', commande.id);
        for (final lignePaiement in lignesPaiements) {
          await _mettreEnCachePaiement(Paiement.depuisJson(lignePaiement));
        }
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
      groupeId: commande.groupeId,
      montantTotal: commande.montantTotal,
      avance: commande.avance,
      tenueRetiree: commande.tenueRetiree,
      createdAt: commande.createdAt,
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
