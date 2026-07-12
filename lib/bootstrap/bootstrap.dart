import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/app.dart';

/// Initialise tous les services de l'application avant son lancement.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Les initialisations globales seront ajoutées progressivement :
  //
  // - Configuration
  // - Logger
  // - Base de données
  // - Notifications
  // - Firebase
  // - IA
  // - Synchronisation Cloud

  runApp(const ProviderScope(child: ForeverCareApp()));
}
