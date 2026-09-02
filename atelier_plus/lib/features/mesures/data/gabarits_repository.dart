import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/local/database.dart';
import '../../../data/models/champ_mesure.dart';
import '../../../data/models/type_tenue.dart';

/// Gestion des gabarits (types de tenue + champs de mesure).
///
/// Contrairement à `ClientsRepository`/`MesuresRepository`, les écritures
/// passent par le serveur EN PREMIER (pas d'écriture locale immédiate) :
/// modifier un gabarit est une action administrative peu fréquente, pas une
/// opération quotidienne (voir la liste "créer client / prendre mesure /
/// noter RDV" du cahier des charges), et sa cohérence doit être garantie
/// par Supabase (contrainte d'unicité, RLS propriétaire uniquement) avant
/// d'être reflétée localement. Cette action nécessite donc une connexion —
/// contrairement à sa LECTURE, qui reste disponible hors-ligne via le cache
/// local pour que l'écran de prise de mesure fonctionne au quotidien.
class GabaritsRepository {
  GabaritsRepository({required SupabaseClient client, required AppDatabase baseLocale})
      : _client = client,
        _baseLocale = baseLocale;

  final SupabaseClient _client;
  final AppDatabase _baseLocale;

  /// Rapatrie les gabarits par défaut et ceux de l'atelier, avec leurs
  /// champs de mesure, dans le cache local. À appeler à la connexion et à
  /// l'ouverture des écrans de gabarits/mesures ; échoue silencieusement
  /// hors-ligne (le cache existant reste utilisable).
  Future<void> chargerDepuisServeur(String atelierId) async {
    try {
      final typesJson = await _client
          .from('types_tenue')
          .select()
          .or('atelier_id.is.null,atelier_id.eq.$atelierId');

      for (final ligne in typesJson) {
        final type = TypeTenue.depuisJson(ligne);
        await _baseLocale.enregistrerTypeTenue(
          id: type.id,
          atelierId: type.atelierId,
          nom: type.nom,
          sexe: type.sexe,
          updatedAt: type.updatedAt,
        );

        final champsJson =
            await _client.from('champs_mesure').select().eq('type_tenue_id', type.id);
        for (final ligneChamp in champsJson) {
          final champ = ChampMesure.depuisJson(ligneChamp);
          await _baseLocale.enregistrerChampMesure(
            id: champ.id,
            typeTenueId: champ.typeTenueId,
            nom: champ.nom,
            unite: champ.unite,
            statut: champ.statut.name,
            ordre: champ.ordre,
            updatedAt: champ.updatedAt,
          );
        }
      }
    } catch (_) {
      // Hors-ligne : le cache existant (chargé lors d'une précédente
      // connexion) reste utilisable pour la prise de mesure.
    }
  }

  Future<TypeTenue> creerTypePersonnalise({
    required String atelierId,
    required String nom,
    required String sexe,
  }) async {
    final ligne = await _client
        .from('types_tenue')
        .insert({'atelier_id': atelierId, 'nom': nom, 'sexe': sexe})
        .select()
        .single();
    final type = TypeTenue.depuisJson(ligne);
    await _baseLocale.enregistrerTypeTenue(
      id: type.id,
      atelierId: type.atelierId,
      nom: type.nom,
      sexe: type.sexe,
      updatedAt: type.updatedAt,
    );
    return type;
  }

  /// Duplique un gabarit (par défaut ou personnalisé) en une nouvelle copie
  /// propre à l'atelier, avec tous ses champs actuellement actifs recopiés
  /// à l'état actif (la copie démarre sans historique de mesures, masquer
  /// un champ de l'original n'a pas de sens à reporter sur la copie).
  Future<TypeTenue> dupliquerGabarit({
    required TypeTenue source,
    required String atelierId,
    String? nouveauNom,
  }) async {
    final nouveauType = await creerTypePersonnalise(
      atelierId: atelierId,
      nom: nouveauNom ?? '${source.nom} (copie)',
      sexe: source.sexe,
    );

    final champsSourceJson = await _client
        .from('champs_mesure')
        .select()
        .eq('type_tenue_id', source.id)
        .order('ordre');

    for (final ligneChamp in champsSourceJson) {
      final champSource = ChampMesure.depuisJson(ligneChamp);
      await ajouterChamp(
        typeTenueId: nouveauType.id,
        nom: champSource.nom,
        unite: champSource.unite,
        ordre: champSource.ordre,
      );
    }

    return nouveauType;
  }

  Future<ChampMesure> ajouterChamp({
    required String typeTenueId,
    required String nom,
    String unite = 'cm',
    int ordre = 0,
  }) async {
    final ligne = await _client
        .from('champs_mesure')
        .insert({'type_tenue_id': typeTenueId, 'nom': nom, 'unite': unite, 'ordre': ordre})
        .select()
        .single();
    final champ = ChampMesure.depuisJson(ligne);
    await _baseLocale.enregistrerChampMesure(
      id: champ.id,
      typeTenueId: champ.typeTenueId,
      nom: champ.nom,
      unite: champ.unite,
      statut: champ.statut.name,
      ordre: champ.ordre,
      updatedAt: champ.updatedAt,
    );
    return champ;
  }

  /// Vérifie si des mesures existantes (en cache local) référencent ce
  /// champ, pour avertir le propriétaire avant masquage — le masquage ne
  /// supprime jamais l'historique (aucune politique DELETE n'existe côté
  /// base sur champs_mesure), mais le champ disparaît des nouvelles prises
  /// de mesure : la vérification informe d'une conséquence réelle, elle ne
  /// bloque rien techniquement.
  ///
  /// Vérification effectuée sur le cache local uniquement (best-effort) :
  /// une mesure prise sur un autre appareil et pas encore synchronisée ici
  /// ne sera détectée qu'après la synchronisation complète (Phase 3).
  Future<bool> champUtiliseParDesMesures(ChampMesure champ) async {
    final mesures = await _baseLocale.mesuresParType(champ.typeTenueId);
    // Recherche textuelle simple de la clé JSON plutôt qu'un décodage
    // complet : suffisant car les identifiants de champ sont des UUID
    // (aucun risque de faux positif par sous-chaîne).
    return mesures.any((m) => m.valeursJson.contains('"${champ.id}"'));
  }

  Future<void> masquerChamp(ChampMesure champ) => _changerStatutChamp(champ.id, StatutChamp.masque);

  Future<void> reactiverChamp(ChampMesure champ) => _changerStatutChamp(champ.id, StatutChamp.actif);

  Future<void> _changerStatutChamp(String champId, StatutChamp statut) async {
    final ligne = await _client
        .from('champs_mesure')
        .update({'statut': statut.name})
        .eq('id', champId)
        .select()
        .single();
    final champ = ChampMesure.depuisJson(ligne);
    await _baseLocale.enregistrerChampMesure(
      id: champ.id,
      typeTenueId: champ.typeTenueId,
      nom: champ.nom,
      unite: champ.unite,
      statut: champ.statut.name,
      ordre: champ.ordre,
      updatedAt: champ.updatedAt,
    );
  }
}
