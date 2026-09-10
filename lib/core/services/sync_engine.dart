import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/local/app_database.dart';
import '../../data/models/client.dart';
import '../../data/models/commande.dart';
import '../../data/models/depense.dart';
import '../../data/models/mesure.dart';
import '../../data/models/paiement.dart';
import '../../data/models/photo.dart';
import '../../data/models/rendez_vous.dart';
import '../../data/repositories/client_repository.dart';
import '../../data/repositories/finances_repository.dart';

/// Synchronisation robuste entre le cache local (Drift) et Supabase, dans
/// les deux sens :
///
/// - **Pousser** (`pousserModificationsEnAttente`) : ClientRepository et
///   FinancesRepository essaient déjà d'envoyer chaque écriture
///   immédiatement, mais la marquent seulement `synced: true` en cas de
///   succès. Cette méthode retrouve tout ce qui est resté `synced: false`
///   (écrit hors-ligne, ou dont l'envoi a échoué) et retente l'envoi —
///   jusqu'ici ces écritures étaient silencieusement perdues côté serveur
///   si le premier essai échouait.
/// - **Tirer** (`tirerDonneesAtelier`) : jusqu'ici, un second appareil
///   (téléphone d'un apprenti, réinstallation) ne récupérait au départ
///   que l'atelier, l'équipe et les gabarits — jamais les clients, leurs
///   mesures, rendez-vous ou finances déjà créés ailleurs. Cette méthode
///   retélécharge tout cela depuis Supabase vers le cache local.
///
/// Appelée après connexion (voir RecuperationCompteService) et dès que la
/// connectivité revient (voir main.dart).
class SyncEngine {
  SyncEngine(this._supabase, this._db, this._clients, this._finances);

  final SupabaseClient _supabase;
  final AppDatabase _db;
  final ClientRepository _clients;
  final FinancesRepository _finances;

  Future<bool> _estEnLigne() async {
    final List<ConnectivityResult> resultats = await Connectivity()
        .checkConnectivity();
    return !resultats.contains(ConnectivityResult.none);
  }

  Future<void> _tenter(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Cette ligne reste non synchronisée : on retentera au prochain
      // passage (connexion retrouvée, prochaine ouverture de l'app...).
    }
  }

  /// Ordre important : clients avant mesures/rendez-vous/commandes (qui
  /// les référencent), commandes avant paiements.
  Future<void> pousserModificationsEnAttente() async {
    if (!await _estEnLigne()) return;

    final List<ClientLocal> clients =
        await (_db.select(_db.clients)
              ..where((t) => t.synced.equals(false)))
            .get();
    for (final ClientLocal ligne in clients) {
      await _tenter(() => _clients.pousserClient(Client.depuisLigneLocale(ligne)));
    }

    final List<MesureLocal> mesures =
        await (_db.select(_db.mesures)
              ..where((t) => t.synced.equals(false)))
            .get();
    for (final MesureLocal ligne in mesures) {
      await _tenter(() => _clients.pousserMesure(Mesure.depuisLigneLocale(ligne)));
    }

    final List<RendezVousLocal> rendezVous =
        await (_db.select(_db.rendezVousTable)
              ..where((t) => t.synced.equals(false)))
            .get();
    for (final RendezVousLocal ligne in rendezVous) {
      await _tenter(
        () => _clients.pousserRendezVous([RendezVous.depuisLigneLocale(ligne)]),
      );
    }

    final List<PhotoLocal> photos =
        await (_db.select(_db.photos)..where((t) => t.synced.equals(false)))
            .get();
    for (final PhotoLocal ligne in photos) {
      await _tenter(() => _clients.pousserPhoto(Photo.depuisLigneLocale(ligne)));
    }

    final List<CommandeLocal> commandes =
        await (_db.select(_db.commandes)
              ..where((t) => t.synced.equals(false)))
            .get();
    for (final CommandeLocal ligne in commandes) {
      await _tenter(
        () => _finances.pousserCommande(Commande.depuisLigneLocale(ligne)),
      );
    }

    final List<PaiementLocal> paiements =
        await (_db.select(_db.paiements)
              ..where((t) => t.synced.equals(false)))
            .get();
    for (final PaiementLocal ligne in paiements) {
      await _tenter(
        () => _finances.pousserPaiement(Paiement.depuisLigneLocale(ligne)),
      );
    }

    final List<DepenseLocal> depenses =
        await (_db.select(_db.depenses)
              ..where((t) => t.synced.equals(false)))
            .get();
    for (final DepenseLocal ligne in depenses) {
      await _tenter(
        () => _finances.pousserDepense(Depense.depuisLigneLocale(ligne)),
      );
    }
  }

  /// Retélécharge les clients d'un atelier (et leurs mesures, rendez-vous,
  /// commandes, paiements) depuis Supabase vers le cache local. Les
  /// tables autres que `clients` ne portent pas `atelier_id` : la RLS de
  /// Supabase (déjà en place, voir supabase/schema.sql) restreint d'elle
  /// même une simple lecture à l'atelier de l'utilisateur connecté — pour
  /// `commandes`/`paiements`, elle ne renvoie d'ailleurs rien du tout à un
  /// apprenti, sans code spécifique à écrire ici pour ce cas.
  ///
  /// Ne touche jamais localement une ligne encore `synced: false` (une
  /// modification faite hors-ligne pas encore envoyée) pour ne pas
  /// l'écraser par une version distante plus ancienne — d'où l'intérêt
  /// d'appeler [pousserModificationsEnAttente] avant.
  Future<void> tirerDonneesAtelier(String atelierId) async {
    if (!await _estEnLigne()) return;

    try {
      final Set<String> clientsEnAttente = (await (_db.select(
        _db.clients,
      )..where((t) => t.synced.equals(false))).get()).map((l) => l.id).toSet();
      final List<Map<String, dynamic>> clientsDistants = await _supabase
          .from('clients')
          .select()
          .eq('atelier_id', atelierId);
      for (final Map<String, dynamic> json in clientsDistants) {
        final Client client = Client.depuisSupabase(json);
        if (clientsEnAttente.contains(client.id)) continue;
        await _db
            .into(_db.clients)
            .insertOnConflictUpdate(client.versCompagnonLocal());
      }

      final Set<String> mesuresEnAttente = (await (_db.select(
        _db.mesures,
      )..where((t) => t.synced.equals(false))).get()).map((l) => l.id).toSet();
      final List<Map<String, dynamic>> mesuresDistantes = await _supabase
          .from('mesures')
          .select();
      for (final Map<String, dynamic> json in mesuresDistantes) {
        final Mesure mesure = Mesure.depuisSupabase(json);
        if (mesuresEnAttente.contains(mesure.id)) continue;
        await _db
            .into(_db.mesures)
            .insertOnConflictUpdate(mesure.versCompagnonLocal());
      }

      // `Photo.depuisSupabase` met `cheminLocal` à vide (voir ce modèle) :
      // sans fichier local, l'affichage passe par `url` à la place. Mais
      // pour une photo déjà présente sur CET appareil (celui qui l'a
      // prise, par exemple), il ne faut surtout pas écraser son vrai
      // chemin local par cette valeur vide — on le préserve donc ici.
      final List<PhotoLocal> photosLocales = await _db.select(_db.photos).get();
      final Map<String, String> cheminsLocauxExistants = {
        for (final PhotoLocal l in photosLocales) l.id: l.cheminLocal,
      };
      final Set<String> photosEnAttente = photosLocales
          .where((l) => !l.synced)
          .map((l) => l.id)
          .toSet();
      final List<Map<String, dynamic>> photosDistantes = await _supabase
          .from('photos')
          .select();
      for (final Map<String, dynamic> json in photosDistantes) {
        final Photo photo = Photo.depuisSupabase(json);
        if (photosEnAttente.contains(photo.id)) continue;
        final PhotosCompanion compagnon = photo.versCompagnonLocal().copyWith(
          cheminLocal: Value(cheminsLocauxExistants[photo.id] ?? ''),
        );
        await _db.into(_db.photos).insertOnConflictUpdate(compagnon);
      }

      final Set<String> rendezVousEnAttente = (await (_db.select(
        _db.rendezVousTable,
      )..where((t) => t.synced.equals(false))).get()).map((l) => l.id).toSet();
      final List<Map<String, dynamic>> rendezVousDistants = await _supabase
          .from('rendez_vous')
          .select();
      for (final Map<String, dynamic> json in rendezVousDistants) {
        final RendezVous rdv = RendezVous.depuisSupabase(json);
        if (rendezVousEnAttente.contains(rdv.id)) continue;
        await _db
            .into(_db.rendezVousTable)
            .insertOnConflictUpdate(rdv.versCompagnonLocal());
      }

      final Set<String> commandesEnAttente = (await (_db.select(
        _db.commandes,
      )..where((t) => t.synced.equals(false))).get()).map((l) => l.id).toSet();
      final List<Map<String, dynamic>> commandesDistantes = await _supabase
          .from('commandes')
          .select();
      for (final Map<String, dynamic> json in commandesDistantes) {
        final Commande commande = Commande.depuisSupabase(json);
        if (commandesEnAttente.contains(commande.id)) continue;
        await _db
            .into(_db.commandes)
            .insertOnConflictUpdate(commande.versCompagnonLocal());
      }

      final Set<String> paiementsEnAttente = (await (_db.select(
        _db.paiements,
      )..where((t) => t.synced.equals(false))).get()).map((l) => l.id).toSet();
      final List<Map<String, dynamic>> paiementsDistants = await _supabase
          .from('paiements')
          .select();
      for (final Map<String, dynamic> json in paiementsDistants) {
        final Paiement paiement = Paiement.depuisSupabase(json);
        if (paiementsEnAttente.contains(paiement.id)) continue;
        await _db
            .into(_db.paiements)
            .insertOnConflictUpdate(paiement.versCompagnonLocal());
      }

      final Set<String> depensesEnAttente = (await (_db.select(
        _db.depenses,
      )..where((t) => t.synced.equals(false))).get()).map((l) => l.id).toSet();
      final List<Map<String, dynamic>> depensesDistantes = await _supabase
          .from('depenses')
          .select()
          .eq('atelier_id', atelierId);
      for (final Map<String, dynamic> json in depensesDistantes) {
        final Depense depense = Depense.depuisSupabase(json);
        if (depensesEnAttente.contains(depense.id)) continue;
        await _db
            .into(_db.depenses)
            .insertOnConflictUpdate(depense.versCompagnonLocal());
      }
    } catch (_) {
      // Best-effort : l'application continue avec le cache local déjà
      // présent, quel qu'il soit.
    }
  }
}
