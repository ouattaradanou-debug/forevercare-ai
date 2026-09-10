import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/telephone_utils.dart';
import '../../../../data/models/client.dart';
import '../../../../data/models/mesure.dart';
import '../../../../data/models/photo.dart';
import '../../../../data/models/rendez_vous.dart';
import '../../../../data/models/utilisateur.dart';
import '../../../../shared/widgets/image_photo.dart';
import '../../../../shared/widgets/visionneuse_photo.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../permissions/presentation/providers/apprentis_providers.dart';
import '../providers/clients_providers.dart';
import '../widgets/carte_finances_client.dart';
import '../widgets/section_titre.dart';

/// Fiche client (lecture seule, avec accès à la modification) : toutes les
/// informations enregistrées pour ce client — identité, mesures, photos,
/// rendez-vous.
class ClientDetailPage extends ConsumerWidget {
  const ClientDetailPage({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Toujours préférer la version à jour (via le flux local) à celle reçue
    // en argument de navigation : après une modification, ce widget n'est
    // pas recréé avec un nouveau `client`, seul le flux change.
    final Client clientActuel =
        ref.watch(clientDetailProvider(client.id)).asData?.value ?? client;

    final List<Mesure> mesures =
        ref.watch(mesuresClientProvider(client.id)).asData?.value ?? const [];
    final List<Photo> photos =
        ref.watch(photosClientProvider(client.id)).asData?.value ?? const [];
    final List<RendezVous> rendezVous =
        ref.watch(rendezVousClientProvider(client.id)).asData?.value ??
        const [];

    final Utilisateur? utilisateur = ref
        .watch(utilisateurCourantProvider)
        .asData
        ?.value;
    final bool estProprietaire = utilisateur?.estProprietaire ?? false;
    bool peutModifier = estProprietaire;
    if (utilisateur != null && !utilisateur.estProprietaire) {
      final permissions = ref
          .watch(permissionsApprentiProvider(utilisateur.id))
          .asData
          ?.value;
      peutModifier = permissions?.modifierClient ?? false;
    }

    final List<Photo> photosTissu = photos
        .where((p) => p.type == 'tissu')
        .toList();
    final List<Photo> photosModele = photos
        .where((p) => p.type == 'modele')
        .toList();
    final Mesure? derniereMesure = mesures.isEmpty ? null : mesures.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(clientActuel.nomComplet),
        actions: [
          if (peutModifier)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Modifier',
              onPressed: () => context.push(
                '/clients/${clientActuel.id}/modifier',
                extra: clientActuel,
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          _CarteInfos(client: clientActuel),
          const SizedBox(height: AppSpacing.xl),
          SectionTitre(
            icone: Icons.straighten,
            titre: 'Mesures',
            couleur: AppColors.terracotta600,
          ),
          const SizedBox(height: AppSpacing.m),
          if (derniereMesure == null ||
              !derniereMesure.aAuMoinsUneValeurRenseignee)
            const Text('Aucune mesure enregistrée.')
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final MapEntry<String, String> entree
                        in derniereMesure.valeurs.entries)
                      if (entree.value.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entree.key),
                              Text(
                                entree.value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          SectionTitre(
            icone: Icons.texture_outlined,
            titre: 'Photos',
            couleur: AppColors.or600,
          ),
          const SizedBox(height: AppSpacing.m),
          if (photosTissu.isEmpty && photosModele.isEmpty)
            const Text('Aucune photo enregistrée.')
          else ...[
            if (photosTissu.isNotEmpty) ...[
              Text(
                'Tissu',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.s),
              _GaleriePhotos(photos: photosTissu),
              const SizedBox(height: AppSpacing.m),
            ],
            if (photosModele.isNotEmpty) ...[
              Text(
                'Modèle',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.s),
              _GaleriePhotos(photos: photosModele),
            ],
          ],
          const SizedBox(height: AppSpacing.xl),
          SectionTitre(
            icone: Icons.event_available,
            titre: 'Rendez-vous',
            couleur: AppColors.or600,
          ),
          const SizedBox(height: AppSpacing.m),
          if (rendezVous.isEmpty)
            const Text('Aucun rendez-vous planifié.')
          else
            for (final RendezVous rdv in rendezVous)
              Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.s),
                child: ListTile(
                  leading: const Icon(
                    Icons.event_available,
                    color: AppColors.or600,
                  ),
                  title: Text(
                    DateFormat(
                      "EEEE d MMMM 'à' HH'h'mm",
                      'fr_FR',
                    ).format(rdv.dateHeure),
                  ),
                ),
              ),
          if (estProprietaire) ...[
            const SizedBox(height: AppSpacing.xl),
            CarteFinancesClient(clientId: client.id),
          ],
        ],
      ),
    );
  }
}

class _CarteInfos extends StatelessWidget {
  const _CarteInfos({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ligne(context, 'Nom', client.nom),
            _ligne(context, 'Prénom', client.prenom),
            if (client.telephone != null && client.telephone!.trim().isNotEmpty)
              _ligneTelephone(context, client.telephone!)
            else
              _ligne(context, 'Téléphone', client.telephone),
            _ligne(context, 'Sexe', client.sexe),
            _ligne(
              context,
              'Date de prise des mesures',
              client.datePriseMesures != null
                  ? DateFormat.yMMMMd('fr_FR').format(client.datePriseMesures!)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _ligne(BuildContext context, String libelle, String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(libelle, style: Theme.of(context).textTheme.bodyMedium),
          Text(valeur, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _ligneTelephone(BuildContext context, String telephone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Téléphone', style: Theme.of(context).textTheme.bodyMedium),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                telephone,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: AppSpacing.s),
              IconButton(
                onPressed: () => _appeler(context, telephone),
                icon: const Icon(Icons.call, color: AppColors.succes),
                tooltip: 'Appeler',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: () => _ouvrirWhatsApp(context, telephone),
                icon: const Icon(Icons.chat, color: AppColors.succes),
                tooltip: 'WhatsApp',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _appeler(BuildContext context, String telephone) async {
    final Uri uri = TelephoneUtils.lienAppel(telephone);
    final bool ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Impossible de lancer l'appel.")));
    }
  }

  Future<void> _ouvrirWhatsApp(BuildContext context, String telephone) async {
    final Uri uri = TelephoneUtils.lienWhatsApp(telephone);
    bool ok = false;

    // Cible explicitement le paquet de l'appli WhatsApp standard, pour ne
    // pas laisser Android ouvrir WhatsApp Business à la place quand les
    // deux sont installées. Si l'appli standard n'est pas installée (ou
    // hors Android), on retombe sur le lancement générique ci-dessous.
    if (Platform.isAndroid) {
      try {
        await AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: uri.toString(),
          package: 'com.whatsapp',
        ).launch();
        ok = true;
      } catch (_) {
        ok = false;
      }
    }

    if (!ok) {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Impossible d'ouvrir WhatsApp. Vérifie que WhatsApp est "
            'installé sur ce téléphone.',
          ),
        ),
      );
    }
  }
}

class _GaleriePhotos extends StatelessWidget {
  const _GaleriePhotos({required this.photos});

  final List<Photo> photos;

  @override
  Widget build(BuildContext context) {
    final List<ElementPhoto> elements = [
      for (final Photo p in photos)
        (cheminLocal: p.cheminLocal, url: p.url, commentaire: p.commentaire),
    ];
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        for (int i = 0; i < photos.length; i++)
          SizedBox(
            width: 84,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () => afficherPhotosPleinEcran(
                    context,
                    elements: elements,
                    indexInitial: i,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.champ),
                    child: imagePhoto(
                      cheminLocal: photos[i].cheminLocal,
                      url: photos[i].url,
                      width: 84,
                      height: 84,
                    ),
                  ),
                ),
                if ((photos[i].commentaire ?? '').isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    photos[i].commentaire!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
