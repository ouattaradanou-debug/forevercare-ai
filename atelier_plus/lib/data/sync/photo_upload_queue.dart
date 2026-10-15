import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/database.dart';
import '../remote/stockage_repository.dart';

const String _bucketPhotosClients = 'photos-clients';

/// Rejoue les photos ajoutées hors-ligne (fichier local déjà sur
/// l'appareil, jamais encore envoyé à Supabase Storage) — équivalent de
/// [SyncEngine] pour les fichiers binaires, qui ne peuvent pas passer par
/// la file d'attente JSON de `SyncQueueEntries`.
///
/// Déclenchée par [SyncTrigger] en même temps que [SyncEngine], juste après
/// celle-ci : si une photo référence un client/groupe lui-même créé
/// hors-ligne, le laisser d'abord se synchroniser évite un rejet par
/// contrainte de clé étrangère.
class PhotoUploadQueue {
  PhotoUploadQueue({required SupabaseClient client, required AppDatabase baseLocale})
      : _client = client,
        _baseLocale = baseLocale,
        _stockage = StockageRepository(client);

  final SupabaseClient _client;
  final AppDatabase _baseLocale;
  final StockageRepository _stockage;

  bool _enCours = false;

  Future<void> traiterPhotosEnAttente() async {
    if (_enCours) return;
    _enCours = true;
    try {
      final photos = await _baseLocale.photosEnAttenteEnvoi();
      for (final photo in photos) {
        await _envoyerUnePhoto(photo);
      }
    } finally {
      _enCours = false;
    }
  }

  Future<void> _envoyerUnePhoto(PhotoEntry photo) async {
    final cheminLocal = photo.cheminLocalEnAttente;
    if (cheminLocal == null) return;

    final fichierLocal = File(cheminLocal);
    if (!await fichierLocal.exists()) {
      // Fichier introuvable (espace disque libéré manuellement, etc.) :
      // impossible à envoyer, on retire seulement la ligne plutôt que de
      // retenter indéfiniment un fichier qui n'existe plus.
      await _baseLocale.supprimerPhoto(photo.id);
      return;
    }

    try {
      final url = await _stockage.televerserImageCompressee(
        fichier: XFile(cheminLocal),
        bucket: _bucketPhotosClients,
        dossier: photo.clientId ?? photo.groupeId!,
      );
      await _client.from('photos').insert({
        'id': photo.id,
        'atelier_id': photo.atelierId,
        'client_id': photo.clientId,
        'groupe_id': photo.groupeId,
        'sexe': photo.sexe,
        'type': photo.type,
        'url': url,
        'source': photo.source,
        'audio_url': photo.audioUrl,
      });
      await _baseLocale.marquerPhotoEnvoyee(id: photo.id, url: url);
      await fichierLocal.delete();
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Ligne déjà présente côté serveur (un envoi précédent avait en
        // fait réussi avant une coupure au mauvais moment) : on relit son
        // URL plutôt que de retenter indéfiniment.
        final ligne =
            await _client.from('photos').select().eq('id', photo.id).maybeSingle();
        if (ligne != null) {
          await _baseLocale.marquerPhotoEnvoyee(id: photo.id, url: ligne['url'] as String);
          await fichierLocal.delete();
        }
      }
      // Autre erreur (ex. 23503 : client/groupe pas encore synchronisé) :
      // reste en attente, un prochain retour de connexion réessaiera.
    } catch (_) {
      // Toujours hors-ligne, ou coupure pendant l'envoi : reste en attente.
    }
  }
}
