import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database_provider.dart';
import '../../../data/models/photo_client.dart';
import '../../../data/remote/supabase_client_provider.dart';
import '../../../data/sync/sync_providers.dart';
import '../data/photos_repository.dart';

final photosRepositoryProvider = Provider<PhotosRepository>((ref) {
  return PhotosRepository(
    client: ref.watch(supabaseClientProvider),
    baseLocale: ref.watch(baseLocaleProvider),
    syncEngine: ref.watch(syncEngineProvider),
  );
});

final photosDuClientProvider = StreamProvider.family<List<PhotoClient>, String>((ref, clientId) {
  return ref.watch(photosRepositoryProvider).observerPhotosDuClient(clientId);
});
