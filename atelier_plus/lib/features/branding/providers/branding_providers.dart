import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database_provider.dart';
import '../data/donnees_export_client.dart';
import '../data/pdf_export_service.dart';

final pdfExportServiceProvider = Provider<PdfExportService>((ref) => PdfExportService());

final donneesExportClientProvider = Provider<DonneesExportClient>((ref) {
  return DonneesExportClient(ref.watch(baseLocaleProvider));
});
