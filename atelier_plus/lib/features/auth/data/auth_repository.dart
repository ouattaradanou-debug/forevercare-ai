import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/telephone.dart';
import '../../../data/local/database.dart';
import '../../../data/models/atelier.dart';
import '../../../data/models/permissions_apprenti.dart';
import '../../../data/models/role_utilisateur.dart';
import '../../../data/models/utilisateur.dart';
import '../../../data/remote/stockage_repository.dart';
import 'exceptions_auth.dart';

const String bucketLogosAteliers = 'logos-ateliers';
const String bucketSignaturesAteliers = 'signatures-ateliers';

/// Authentification et cycle de vie du compte atelier.
///
/// Écrit systématiquement dans Supabase PUIS met en cache le résultat en
/// local (`AppDatabase`) : au login initial il n'y a pas encore de cache à
/// lire, donc contrairement aux fonctionnalités des phases suivantes
/// (clients, mesures...) l'authentification a besoin d'un accès réseau la
/// toute première fois sur un appareil. Une fois connecté, `sessionHorsLigne()`
/// permet de redémarrer l'application sans réseau.
class AuthRepository {
  AuthRepository({
    required SupabaseClient client,
    required AppDatabase baseLocale,
  })  : _client = client,
        _baseLocale = baseLocale,
        _stockage = StockageRepository(client);

  final SupabaseClient _client;
  final AppDatabase _baseLocale;
  final StockageRepository _stockage;

  /// Crée un nouvel atelier et son compte propriétaire.
  Future<Utilisateur> creerCompteAtelier({
    required String nomAtelier,
    required String nomProprietaire,
    required String telephone,
    required String pin,
    XFile? logo,
  }) async {
    final email = Telephone.emailSynthetique(telephone);

    final AuthResponse reponseAuth;
    try {
      reponseAuth = await _client.auth.signUp(email: email, password: pin);
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered')) {
        throw const TelephoneDejaUtiliseException();
      }
      rethrow;
    }

    final utilisateurId = reponseAuth.user?.id;
    if (utilisateurId == null) {
      throw const CompteIncompletException(null);
    }

    String? logoUrl;
    if (logo != null) {
      logoUrl = await _stockage.televerserImageCompressee(
        fichier: logo,
        bucket: bucketLogosAteliers,
        dossier: utilisateurId,
      );
    }

    final Map<String, dynamic> ligneAtelier;
    try {
      ligneAtelier = await _client
          .from('ateliers')
          .insert({'nom': nomAtelier, 'logo_url': logoUrl})
          .select()
          .single();
    } catch (_) {
      // L'utilisateur Auth existe déjà mais aucun atelier n'a pu être créé :
      // aucune action destructive possible depuis le client (voir
      // supabase/README.md, section "aucune politique DELETE sur
      // ateliers"). L'utilisateur peut réessayer : signUp échouera alors
      // avec "already registered" et il devra utiliser l'écran de
      // connexion, qui détecte et signale ce cas via
      // CompteIncompletException.
      rethrow;
    }

    final atelier = Atelier.depuisJson(ligneAtelier);

    final Map<String, dynamic> ligneUtilisateur;
    try {
      ligneUtilisateur = await _client
          .from('utilisateurs')
          .insert({
            'id': utilisateurId,
            'atelier_id': atelier.id,
            'nom': nomProprietaire,
            'telephone': Telephone.normaliser(telephone),
            'role': RoleUtilisateur.proprietaire.name,
          })
          .select()
          .single();
    } catch (_) {
      throw CompteIncompletException(atelier.id);
    }

    final utilisateur = Utilisateur.depuisJson(ligneUtilisateur);
    await _mettreEnCache(atelier: atelier, utilisateur: utilisateur, permissions: null);
    return utilisateur;
  }

  /// Enregistre (ou remplace) la signature manuscrite du tailleur, dessinée
  /// une fois dans Paramètres puis réutilisée sur chaque facture PDF.
  /// Nécessite une connexion (écriture directe Supabase, hors file de
  /// synchronisation) : une signature est rare à modifier et toujours
  /// dessinée par le propriétaire, déjà en ligne au moment de l'enregistrer.
  Future<String> enregistrerSignatureAtelier({
    required Atelier atelierActuel,
    required Uint8List signaturePng,
  }) async {
    final signatureUrl = await _stockage.televerserBinaire(
      octets: signaturePng,
      bucket: bucketSignaturesAteliers,
      dossier: atelierActuel.id,
      extension: 'png',
      contentType: 'image/png',
    );

    await _client
        .from('ateliers')
        .update({'signature_url': signatureUrl})
        .eq('id', atelierActuel.id);

    await _baseLocale.enregistrerAtelier(
      id: atelierActuel.id,
      nom: atelierActuel.nom,
      logoUrl: atelierActuel.logoUrl,
      signatureUrl: signatureUrl,
      updatedAt: DateTime.now(),
    );

    return signatureUrl;
  }

  /// Remplace le logo de l'atelier (touché depuis l'écran d'accueil).
  /// Nécessite une connexion, comme `enregistrerSignatureAtelier` : action
  /// rare, écrite directement sur Supabase plutôt que via la file de
  /// synchronisation hors-ligne.
  Future<String> modifierLogoAtelier({
    required Atelier atelierActuel,
    required XFile logo,
  }) async {
    final logoUrl = await _stockage.televerserImageCompressee(
      fichier: logo,
      bucket: bucketLogosAteliers,
      dossier: atelierActuel.id,
    );

    await _client.from('ateliers').update({'logo_url': logoUrl}).eq('id', atelierActuel.id);

    await _baseLocale.enregistrerAtelier(
      id: atelierActuel.id,
      nom: atelierActuel.nom,
      logoUrl: logoUrl,
      signatureUrl: atelierActuel.signatureUrl,
      updatedAt: DateTime.now(),
    );

    return logoUrl;
  }

  /// Connexion par téléphone + PIN, sur cet appareil ou un nouvel appareil.
  /// Sur un nouvel appareil, [recupererDonneesApresConnexion] reconstitue
  /// intégralement le profil, l'atelier et les permissions en cache local
  /// (scénario "perte de téléphone").
  Future<Utilisateur> connecter({required String telephone, required String pin}) async {
    final email = Telephone.emailSynthetique(telephone);
    try {
      await _client.auth.signInWithPassword(email: email, password: pin);
    } on AuthException {
      throw const IdentifiantsInvalidesException();
    }
    return recupererDonneesApresConnexion();
  }

  /// Récupère intégralement le profil de l'utilisateur connecté (atelier,
  /// ligne utilisateur, permissions le cas échéant) depuis Supabase et les
  /// met en cache local. Les données métier (clients, mesures, rendez-vous,
  /// finances) sont récupérées par leurs repositories respectifs, ajoutés
  /// en Phase 2/3, qui s'appuient sur ce même appel comme point de départ
  /// d'une synchronisation complète après connexion sur un nouvel appareil.
  Future<Utilisateur> recupererDonneesApresConnexion() async {
    final utilisateurId = _client.auth.currentUser?.id;
    if (utilisateurId == null) {
      throw const IdentifiantsInvalidesException();
    }

    final ligneUtilisateur = await _client
        .from('utilisateurs')
        .select()
        .eq('id', utilisateurId)
        .maybeSingle();

    if (ligneUtilisateur == null) {
      throw CompteIncompletException(null);
    }
    final utilisateur = Utilisateur.depuisJson(ligneUtilisateur);

    final ligneAtelier = await _client
        .from('ateliers')
        .select()
        .eq('id', utilisateur.atelierId)
        .single();
    final atelier = Atelier.depuisJson(ligneAtelier);

    PermissionsApprenti? permissions;
    if (utilisateur.estApprenti) {
      final lignePermissions = await _client
          .from('permissions_apprenti')
          .select()
          .eq('utilisateur_id', utilisateurId)
          .maybeSingle();
      permissions = lignePermissions != null
          ? PermissionsApprenti.depuisJson(lignePermissions)
          : PermissionsApprenti.aucunePermission(utilisateurId);
    }

    await _mettreEnCache(atelier: atelier, utilisateur: utilisateur, permissions: permissions);
    return utilisateur;
  }

  /// Lit l'identité de l'utilisateur connecté **uniquement depuis le cache
  /// local**, sans aucun accès réseau : c'est ce qui permet à l'application
  /// de démarrer hors-ligne au quotidien.
  Future<Utilisateur?> sessionHorsLigne() async {
    final utilisateurId = await _baseLocale.utilisateurConnecteId();
    if (utilisateurId == null) return null;

    final ligne = await _baseLocale.utilisateurParId(utilisateurId);
    if (ligne == null) return null;

    return Utilisateur(
      id: ligne.id,
      atelierId: ligne.atelierId,
      nom: ligne.nom,
      telephone: ligne.telephone,
      role: RoleUtilisateur.depuisTexte(ligne.role),
      updatedAt: ligne.updatedAt,
    );
  }

  Future<void> deconnecter() async {
    await _client.auth.signOut();
    // Un appareil peut être repris par un autre utilisateur de l'atelier
    // (propriétaire <-> apprenti) : le cache financier ne doit jamais
    // survivre à la déconnexion (voir AppDatabase.effacerCacheFinancierSiSynchronise).
    await _baseLocale.effacerCacheFinancierSiSynchronise();
    await _baseLocale.definirUtilisateurConnecte(null);
  }

  Future<void> _mettreEnCache({
    required Atelier atelier,
    required Utilisateur utilisateur,
    required PermissionsApprenti? permissions,
  }) async {
    await _baseLocale.enregistrerAtelier(
      id: atelier.id,
      nom: atelier.nom,
      logoUrl: atelier.logoUrl,
      signatureUrl: atelier.signatureUrl,
      updatedAt: atelier.updatedAt,
    );
    await _baseLocale.enregistrerUtilisateur(
      id: utilisateur.id,
      atelierId: utilisateur.atelierId,
      nom: utilisateur.nom,
      telephone: utilisateur.telephone,
      role: utilisateur.role.name,
      updatedAt: utilisateur.updatedAt,
    );
    if (permissions != null) {
      await _baseLocale.enregistrerPermissions(
        utilisateurId: permissions.utilisateurId,
        creerClient: permissions.creerClient,
        modifierClient: permissions.modifierClient,
        prendreMesures: permissions.prendreMesures,
        ajouterPhotos: permissions.ajouterPhotos,
        modifierGabarits: permissions.modifierGabarits,
      );
    }
    await _baseLocale.definirUtilisateurConnecte(utilisateur.id);
  }
}
