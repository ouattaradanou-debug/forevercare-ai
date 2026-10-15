import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database_provider.dart';
import '../../../data/remote/supabase_client_provider.dart';
import '../data/mesures_repository.dart';

final mesuresRepositoryProvider = Provider<MesuresRepository>((ref) {
  return MesuresRepository(
    client: ref.watch(supabaseClientProvider),
    baseLocale: ref.watch(baseLocaleProvider),
  );
});
