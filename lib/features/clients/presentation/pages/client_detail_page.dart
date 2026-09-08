import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/client.dart';
import '../../../../data/models/mesure.dart';
import '../../../../data/models/photo.dart';
import '../../../../data/models/rendez_vous.dart';
import '../providers/clients_providers.dart';
import '../widgets/section_titre.dart';

/// Fiche client (lecture seule) : toutes les informations enregistrées à
/// la création du client — identité, mesures, photos, rendez-vous.
class ClientDetailPage extends ConsumerWidget {
  const ClientDetailPage({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Mesure> mesures =
        ref.watch(mesuresClientProvider(client.id)).asData?.value ?? const [];
    final List<Photo> photos =
        ref.watch(photosClientProvider(client.id)).asData?.value ?? const [];
    final List<RendezVous> rendezVous =
        ref.watch(rendezVousClientProvider(client.id)).asData?.value ??
        const [];

    final List<Photo> photosTissu = photos
        .where((p) => p.type == 'tissu')
        .toList();
    final List<Photo> photosModele = photos
        .where((p) => p.type == 'modele')
        .toList();
    final Mesure? derniereMesure = mesures.isEmpty ? null : mesures.first;

    return Scaffold(
      appBar: AppBar(title: Text(client.nomComplet)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          _CarteInfos(client: client),
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
}

class _GaleriePhotos extends StatelessWidget {
  const _GaleriePhotos({required this.photos});

  final List<Photo> photos;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        for (final Photo photo in photos)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.champ),
            child: Image.file(
              File(photo.cheminLocal),
              width: 84,
              height: 84,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }
}
