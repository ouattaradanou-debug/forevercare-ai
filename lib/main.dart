import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Formats de date/heure en français (nécessaire pour l'affichage des
  // dates de rendez-vous, de mesures, etc. dans toute l'application).
  await initializeDateFormatting('fr_FR');

  // Connexion au projet Supabase (voir lib/core/config/supabase_config.dart
  // pour la marche à suivre de configuration).
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const ProviderScope(child: AtelierPlusApp()));
}
