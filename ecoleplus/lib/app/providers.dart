import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ecoleplus/core/clock.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/sync/local_store.dart';
import 'package:ecoleplus/core/sync/supabase_sync_remote.dart';
import 'package:ecoleplus/core/sync/sync_engine.dart';
import 'package:ecoleplus/core/sync/sync_remote.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/auth/data/auth_service.dart';
import 'package:ecoleplus/features/auth/data/members_service.dart';
import 'package:ecoleplus/features/school/data/school_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remplacés au démarrage (main.dart) ou dans les tests.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider'),
);
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => throw UnimplementedError('supabaseClientProvider'),
);
final mediaDirProvider = Provider<Directory?>((ref) => null);

/// Clé de la base chiffrée du téléphone (A10) ; null dans les tests (base
/// en mémoire, non chiffrée).
final cleBaseProvider = Provider<String?>((ref) => null);
final clockProvider = Provider<Clock>((ref) => Clock());

final localStoreProvider = Provider<LocalStore>(
  (ref) => LocalStore(ref.watch(databaseProvider), ref.watch(clockProvider)),
);
final syncRemoteProvider = Provider<SyncRemote>(
  (ref) => SupabaseSyncRemote(ref.watch(supabaseClientProvider)),
);
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(
    store: ref.watch(localStoreProvider),
    remote: ref.watch(syncRemoteProvider),
    mediaDir: ref.watch(mediaDirProvider),
    onRevoked: () => effacerTelephoneDeconnecte(
      ref.read(databaseProvider),
      ref.read(authApiProvider),
    ),
  );
  ref.onDispose(engine.dispose);
  return engine;
});
final authApiProvider = Provider<AuthApi>(
  (ref) => SupabaseAuthApi(ref.watch(supabaseClientProvider)),
);
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    api: ref.watch(authApiProvider),
    store: ref.watch(localStoreProvider),
    engine: ref.watch(syncEngineProvider),
  ),
);
final membersServiceProvider = Provider<MembersService>(
  (ref) =>
      MembersService(ref.watch(authApiProvider), ref.watch(localStoreProvider)),
);
final schoolRepositoryProvider = Provider<SchoolRepository>(
  (ref) => SchoolRepository(
    ref.watch(localStoreProvider),
    mediaDir: ref.watch(mediaDirProvider),
  ),
);

/// Session ouverte sur ce téléphone (null = personne n'est connecté).
final sessionProvider = StreamProvider<LocalSessionRow?>(
  (ref) => ref.watch(authServiceProvider).watchSession(),
);

/// État affiché en permanence (R3).
class SyncStatus {
  const new({
    required this.pending,
    required this.refused,
    required this.state,
  });
  final int pending;
  final int refused;
  final SyncState state;

  String get label {
    if (state.phase == SyncPhase.running) return 'Synchronisation en cours…';
    if (refused > 0) {
      return refused == 1
          ? '1 modification refusée — touchez pour voir'
          : '$refused modifications refusées — touchez pour voir';
    }
    if (state.phase == SyncPhase.sessionExpired) {
      return 'Reconnectez-vous pour envoyer vos données';
    }
    if (pending == 0) return 'Tout est synchronisé';
    final n = pending == 1
        ? '1 élément en attente'
        : '$pending éléments en attente';
    return state.phase == SyncPhase.offline
        ? '$n — envoi au retour du réseau'
        : n;
  }
}

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final store = ref.watch(localStoreProvider);
  final engine = ref.watch(syncEngineProvider);
  final controller = StreamController<SyncStatus>();
  var pending = 0;
  var refused = 0;
  void emit() => controller.add(
    SyncStatus(pending: pending, refused: refused, state: engine.state),
  );
  final subs = [
    store.watchCount('en_attente').listen((n) {
      pending = n;
      emit();
    }),
    store.watchCount('refuse').listen((n) {
      refused = n;
      emit();
    }),
    engine.states.listen((_) => emit()),
  ];
  ref.onDispose(() async {
    for (final s in subs) {
      await s.cancel();
    }
    await controller.close();
  });
  return controller.stream;
});

/// Lance la synchronisation sans jamais bloquer l'écran : au retour du
/// réseau, quelques secondes après chaque saisie, et toutes les 5 minutes.
class SyncScheduler {
  new(this._ref);
  final Ref _ref;
  final _subs = <StreamSubscription<Object?>>[];
  Timer? _periodic;
  Timer? _debounce;

  void start() {
    final store = _ref.read(localStoreProvider);
    _subs
      ..add(
        Connectivity().onConnectivityChanged.listen((r) {
          if (!r.contains(ConnectivityResult.none)) unawaited(_trigger());
        }),
      )
      ..add(
        store.watchCount('en_attente').listen((n) {
          if (n > 0) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(seconds: 3), _trigger);
          }
        }),
      );
    _periodic = Timer.periodic(
      const Duration(minutes: 5),
      (_) => unawaited(_trigger()),
    );
    unawaited(_trigger());
  }

  Future<void> _trigger() async {
    final session = await _ref.read(authServiceProvider).session();
    if (session != null) await _ref.read(syncEngineProvider).syncNow();
  }

  Future<void> stop() async {
    _periodic?.cancel();
    _debounce?.cancel();
    for (final s in _subs) {
      await s.cancel();
    }
  }
}

final syncSchedulerProvider = Provider<SyncScheduler?>((ref) {
  final s = SyncScheduler(ref)..start();
  ref.onDispose(s.stop);
  return s;
});
