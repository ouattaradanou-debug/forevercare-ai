import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Formats de date/heure en français (nécessaire pour l'affichage des
  // dates de rendez-vous, de mesures, etc. dans toute l'application).
  await initializeDateFormatting('fr_FR');

  // Remarque Phase 0 : l'initialisation de Supabase (connexion au projet
  // distant) et l'ouverture de la base locale Drift seront ajoutées à
  // partir de la Phase 1, une fois le projet Supabase du tailleur créé.

  runApp(const AtelierPlusApp());
}
