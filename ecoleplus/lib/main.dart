import 'package:ecoleplus/app/app.dart';
import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/clock.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuration passée à la compilation : `--dart-define-from-file=.env`.
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr');
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
  final db = AppDatabase.open();
  final session = await db.select(db.localSession).getSingleOrNull();
  final docs = await getApplicationDocumentsDirectory();
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        supabaseClientProvider.overrideWithValue(Supabase.instance.client),
        mediaDirProvider.overrideWithValue(docs),
        clockProvider.overrideWithValue(
          Clock(offset: Duration(milliseconds: session?.clockOffsetMs ?? 0)),
        ),
      ],
      child: const EcolePlusApp(),
    ),
  );
}
