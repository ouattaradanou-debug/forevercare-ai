import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/app/router.dart';
import 'package:ecoleplus/app/theme.dart';
import 'package:ecoleplus/features/lock/presentation/lock_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Nom provisoire de l'application (à remplacer, voir docs/EVOLUTIONS.md).
const appName = 'EcolePlus';

/// Durée en arrière-plan au-delà de laquelle le code est redemandé.
const delaiVerrouillage = Duration(minutes: 2);

class EcolePlusApp extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<EcolePlusApp> createState() => _EcolePlusAppState();
}

class _EcolePlusAppState extends ConsumerState<EcolePlusApp> {
  late final AppLifecycleListener _listener;
  DateTime? _cache;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onHide: () => _cache = DateTime.now(),
      onShow: () {
        final depuis = _cache;
        if (depuis != null &&
            DateTime.now().difference(depuis) > delaiVerrouillage) {
          ref.read(lockedProvider.notifier).lock();
        }
        _cache = null;
      },
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Démarre la synchronisation automatique (réseau, saisies, minuterie).
    ref.watch(syncSchedulerProvider);
    return MaterialApp.router(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
