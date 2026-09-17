import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/telephone_utils.dart';
import '../../../../data/models/groupe_uniforme.dart';
import '../../../../data/models/membre_groupe_uniforme.dart';
import '../../../../data/models/mesure_uniforme.dart';
import '../../../../data/models/photo_groupe_uniforme.dart';
import '../../../../shared/widgets/image_photo.dart';
import '../../../../shared/widgets/visionneuse_photo.dart';
import '../providers/uniformes_providers.dart';

/// Fiche d'un groupe d'uniformes : informations générales, répondant,
/// photos de modèles/tissus, et liste des membres avec le statut de prise
/// de mesures de chacun. Voir la demande "Mesures des uniformes".
class GroupeUniformeDetailPage extends ConsumerWidget {
  const GroupeUniformeDetailPage({super.key, required this.groupe});

  final GroupeUniforme groupe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GroupeUniforme groupeActuel =
        ref.watch(groupeUniformeDetailProvider(groupe.id)).asData?.value ??
        groupe;
    final List<PhotoGroupeUniforme> photos =
        ref.watch(photosGroupeUniformeProvider(groupe.id)).asData?.value ??
        const [];
    final List<MembreGroupeUniforme> membres =
        ref.watch(membresGroupeUniformeProvider(groupe.id)).asData?.value ??
        const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(groupeActuel.nom),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Modifier',
            onPressed: () => context.push(
              '/uniformes/${groupeActuel.id}/modifier',
              extra: groupeActuel,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/uniformes/${groupeActuel.id}/membres/nouveau',
          extra: groupeActuel,
        ),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Ajouter un membre'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.xxl,
        ),
        children: [
          _CarteInfosGroupe(groupe: groupeActuel),
          const SizedBox(height: AppSpacing.xl),
          _SectionPhotosGroupe(
            titre: 'Modèles (hommes/garçons)',
            photos: photos.where((p) => p.type == 'modele_homme').toList(),
          ),
          _SectionPhotosGroupe(
            titre: 'Modèles (femmes/filles)',
            photos: photos.where((p) => p.type == 'modele_femme').toList(),
          ),
          _SectionPhotosGroupe(
            titre: 'Tissus (hommes/garçons)',
            photos: photos.where((p) => p.type == 'tissu_homme').toList(),
          ),
          _SectionPhotosGroupe(
            titre: 'Tissus (femmes/filles)',
            photos: photos.where((p) => p.type == 'tissu_femme').toList(),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Membres', style: Theme.of(context).textTheme.headlineMedium),
              Text(
                '${membres.length}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          if (membres.isEmpty)
            const Text("Aucun membre pour l'instant.")
          else
            for (final MembreGroupeUniforme membre in membres)
              _CarteMembre(groupe: groupeActuel, membre: membre),
        ],
      ),
    );
  }
}

class _CarteInfosGroupe extends StatelessWidget {
  const _CarteInfosGroupe({required this.groupe});

  final GroupeUniforme groupe;

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

  @override
  Widget build(BuildContext context) {
    final String? repondantNom = groupe.repondantNom;
    final String? repondantTelephone = groupe.repondantTelephone;
    if ((repondantNom == null || repondantNom.trim().isEmpty) &&
        (repondantTelephone == null || repondantTelephone.trim().isEmpty)) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (repondantNom != null && repondantNom.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Répondant', style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      repondantNom,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            if (repondantTelephone != null &&
                repondantTelephone.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Contact', style: Theme.of(context).textTheme.bodyMedium),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          repondantTelephone,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        IconButton(
                          onPressed: () => _appeler(context, repondantTelephone),
                          icon: const Icon(Icons.call, color: AppColors.succes),
                          tooltip: 'Appeler',
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          onPressed: () =>
                              _ouvrirWhatsApp(context, repondantTelephone),
                          icon: const Icon(Icons.chat, color: AppColors.succes),
                          tooltip: 'WhatsApp',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionPhotosGroupe extends StatelessWidget {
  const _SectionPhotosGroupe({required this.titre, required this.photos});

  final String titre;
  final List<PhotoGroupeUniforme> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();
    final List<ElementPhoto> elements = [
      for (final PhotoGroupeUniforme p in photos)
        (cheminLocal: p.cheminLocal, url: p.url, commentaire: p.commentaire),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              for (int i = 0; i < photos.length; i++)
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
            ],
          ),
        ],
      ),
    );
  }
}

class _CarteMembre extends ConsumerWidget {
  const _CarteMembre({required this.groupe, required this.membre});

  final GroupeUniforme groupe;
  final MembreGroupeUniforme membre;

  Future<void> _confirmerSuppression(BuildContext context, WidgetRef ref) async {
    final bool? confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce membre ?'),
        content: Text(
          '${membre.nomComplet} et son historique de mesures seront '
          'définitivement supprimés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.erreur),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    try {
      await ref.read(uniformeRepositoryProvider).supprimerMembre(membre.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de supprimer : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MesureUniforme> mesures =
        ref.watch(mesuresMembreUniformeProvider(membre.id)).asData?.value ??
        const [];
    final bool mesurePrise = mesures.any((m) => m.aAuMoinsUneValeurRenseignee);
    final bool termine = membre.tenueTerminee;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      color: termine ? AppColors.vertClair : null,
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.m),
        // Toute la ligne est cliquable (pas seulement un bouton à droite) :
        // appuyer sur le nom du membre ouvre directement ses mesures. Un
        // appui long propose de le supprimer.
        onTap: () => context.push(
          '/uniformes/${groupe.id}/membres/${membre.id}/mesures',
          extra: (groupe: groupe, membre: membre),
        ),
        onLongPress: () => _confirmerSuppression(context, ref),
        leading: CircleAvatar(
          backgroundColor: termine
              ? Colors.white.withValues(alpha: 0.5)
              : mesurePrise
              ? AppColors.succes.withValues(alpha: 0.15)
              : AppColors.erreur.withValues(alpha: 0.15),
          child: Icon(
            termine
                ? Icons.check_circle
                : mesurePrise
                ? Icons.check_circle_outline
                : Icons.straighten,
            color: termine
                ? AppColors.vertFonce
                : mesurePrise
                ? AppColors.succes
                : AppColors.erreur,
          ),
        ),
        title: Text(
          membre.nomComplet,
          style: termine
              ? const TextStyle(
                  color: AppColors.anthracite900,
                  fontWeight: FontWeight.w600,
                )
              : null,
        ),
        subtitle: Text(
          termine
              ? 'Tenue confectionnée'
              : mesurePrise
              ? 'Mesures prises — appuyer pour consulter'
              : 'Mesures non prises',
          style: termine
              ? TextStyle(color: AppColors.anthracite900.withValues(alpha: 0.75))
              : null,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: termine ? AppColors.anthracite900 : null,
        ),
      ),
    );
  }
}
