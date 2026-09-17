import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../local/app_database.dart';
import '../models/champ_mesure.dart';
import '../models/type_tenue.dart';

/// Gabarits (types de tenue + champs de mesure) : synchronisation depuis
/// Supabase et lecture locale (hors-ligne d'abord).
class GabaritRepository {
  GabaritRepository(this._client, this._db);

  final SupabaseClient _client;
  final AppDatabase _db;
  static final Uuid _uuid = Uuid();

  /// Récupère les gabarits par défaut (`atelier_id` nul) et ceux propres à
  /// l'atelier, et les met en cache local. Appelé après connexion (voir
  /// `RecuperationCompteService`) quand une connexion internet est
  /// disponible ; les lectures suivantes se font uniquement depuis le
  /// cache local.
  Future<void> synchroniserGabarits(String atelierId) async {
    final List<Map<String, dynamic>> lignesTypes = await _client
        .from('types_tenue')
        .select()
        .or('atelier_id.is.null,atelier_id.eq.$atelierId');

    final List<TypeTenue> types = lignesTypes
        .map(TypeTenue.depuisSupabase)
        .toList();
    for (final TypeTenue t in types) {
      await _db
          .into(_db.typesTenue)
          .insertOnConflictUpdate(t.versCompagnonLocal());
    }

    if (types.isEmpty) return;

    final List<Map<String, dynamic>> lignesChamps = await _client
        .from('champs_mesure')
        .select()
        .inFilter('type_tenue_id', types.map((t) => t.id).toList());

    final List<ChampMesure> champs = lignesChamps
        .map(ChampMesure.depuisSupabase)
        .toList();
    for (final ChampMesure c in champs) {
      await _db
          .into(_db.champsMesure)
          .insertOnConflictUpdate(c.versCompagnonLocal());
    }

    await nettoyerChampsDupliques();
  }

  /// Supprime les doublons de champs (même gabarit, même nom à la casse et
  /// aux espaces près) qui ont pu apparaître localement — ne garde que la
  /// ligne la plus ancienne. Appelé à chaque synchronisation des gabarits,
  /// en complément de la migration Supabase équivalente (voir
  /// supabase/migration_phase6_dedoublonnage_champs.sql) qui nettoie le
  /// côté serveur ; celle-ci ne suffit pas à elle seule car un doublon déjà
  /// présent dans le cache local d'un appareil n'y disparaît pas tout seul.
  Future<void> nettoyerChampsDupliques() async {
    final List<ChampMesureLocal> tous = await _db.select(_db.champsMesure).get();
    final Map<String, List<ChampMesureLocal>> groupes = {};
    for (final ChampMesureLocal c in tous) {
      final String cle = '${c.typeTenueId}|${c.nom.trim().toLowerCase()}';
      (groupes[cle] ??= []).add(c);
    }
    for (final List<ChampMesureLocal> groupe in groupes.values) {
      if (groupe.length <= 1) continue;
      groupe.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      for (final ChampMesureLocal doublon in groupe.skip(1)) {
        await (_db.delete(
          _db.champsMesure,
        )..where((c) => c.id.equals(doublon.id))).go();
      }
    }
  }

  /// Résout le gabarit à utiliser pour un sexe donné : celui propre à
  /// l'atelier s'il existe, sinon le gabarit par défaut (`atelier_id`
  /// nul). Depuis le correctif "plus de choix de type de tenue", il n'en
  /// existe plus qu'un seul par sexe (voir supabase/seed_gabarits.sql) —
  /// appelé automatiquement dès que le sexe du client est renseigné, sans
  /// aucune sélection de la part de l'utilisatrice ou l'utilisateur.
  Future<String?> resoudreTypeTenue({
    required String sexe,
    required String atelierId,
  }) async {
    final query = _db.select(_db.typesTenue)
      ..where(
        (t) =>
            t.sexe.equals(sexe) &
            (t.atelierId.isNull() | t.atelierId.equals(atelierId)),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.atelierId)])
      ..limit(1);
    final TypeTenueLocal? ligne = await query.getSingleOrNull();
    return ligne?.id;
  }

  Stream<List<TypeTenue>> observerTypesTenue({
    required String sexe,
    required String atelierId,
  }) {
    final query = _db.select(_db.typesTenue)
      ..where(
        (t) =>
            t.sexe.equals(sexe) &
            (t.atelierId.isNull() | t.atelierId.equals(atelierId)),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.nom)]);
    return query.watch().map(
      (lignes) => lignes.map(TypeTenue.depuisLigneLocale).toList(),
    );
  }

  Stream<List<ChampMesure>> observerChampsActifs(String typeTenueId) {
    final query = _db.select(_db.champsMesure)
      ..where(
        (c) => c.typeTenueId.equals(typeTenueId) & c.statut.equals('actif'),
      )
      ..orderBy([(c) => OrderingTerm.asc(c.ordre)]);
    return query.watch().map(
      (lignes) => lignes.map(ChampMesure.depuisLigneLocale).toList(),
    );
  }

  /// Tous les champs d'un gabarit, actifs ET masqués (pour l'écran de
  /// gestion des champs — contrairement à [observerChampsActifs], utilisé
  /// par le formulaire de mesures).
  Stream<List<ChampMesure>> observerTousLesChamps(String typeTenueId) {
    final query = _db.select(_db.champsMesure)
      ..where((c) => c.typeTenueId.equals(typeTenueId))
      ..orderBy([(c) => OrderingTerm.asc(c.ordre)]);
    return query.watch().map(
      (lignes) => lignes.map(ChampMesure.depuisLigneLocale).toList(),
    );
  }

  /// S'assure qu'un gabarit propre à l'atelier existe pour ce sexe, et
  /// retourne son identifiant. `types_tenue`/`champs_mesure` par défaut
  /// (`atelier_id` nul) ne peuvent jamais être modifiés directement — les
  /// policies RLS `..._insert_mon_atelier`/`..._update_mon_atelier`
  /// exigent `atelier_id = mon_atelier_id()` (voir schema.sql). Masquer un
  /// champ par défaut ou en ajouter un personnalisé passe donc toujours
  /// par une copie préalable ("clone-on-customize") : au premier appel
  /// pour un sexe donné, le gabarit par défaut et tous ses champs sont
  /// dupliqués avec un nouvel identifiant et `atelier_id` renseigné ; les
  /// appels suivants retrouvent directement cette copie (déjà préférée
  /// par [resoudreTypeTenue], qui trie `atelier_id` non nul en premier).
  Future<String> assurerGabaritPersonnalise({
    required String sexe,
    required String atelierId,
  }) async {
    final TypeTenueLocal? existant =
        await (_db.select(_db.typesTenue)..where(
              (t) => t.sexe.equals(sexe) & t.atelierId.equals(atelierId),
            ))
            .getSingleOrNull();
    if (existant != null) return existant.id;

    final TypeTenueLocal? defaut =
        await (_db.select(_db.typesTenue)..where(
              (t) => t.sexe.equals(sexe) & t.atelierId.isNull(),
            ))
            .getSingleOrNull();
    if (defaut == null) {
      throw StateError('Aucun gabarit par défaut pour le sexe "$sexe".');
    }

    final List<ChampMesureLocal> champsDefaut =
        await (_db.select(_db.champsMesure)
              ..where((c) => c.typeTenueId.equals(defaut.id)))
            .get();

    final DateTime maintenant = DateTime.now();
    final TypeTenue nouveauType = TypeTenue(
      id: _uuid.v4(),
      atelierId: atelierId,
      nom: defaut.nom,
      sexe: sexe,
      createdAt: maintenant,
      updatedAt: maintenant,
    );
    await _db
        .into(_db.typesTenue)
        .insertOnConflictUpdate(nouveauType.versCompagnonLocal());

    final List<ChampMesure> nouveauxChamps = [
      for (final ChampMesureLocal c in champsDefaut)
        ChampMesure(
          id: _uuid.v4(),
          typeTenueId: nouveauType.id,
          nom: c.nom,
          unite: c.unite,
          statut: c.statut,
          ordre: c.ordre,
          createdAt: maintenant,
          updatedAt: maintenant,
        ),
    ];
    for (final ChampMesure c in nouveauxChamps) {
      await _db
          .into(_db.champsMesure)
          .insertOnConflictUpdate(c.versCompagnonLocal());
    }

    try {
      await _client.from('types_tenue').upsert({
        'id': nouveauType.id,
        'atelier_id': nouveauType.atelierId,
        'nom': nouveauType.nom,
        'sexe': nouveauType.sexe,
      });
      await _client.from('champs_mesure').upsert([
        for (final ChampMesure c in nouveauxChamps)
          {
            'id': c.id,
            'type_tenue_id': c.typeTenueId,
            'nom': c.nom,
            'unite': c.unite,
            'statut': c.statut,
            'ordre': c.ordre,
          },
      ]);
    } catch (_) {
      // Best-effort : la copie reste valide et utilisable localement même
      // hors-ligne. Un second appareil de l'atelier ne la verra qu'après
      // une prochaine synchronisation réussie sur celui-ci.
    }

    return nouveauType.id;
  }

  /// Masque ou réactive un champ (jamais de suppression, voir
  /// `champs_mesure.statut` dans schema.sql). Ne doit être appelé que sur
  /// un champ appartenant à un gabarit propre à l'atelier — voir
  /// [assurerGabaritPersonnalise].
  Future<void> definirStatutChamp({
    required String champId,
    required bool actif,
  }) async {
    final String statut = actif ? 'actif' : 'masque';
    final DateTime maintenant = DateTime.now();
    await (_db.update(_db.champsMesure)..where((c) => c.id.equals(champId)))
        .write(
          ChampsMesureCompanion(
            statut: Value(statut),
            updatedAt: Value(maintenant),
          ),
        );
    try {
      await _client
          .from('champs_mesure')
          .update({'statut': statut})
          .eq('id', champId);
    } catch (_) {
      // Best-effort, voir assurerGabaritPersonnalise.
    }
  }

  /// Masque un champ de mesure identifié par son nom, quel que soit le
  /// gabarit auquel il appartient actuellement (par défaut ou déjà propre
  /// à l'atelier) — utilisé par l'appui long sur un champ depuis
  /// SectionMesures. S'assure d'abord qu'un gabarit personnalisé existe
  /// (voir [assurerGabaritPersonnalise]) puisqu'un champ par défaut ne
  /// peut jamais être modifié directement (RLS) : le champ y est déjà
  /// présent (copié) sous le même nom, c'est celui-là qui est masqué.
  Future<void> masquerChampParNom({
    required String sexe,
    required String atelierId,
    required String nom,
  }) async {
    final String typeTenueId = await assurerGabaritPersonnalise(
      sexe: sexe,
      atelierId: atelierId,
    );

    final String nomNormalise = nom.trim().toLowerCase();
    final List<ChampMesureLocal> champs =
        await (_db.select(_db.champsMesure)
              ..where((c) => c.typeTenueId.equals(typeTenueId)))
            .get();
    ChampMesureLocal? champ;
    for (final ChampMesureLocal c in champs) {
      if (c.nom.trim().toLowerCase() == nomNormalise) {
        champ = c;
        break;
      }
    }
    if (champ == null) return;

    await definirStatutChamp(champId: champ.id, actif: false);
  }

  /// Ajoute un champ personnalisé à la fin d'un gabarit (propre à
  /// l'atelier, voir [assurerGabaritPersonnalise]).
  ///
  /// Refuse silencieusement de créer un doublon : si un champ du même nom
  /// (à la casse et aux espaces près) existe déjà pour ce gabarit, il est
  /// simplement réactivé s'il était masqué, sans qu'une seconde ligne ne
  /// soit créée.
  Future<void> ajouterChamp({
    required String typeTenueId,
    required String nom,
    String? unite,
  }) async {
    final List<ChampMesureLocal> existants =
        await (_db.select(_db.champsMesure)
              ..where((c) => c.typeTenueId.equals(typeTenueId)))
            .get();

    final String nomNormalise = nom.trim().toLowerCase();
    for (final ChampMesureLocal c in existants) {
      if (c.nom.trim().toLowerCase() == nomNormalise) {
        if (c.statut == 'masque') {
          await definirStatutChamp(champId: c.id, actif: true);
        }
        return;
      }
    }

    final int ordre = existants.isEmpty
        ? 1
        : existants.map((c) => c.ordre).reduce((a, b) => a > b ? a : b) + 1;

    final DateTime maintenant = DateTime.now();
    final ChampMesure champ = ChampMesure(
      id: _uuid.v4(),
      typeTenueId: typeTenueId,
      nom: nom,
      unite: unite,
      statut: 'actif',
      ordre: ordre,
      createdAt: maintenant,
      updatedAt: maintenant,
    );
    await _db
        .into(_db.champsMesure)
        .insertOnConflictUpdate(champ.versCompagnonLocal());

    try {
      await _client.from('champs_mesure').upsert({
        'id': champ.id,
        'type_tenue_id': champ.typeTenueId,
        'nom': champ.nom,
        'unite': champ.unite,
        'statut': champ.statut,
        'ordre': champ.ordre,
      });
    } catch (_) {
      // Best-effort, voir assurerGabaritPersonnalise.
    }
  }
}
