import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../data/models/photo_client.dart';
import '../../../data/remote/stockage_repository.dart';
import '../../../data/sync/ecriture_synchronisee.dart';
import '../../../data/sync/sync_engine.dart';
import '../../abonnement/data/abonnement_guard.dart';

const String bucketPhotosClients = 'photos-clients';
const String bucketAudiosClients = 'audios-clients';

/// Photos de tissus/modèles associées à un client. Contrairement aux
/// gabarits, l'ajout d'une photo fait partie de l'usage courant (comme les
/// clients et les mesures) : écriture locale d'abord, avec tentative
/// d'upload immédiate en meilleur effort.
class PhotosRepository {
  PhotosRepository({
    required SupabaseClient client,
    required AppDatabase baseLocale,
    required SyncEngine syncEngine,
  })  : _client = client,
        _baseLocale = baseLocale,
        _syncEngine = syncEngine,
        _stockage = StockageRepository(client);

  final SupabaseClient _client;
  final AppDatabase _baseLocale;
  final SyncEngine _syncEngine;
  final StockageRepository _stockage;
  static const _uuid = Uuid();

  /// Nécessite une connexion pour l'upload lui-même (une photo ne peut pas
  /// être stockée durablement sans être envoyée à Supabase Storage — il n'y
  /// a pas de cache local de fichiers binaires en Phase 2). Si hors-ligne,
  /// l'erreur remonte à l'écran, qui invite à réessayer une fois reconnecté.
  ///
  /// Exactement l'un de [clientId] (photo d'un client) ou [groupeId] +
  /// [sexe] (photo d'un groupe d'uniformes, séparée hommes/femmes) doit être
  /// fourni.
  Future<PhotoClient> ajouterPhoto({
    required String atelierId,
    String? clientId,
    String? groupeId,
    String? sexe,
    required TypePhoto type,
    required SourcePhoto source,
    required XFile fichier,
  }) async {
    assert(
      (clientId != null) != (groupeId != null),
      'ajouterPhoto : fournir clientId OU groupeId, jamais les deux ni aucun.',
    );
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final url = await _stockage.televerserImageCompressee(
      fichier: fichier,
      bucket: bucketPhotosClients,
      dossier: clientId ?? groupeId!,
    );

    final photo = PhotoClient(
      id: _uuid.v4(),
      atelierId: atelierId,
      clientId: clientId,
      groupeId: groupeId,
      sexe: sexe,
      type: type,
      url: url,
      source: source,
      createdAt: DateTime.now().toUtc(),
    );

    // Le client (ou le groupe) vient peut-être d'être créé "en local
    // d'abord" quelques instants plus tôt (voir ClientsRepository.
    // creerClient / GroupesUniformesRepository.creerGroupe) : si sa propre
    // écriture vers Supabase a échoué et a été mise en file d'attente (ex.
    // réseau instable à ce moment précis), l'insertion directe ci-dessous
    // échouerait avec "violates foreign key constraint" puisque la photo
    // référence un client/groupe absent côté serveur. On force alors le
    // rejeu de la file d'attente puis on retente une seule fois.
    await avecRejeuSiClientPasEncoreSynchronise(
      syncEngine: _syncEngine,
      ecrire: () => _client.from('photos').insert(photo.versJson()),
    );
    await _mettreEnCache(photo);
    return photo;
  }

  /// Enregistre (ou remplace) la note vocale de description d'une photo déjà
  /// envoyée. [cheminFichierAudio] est le fichier local produit par le
  /// package `record` (voir EcranNouveauClient).
  Future<String> ajouterAudioAPhoto({
    required PhotoClient photo,
    required String cheminFichierAudio,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, photo.atelierId);
    final url = await _stockage.televerserAudio(
      cheminFichier: cheminFichierAudio,
      bucket: bucketAudiosClients,
      dossier: photo.clientId ?? photo.groupeId!,
    );

    await _client.from('photos').update({'audio_url': url}).eq('id', photo.id);
    await _baseLocale.mettreAJourAudioPhoto(photo.id, url);
    return url;
  }

  /// Retire la note vocale d'une photo (le fichier audio lui-même reste
  /// dans le stockage — même choix que pour les photos/champs, jamais
  /// supprimés physiquement, seulement détachés).
  Future<void> supprimerAudioDePhoto(PhotoClient photo) async {
    await verifierEcritureAutorisee(_baseLocale, photo.atelierId);
    await _client.from('photos').update({'audio_url': null}).eq('id', photo.id);
    await _baseLocale.mettreAJourAudioPhoto(photo.id, null);
  }

  /// Supprime définitivement une photo (fichier dans Supabase Storage,
  /// note vocale associée si elle existe, ligne `photos`) — pour retirer
  /// une photo ajoutée par erreur ou qui n'est plus utile. Nécessite une
  /// connexion, comme la suppression d'un client : il n'existe pas
  /// d'opération "delete" dans la file d'attente de synchronisation.
  Future<void> supprimerPhoto(PhotoClient photo) async {
    await verifierEcritureAutorisee(_baseLocale, photo.atelierId);

    // Retire d'abord toute tâche encore en file d'attente (ajout fait
    // hors-ligne, jamais encore envoyé) : sans ça, la suppression serait
    // "ressuscitée" dès que la file serait rejouée — même précaution que
    // FinancesRepository.definirPaiementTotal.
    await _baseLocale.retirerTachesPourEnregistrement('photos', photo.id);
    await _client.from('photos').delete().eq('id', photo.id);
    await _baseLocale.supprimerPhoto(photo.id);

    // Best-effort : la photo a déjà disparu de l'application à ce stade,
    // un fichier orphelin dans le stockage n'est pas une erreur à remonter.
    try {
      final cheminImage = _cheminDepuisUrlPublique(photo.url, bucketPhotosClients);
      if (cheminImage != null) {
        await _client.storage.from(bucketPhotosClients).remove([cheminImage]);
      }
      final audioUrl = photo.audioUrl;
      if (audioUrl != null) {
        final cheminAudio = _cheminDepuisUrlPublique(audioUrl, bucketAudiosClients);
        if (cheminAudio != null) {
          await _client.storage.from(bucketAudiosClients).remove([cheminAudio]);
        }
      }
    } catch (_) {
      // Ignoré, voir commentaire ci-dessus.
    }
  }

  /// Extrait le chemin interne au bucket depuis une URL publique Supabase
  /// Storage (`.../object/public/<bucket>/<chemin>`), nécessaire pour
  /// demander la suppression du fichier lui-même.
  String? _cheminDepuisUrlPublique(String url, String bucket) {
    final motif = '/object/public/$bucket/';
    final index = url.indexOf(motif);
    if (index == -1) return null;
    return url.substring(index + motif.length);
  }

  Future<void> chargerDepuisServeur(String clientId) async {
    try {
      final lignes = await _client.from('photos').select().eq('client_id', clientId);
      for (final ligne in lignes) {
        await _mettreEnCache(PhotoClient.depuisJson(ligne));
      }
    } catch (_) {
      // Hors-ligne : les photos déjà en cache restent consultables.
    }
  }

  /// Équivalent de [chargerDepuisServeur] pour les photos d'un groupe
  /// d'uniformes.
  Future<void> chargerPhotosGroupeDepuisServeur(String groupeId) async {
    try {
      final lignes = await _client.from('photos').select().eq('groupe_id', groupeId);
      for (final ligne in lignes) {
        await _mettreEnCache(PhotoClient.depuisJson(ligne));
      }
    } catch (_) {
      // Hors-ligne : les photos déjà en cache restent consultables.
    }
  }

  Stream<List<PhotoClient>> observerPhotosDuClient(String clientId) {
    return _baseLocale.observerPhotosDuClient(clientId).map(
          (lignes) => lignes.map(_depuisLigne).toList(),
        );
  }

  /// Toutes les photos (tissus/modèles, hommes/femmes confondus) d'un
  /// groupe d'uniformes — filtrées côté écran par [TypePhoto] et sexe,
  /// comme `observerPhotosDuClient` est filtré par type côté écran.
  Stream<List<PhotoClient>> observerPhotosDuGroupe(String groupeId) {
    return _baseLocale.observerPhotosDuGroupe(groupeId).map(
          (lignes) => lignes.map(_depuisLigne).toList(),
        );
  }

  PhotoClient _depuisLigne(PhotoEntry ligne) => PhotoClient(
        id: ligne.id,
        atelierId: ligne.atelierId,
        clientId: ligne.clientId,
        groupeId: ligne.groupeId,
        sexe: ligne.sexe,
        type: TypePhoto.depuisTexte(ligne.type),
        url: ligne.url,
        source: SourcePhoto.depuisTexte(ligne.source),
        audioUrl: ligne.audioUrl,
        createdAt: ligne.createdAt,
      );

  Future<void> _mettreEnCache(PhotoClient photo) {
    return _baseLocale.enregistrerPhoto(
      id: photo.id,
      atelierId: photo.atelierId,
      clientId: photo.clientId,
      groupeId: photo.groupeId,
      sexe: photo.sexe,
      type: photo.type.name,
      url: photo.url,
      source: photo.source.name,
      audioUrl: photo.audioUrl,
      createdAt: photo.createdAt,
    );
  }
}
