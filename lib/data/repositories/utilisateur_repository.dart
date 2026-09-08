import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/telephone_utils.dart';
import '../local/app_database.dart' as local;
import '../models/permissions_apprenti.dart';
import '../models/utilisateur.dart';

/// Accès aux comptes utilisateurs (propriétaire et apprentis) et à leurs
/// permissions.
class UtilisateurRepository {
  UtilisateurRepository(this._client, this._db);

  final SupabaseClient _client;
  final local.AppDatabase _db;

  static const String _table = 'utilisateurs';
  static const String _tablePermissions = 'permissions_apprenti';

  /// Bootstrap du compte propriétaire, appelé juste après la création du
  /// compte Supabase Auth : voir la policy RLS `utilisateurs_insert_soi_meme`
  /// dans supabase/schema.sql (id = auth.uid() obligatoire).
  ///
  /// Comme pour `AtelierRepository.creerAtelier`, on n'enchaîne pas
  /// `.select()` après l'insertion : la ligne créée n'est pas encore visible
  /// à ce moment précis pour la policy RLS de lecture
  /// (`utilisateurs_select_mon_atelier`, via `mon_atelier_id()`), qui
  /// interroge la table `utilisateurs` elle-même — Postgres rejetterait
  /// alors l'insertion avec "new row violates row-level security policy",
  /// la clause RETURNING étant filtrée par cette policy de lecture. On
  /// connaît déjà toutes les valeurs de la ligne, la relecture est donc
  /// inutile.
  Future<Utilisateur> creerUtilisateurProprietaire({
    required String id,
    required String atelierId,
    required String nom,
    required String telephone,
  }) async {
    final String telephoneNormalise = TelephoneUtils.normaliser(telephone);
    final DateTime maintenant = DateTime.now();
    await _client.from(_table).insert({
      'id': id,
      'atelier_id': atelierId,
      'nom': nom,
      'telephone': telephoneNormalise,
      'role': 'proprietaire',
    });

    final Utilisateur utilisateur = Utilisateur(
      id: id,
      atelierId: atelierId,
      nom: nom,
      telephone: telephoneNormalise,
      role: RoleUtilisateur.proprietaire,
      createdAt: maintenant,
      updatedAt: maintenant,
    );
    await enregistrerLocalement(utilisateur);
    return utilisateur;
  }

  Future<Utilisateur> recupererDepuisSupabase(String id) async {
    final Map<String, dynamic> ligne = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .single();
    return Utilisateur.depuisSupabase(ligne);
  }

  Future<List<Utilisateur>> recupererEquipeAtelier(String atelierId) async {
    final List<Map<String, dynamic>> lignes = await _client
        .from(_table)
        .select()
        .eq('atelier_id', atelierId)
        .order('created_at');
    final List<Utilisateur> equipe = lignes
        .map(Utilisateur.depuisSupabase)
        .toList();
    for (final Utilisateur membre in equipe) {
      await enregistrerLocalement(membre);
    }
    return equipe;
  }

  /// Création d'un compte apprenti : passe obligatoirement par une Edge
  /// Function Supabase utilisant la clé service_role (voir
  /// supabase/functions/create-apprentice), un client mobile ne devant
  /// jamais détenir de privilèges permettant de créer un compte
  /// d'authentification pour un tiers.
  Future<void> creerApprenti({
    required String nom,
    required String telephone,
    required String pin,
  }) async {
    await _client.functions.invoke(
      'create-apprentice',
      body: {
        'nom': nom,
        'telephone': TelephoneUtils.normaliser(telephone),
        'pin': pin,
      },
    );
  }

  Future<PermissionsApprenti> recupererPermissions(
    String utilisateurId,
  ) async {
    final Map<String, dynamic> ligne = await _client
        .from(_tablePermissions)
        .select()
        .eq('utilisateur_id', utilisateurId)
        .single();
    final PermissionsApprenti permissions = PermissionsApprenti.depuisSupabase(
      ligne,
    );
    await enregistrerPermissionsLocalement(permissions);
    return permissions;
  }

  Future<void> mettreAJourPermissions(PermissionsApprenti permissions) async {
    await _client
        .from(_tablePermissions)
        .update({
          'creer_client': permissions.creerClient,
          'modifier_client': permissions.modifierClient,
          'prendre_mesures': permissions.prendreMesures,
          'ajouter_photos': permissions.ajouterPhotos,
          'modifier_gabarits': permissions.modifierGabarits,
        })
        .eq('utilisateur_id', permissions.utilisateurId);
    await enregistrerPermissionsLocalement(permissions);
  }

  Future<void> enregistrerLocalement(Utilisateur utilisateur) async {
    await _db
        .into(_db.utilisateurs)
        .insertOnConflictUpdate(utilisateur.versCompagnonLocal());
  }

  Future<void> enregistrerPermissionsLocalement(
    PermissionsApprenti permissions,
  ) async {
    await _db
        .into(_db.permissionsApprenti)
        .insertOnConflictUpdate(permissions.versCompagnonLocal());
  }

  Stream<PermissionsApprenti?> observerPermissionsLocal(String utilisateurId) {
    final query = _db.select(_db.permissionsApprenti)
      ..where((t) => t.utilisateurId.equals(utilisateurId));
    return query.watchSingleOrNull().map(
      (ligne) =>
          ligne == null ? null : PermissionsApprenti.depuisLigneLocale(ligne),
    );
  }

  Stream<Utilisateur?> observerUtilisateurLocal(String id) {
    final query = _db.select(_db.utilisateurs)..where((t) => t.id.equals(id));
    return query.watchSingleOrNull().map(
      (ligne) => ligne == null ? null : Utilisateur.depuisLigneLocale(ligne),
    );
  }

  Stream<List<Utilisateur>> observerEquipeLocale(String atelierId) {
    final query = _db.select(_db.utilisateurs)
      ..where((t) => t.atelierId.equals(atelierId));
    return query.watch().map(
      (lignes) => lignes.map(Utilisateur.depuisLigneLocale).toList(),
    );
  }
}
