import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/gestion_erreurs.dart';
import '../../../core/widgets/ecran_photo_plein_ecran.dart';
import '../../../core/widgets/en_tete_section.dart';
import '../../../data/models/client.dart';
import '../../../data/models/photo_client.dart';
import '../../../data/models/rendez_vous.dart';
import '../../auth/providers/auth_providers.dart';
import '../../branding/providers/branding_providers.dart';
import '../../finances/presentation/section_finances_client.dart';
import '../../mesures/providers/gabarits_providers.dart';
import '../../mesures/providers/mesures_providers.dart';
import '../../mesures/utils/choix_gabarit.dart';
import '../../permissions/providers/permissions_providers.dart';
import '../../rendezvous/providers/rendezvous_providers.dart';
import '../providers/clients_providers.dart';
import '../providers/photos_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);

/// Fiche client fidèle à l'ancienne application : une seule page qui
/// affiche directement les informations, les mesures, les photos, le
/// prochain rendez-vous et les finances — plutôt qu'un menu de cartes
/// ouvrant chacune un autre écran. Chaque en-tête de section reste
/// cliquable pour prendre une nouvelle mesure, ajouter une photo ou un
/// rendez-vous (non montré sur les captures de l'ancienne application, qui
/// ne représentent qu'une fiche déjà remplie, mais nécessaire pour ne pas
/// perdre ces actions).
class EcranFicheClient extends ConsumerStatefulWidget {
  const EcranFicheClient({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<EcranFicheClient> createState() => _EcranFicheClientState();
}

class _EcranFicheClientState extends ConsumerState<EcranFicheClient> {
  @override
  void initState() {
    super.initState();
    // Rapatriement best-effort (silencieux hors-ligne) de tout ce que cette
    // page affiche désormais directement : la fiche reste utilisable
    // immédiatement via le cache local pendant ce chargement.
    Future.microtask(() async {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      if (utilisateur == null) return;
      await ref.read(gabaritsRepositoryProvider).chargerDepuisServeur(utilisateur.atelierId);
      await ref.read(rendezVousRepositoryProvider).chargerDepuisServeur(utilisateur.atelierId);
      await ref.read(photosRepositoryProvider).chargerDepuisServeur(widget.clientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(clientParIdProvider(widget.clientId));
    final permissions = ref.watch(mesPermissionsProvider);
    final estProprietaire = ref.watch(estProprietaireProvider);
    final peutModifier = estProprietaire || (permissions.valueOrNull?.modifierClient ?? false);
    final peutPrendreMesure = estProprietaire || (permissions.valueOrNull?.prendreMesures ?? false);

    return client.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (erreur, _) => Scaffold(body: Center(child: Text('Erreur : $erreur'))),
      data: (client) {
        if (client == null) {
          return const Scaffold(body: Center(child: Text('Client introuvable.')));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(client.nomComplet, overflow: TextOverflow.ellipsis),
            backgroundColor: _bleuSeda,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                tooltip: 'Exporter la fiche en PDF',
                onPressed: () => _exporterPdf(context, ref, client),
              ),
              if (peutModifier)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () =>
                      context.push(AppRoutes.modificationClient(client.id), extra: client),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CarteInfos(client: client),
              const SizedBox(height: 28),
              EnTeteSection(
                icone: Icons.straighten_outlined,
                couleurFond: const Color(0xFFF5DCD3),
                couleurIcone: const Color(0xFF8A4B24),
                titre: 'Mesures',
                onTap: peutPrendreMesure
                    ? () => context.push(AppRoutes.selectionTypeTenue(client.id))
                    : null,
              ),
              const SizedBox(height: 12),
              _SectionMesures(clientId: client.id, sexe: client.sexe),
              const SizedBox(height: 28),
              EnTeteSection(
                icone: Icons.photo_library_outlined,
                couleurFond: const Color(0xFFF0E6C8),
                couleurIcone: const Color(0xFFA47B1B),
                titre: 'Photos',
                onTap: () => context.push(AppRoutes.photosClient(client.id)),
              ),
              const SizedBox(height: 12),
              _SectionPhotos(clientId: client.id),
              const SizedBox(height: 28),
              EnTeteSection(
                icone: Icons.event_available_outlined,
                couleurFond: const Color(0xFFF0E6C8),
                couleurIcone: const Color(0xFFA47B1B),
                titre: 'Rendez-vous',
                onTap: () => context.push(AppRoutes.creationRendezVous, extra: client),
              ),
              const SizedBox(height: 12),
              _SectionRendezVous(clientId: client.id),
              if (estProprietaire) ...[
                const SizedBox(height: 28),
                const EnTeteSection(
                  icone: Icons.savings_outlined,
                  couleurFond: Color(0xFFDCEADF),
                  couleurIcone: Color(0xFF2E7D32),
                  titre: 'Finances',
                ),
                const SizedBox(height: 12),
                SectionFinancesClient(clientId: client.id),
              ],
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

/// Conteneur blanc arrondi commun à toutes les cartes de la fiche, cohérent
/// avec le reste de l'application (Champs de mesure, etc.).
class _Carte extends StatelessWidget {
  const _Carte({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 4)],
      ),
      child: child,
    );
  }
}

class _LigneInfo extends StatelessWidget {
  const _LigneInfo(this.libelle, this.valeur);

  final String libelle;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(libelle, style: const TextStyle(color: Color(0xFF6F6259))),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              valeur,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ligne "Téléphone" avec, comme dans l'ancienne application, un bouton
/// pour appeler et un pour envoyer un SMS directement depuis la fiche.
class _LigneTelephone extends StatelessWidget {
  const _LigneTelephone(this.telephone);

  final String telephone;

  Future<void> _appeler(BuildContext context) => executerAvecErreurAffichee(
        context,
        () => launchUrl(Uri(scheme: 'tel', path: telephone)),
      );

  Future<void> _envoyerSms(BuildContext context) => executerAvecErreurAffichee(
        context,
        () => launchUrl(Uri(scheme: 'sms', path: telephone)),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Text('Téléphone', style: TextStyle(color: Color(0xFF6F6259))),
          const Spacer(),
          Text(telephone, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (telephone.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.call, color: Color(0xFF2E7D32)),
              visualDensity: VisualDensity.compact,
              tooltip: 'Appeler',
              onPressed: () => _appeler(context),
            ),
            IconButton(
              icon: const Icon(Icons.message_outlined, color: Color(0xFF2E7D32)),
              visualDensity: VisualDensity.compact,
              tooltip: 'Envoyer un SMS',
              onPressed: () => _envoyerSms(context),
            ),
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
    return _Carte(
      child: Column(
        children: [
          _LigneInfo('Nom', client.nom),
          _LigneInfo('Prénom', client.prenom),
          _LigneTelephone(client.telephone),
          _LigneInfo('Sexe', client.sexe),
          _LigneInfo('Date de prise des mesures', Formatters.dateLongue(client.datePriseMesures)),
        ],
      ),
    );
  }
}

/// Dernières mesures connues pour le gabarit du sexe du client — la même
/// liste que celle pré-remplie en prise de mesure, affichée ici en lecture
/// seule (nom du champ à gauche, valeur à droite), comme dans l'ancienne
/// application.
class _SectionMesures extends ConsumerWidget {
  const _SectionMesures({required this.clientId, required this.sexe});

  final String clientId;
  final String sexe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final utilisateur = ref.watch(utilisateurCourantProvider).valueOrNull;
    final types = ref.watch(typesTenueVisiblesProvider);

    return types.when(
      loading: () => const _Carte(child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const _Carte(child: Text('Impossible de charger les mesures.')),
      data: (liste) {
        if (utilisateur == null) {
          return const _Carte(child: Center(child: CircularProgressIndicator()));
        }
        final gabarit = choisirGabaritPourSexe(liste, utilisateur.atelierId, sexe);
        if (gabarit == null) {
          return const _Carte(
            child: Text(
              'Connectez-vous à internet une première fois pour récupérer les champs de mesure.',
            ),
          );
        }

        final champs = ref.watch(champsActifsProvider(gabarit.id));
        return champs.when(
          loading: () => const _Carte(child: Center(child: CircularProgressIndicator())),
          error: (_, __) => const _Carte(child: Text('Impossible de charger les mesures.')),
          data: (champsListe) => FutureBuilder<Map<String, String>?>(
            future: ref.read(mesuresRepositoryProvider).dernieresValeurs(clientId, gabarit.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const _Carte(child: Center(child: CircularProgressIndicator()));
              }
              final valeurs = snapshot.data;
              final lignes = <MapEntry<String, String>>[
                for (final champ in champsListe)
                  if (valeurs?[champ.id] != null) MapEntry(champ.nom, valeurs![champ.id]!),
              ];
              if (lignes.isEmpty) {
                return const _Carte(child: Text('Aucune mesure enregistrée pour ce client.'));
              }
              return _Carte(
                child: Column(
                  children: [for (final ligne in lignes) _LigneInfo(ligne.key, ligne.value)],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

PhotoClient? _premierDuType(List<PhotoClient> liste, TypePhoto type) {
  for (final photo in liste) {
    if (photo.type == type) return photo;
  }
  return null;
}

/// Dernières photos (tissu et modèle) du client, affichées directement.
class _SectionPhotos extends ConsumerWidget {
  const _SectionPhotos({required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photosDuClientProvider(clientId));

    return photos.when(
      loading: () => const _Carte(child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const _Carte(child: Text('Impossible de charger les photos.')),
      data: (liste) {
        final tissu = _premierDuType(liste, TypePhoto.tissu);
        final modele = _premierDuType(liste, TypePhoto.modele);
        if (tissu == null && modele == null) {
          return const _Carte(child: Text('Aucune photo pour ce client.'));
        }
        return Row(
          children: [
            if (tissu != null)
              Expanded(child: _VignettePhoto(titre: 'Tissu', url: tissu.url)),
            if (tissu != null && modele != null) const SizedBox(width: 16),
            if (modele != null)
              Expanded(child: _VignettePhoto(titre: 'Modèle', url: modele.url)),
          ],
        );
      },
    );
  }
}

class _VignettePhoto extends StatelessWidget {
  const _VignettePhoto({required this.titre, required this.url});

  final String titre;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titre, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => ouvrirPhotoPleinEcran(context, url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(url, fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }
}

RendezVous? _prochainRendezVous(List<RendezVous> tous, String clientId) {
  final maintenant = DateTime.now();
  for (final rdv in tous) {
    if (rdv.clientId == clientId &&
        rdv.statut != AppConstants.rdvAnnule &&
        rdv.dateHeure.isAfter(maintenant)) {
      return rdv;
    }
  }
  return null;
}

/// Prochain rendez-vous à venir du client (la liste est déjà triée par
/// date croissante — le premier qui correspond est donc le plus proche).
class _SectionRendezVous extends ConsumerWidget {
  const _SectionRendezVous({required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tous = ref.watch(rendezVousTriesProvider);

    return tous.when(
      loading: () => const _Carte(child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const _Carte(child: Text('Impossible de charger les rendez-vous.')),
      data: (liste) {
        final prochain = _prochainRendezVous(liste, clientId);
        if (prochain == null) {
          return const _Carte(child: Text('Aucun rendez-vous programmé.'));
        }
        return _Carte(
          child: Row(
            children: [
              const Icon(Icons.event_available_outlined, color: Color(0xFFA47B1B)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  Formatters.rendezVousComplet(prochain.dateHeure),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
