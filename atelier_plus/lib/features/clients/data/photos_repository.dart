import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../data/models/photo_client.dart';
import '../../../data/remote/stockage_repository.dart';
import '../../abonnement/data/abonnement_guard.dart';

const String bucketPhotosClients = 'photos-clients';
const String bucketAudiosClients = 'audios-clients';

/// Photos de tissus/modèles associées à un client. Contrairement aux
/// gabarits, l'ajout d'une photo fait partie de l'usage courant (comme les
/// clients et les mesures) : écriture locale d'abord, avec tentative
/// d'upload immédiate en meilleur effort.
class PhotosRepository {
  PhotosRepository({required SupabaseClient client, required AppDatabase baseLocale})
      : _client = client,
        _baseLocale = baseLocale,
        _stockage = StockageRepository(client);

  final SupabaseClient _client;
  final AppDatabase _baseLocale;
  final StockageRepository _stockage;
  static const _uuid = Uuid();

  /// Nécessite une connexion pour l'upload lui-même (une photo ne peut pas
  /// être stockée durablement sans être envoyée à Supabase Storage — il n'y
  /// a pas de cache local de fichiers binaires en Phase 2). Si hors-ligne,
  /// l'erreur remonte à l'écran, qui invite à réessayer une fois reconnecté.
  Future<PhotoClient> ajouterPhoto({
    required String atelierId,
    required String clientId,
    required TypePhoto type,
    required SourcePhoto source,
    required XFile fichier,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final url = await _stockage.televerserImageCompressee(
      fichier: fichier,
      bucket: bucketPhotosClients,
      dossier: clientId,
    );

    final photo = PhotoClient(
      id: _uuid.v4(),
      atelierId: atelierId,
      clientId: clientId,
      type: type,
      url: url,
      source: source,
      createdAt: DateTime.now().toUtc(),
    );

    await _client.from('photos').insert(photo.versJson());
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
      dossier: photo.clientId,
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

  Stream<List<PhotoClient>> observerPhotosDuClient(String clientId) {
    return _baseLocale.observerPhotosDuClient(clientId).map(
          (lignes) => lignes
              .map(
                (ligne) => PhotoClient(
                  id: ligne.id,
                  atelierId: ligne.atelierId,
                  clientId: ligne.clientId,
                  type: TypePhoto.depuisTexte(ligne.type),
                  url: ligne.url,
                  source: SourcePhoto.depuisTexte(ligne.source),
                  audioUrl: ligne.audioUrl,
                  createdAt: ligne.createdAt,
                ),
              )
              .toList(),
        );
  }

  Future<void> _mettreEnCache(PhotoClient photo) {
    return _baseLocale.enregistrerPhoto(
      id: photo.id,
      atelierId: photo.atelierId,
      clientId: photo.clientId,
      type: photo.type.name,
      url: photo.url,
      source: photo.source.name,
      audioUrl: photo.audioUrl,
      createdAt: photo.createdAt,
    );
  }
}
