import 'package:ecoleplus/app/router.dart';
import 'package:ecoleplus/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Nom provisoire de l'application (à remplacer, voir docs/EVOLUTIONS.md).
const appName = 'EcolePlus';

class EcolePlusApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('fr'),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
