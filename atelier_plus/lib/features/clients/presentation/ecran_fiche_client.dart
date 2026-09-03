import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../../core/router/app_router.dart';
import '../../../data/models/client.dart';
import '../../auth/providers/auth_providers.dart';
import '../../branding/providers/branding_providers.dart';
import '../../permissions/providers/permissions_providers.dart';
import '../providers/clients_providers.dart';

/// Écran central d'un client : informations, et accès à la prise de mesure,
/// aux photos, aux rendez-vous et aux finances (ce dernier bouton
/// n'apparaît que pour le propriétaire — l'écran lui-même vérifie aussi le
/// rôle en défense en profondeur).
class EcranFicheClient extends ConsumerWidget {
  const EcranFicheClient({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientParIdProvider(clientId));
    final permissions = ref.watch(mesPermissionsProvider);
    final estProprietaire = ref.watch(estProprietaireProvider);
    final peutModifier = estProprietaire || (permissions.valueOrNull?.modifierClient ?? false);
    final peutPrendreMesure = estProprietaire || (permissions.valueOrNull?.prendreMesures ?? false);
    final peutAjouterPhoto = estProprietaire || (permissions.valueOrNull?.ajouterPhotos ?? false);

    return client.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (erreur, _) => Scaffold(body: Center(child: Text('Erreur : $erreur'))),
      data: (client) {
        if (client == null) {
          return const Scaffold(body: Center(child: Text('Client introuvable.')));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(client.nomComplet),
            actions: [
              if (peutModifier)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push(AppRoutes.modificationClient(client.id), extra: client),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (client.telephone != null)
                ListTile(leading: const Icon(Icons.phone), title: Text(client.telephone!)),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  enabled: peutPrendreMesure,
                  leading: const Icon(Icons.straighten),
                  title: const Text('Prendre une mesure'),
                  subtitle: peutPrendreMesure
                      ? null
                      : const Text('Non autorisé — demandez au propriétaire.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: peutPrendreMesure
                      ? () => context.push(AppRoutes.selectionTypeTenue(client.id))
                      : null,
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Photos (tissus et modèles)'),
                  subtitle: peutAjouterPhoto ? null : const Text('Lecture seule'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.photosClient(client.id)),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Prendre un rendez-vous'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.creationRendezVous, extra: client),
                ),
              ),
              if (estProprietaire)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.payments_outlined),
                    title: const Text('Finances'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.financesClient(client.id)),
                  ),
                ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf_outlined),
                  title: const Text('Exporter la fiche en PDF'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _exporterPdf(context, ref, client),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Ouvre l'aperçu d'impression/partage du système avec la fiche client
  /// (mesures les plus récentes par type de tenue), en-tête personnalisé
  /// avec le nom et le logo de l'atelier.
  Future<void> _exporterPdf(BuildContext context, WidgetRef ref, Client client) async {
    final atelier = await ref.read(atelierCourantProvider.future);
    if (atelier == null) return;

    final groupes =
        await ref.read(donneesExportClientProvider).dernieresMesuresParType(client.id);

    await Printing.layoutPdf(
      onLayout: (_) => ref.read(pdfExportServiceProvider).genererFicheClientPdf(
            atelier: atelier,
            client: client,
            groupesMesures: groupes,
          ),
    );
  }
}
