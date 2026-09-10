import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/local/database_provider.dart';
import '../../features/clients/presentation/providers/clients_providers.dart';
import '../../features/clients/presentation/providers/finances_providers.dart';
import 'sync_engine.dart';

final Provider<SyncEngine> syncEngineProvider = Provider<SyncEngine>(
  (ref) => SyncEngine(
    Supabase.instance.client,
    ref.watch(appDatabaseProvider),
    ref.watch(clientRepositoryProvider),
    ref.watch(financesRepositoryProvider),
  ),
);
