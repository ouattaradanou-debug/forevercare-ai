import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_providers.dart';
import '../core/sync/connectivity_provider.dart';
import 'router.dart';
import 'theme.dart';

class CaveManagerApp extends ConsumerWidget {
  const CaveManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Règle offline-first : dès que la connectivité revient, on vide la
    // file de synchronisation en attente (voir SyncService.synchroniser()).
    ref.listen(connectiviteProvider, (previous, next) {
      final estConnecte = next.valueOrNull ?? false;
      final etaitConnecte = previous?.valueOrNull ?? false;
      if (estConnecte && !etaitConnecte) {
        ref.read(syncServiceProvider).synchroniser();
      }
    });

    final routeur = ref.watch(_routeurProvider);

    return MaterialApp.router(
      title: 'Ma Cave',
      debugShowCheckedModeBanner: false,
      theme: construireTheme(),
      routerConfig: routeur,
    );
  }
}

final _routeurProvider = Provider((ref) => construireRouteur(ref));
