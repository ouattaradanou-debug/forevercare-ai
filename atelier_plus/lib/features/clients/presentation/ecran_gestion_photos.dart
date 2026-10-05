import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/ecran_photo_plein_ecran.dart';
import '../../../data/models/photo_client.dart';
import '../../../shared/widgets/selecteur_source_image.dart';
import '../../auth/providers/auth_providers.dart';
import '../../permissions/providers/permissions_providers.dart';
import '../providers/photos_providers.dart';

/// Photos de tissus et de modèles d'un client. Choix explicite caméra ou
/// galerie à chaque ajout (voir `choisirSourceEtImage`), jamais de valeur
/// par défaut implicite.
class EcranGestionPhotos extends ConsumerStatefulWidget {
  const EcranGestionPhotos({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<EcranGestionPhotos> createState() => _EcranGestionPhotosState();
}

class _EcranGestionPhotosState extends ConsumerState<EcranGestionPhotos>
    with SingleTickerProviderStateMixin {
  late final TabController _ongletsCtrl;
  bool _envoiEnCours = false;

  @override
  void initState() {
    super.initState();
    _ongletsCtrl = TabController(length: 2, vsync: this)..addListener(() => setState(() {}));
    Future.microtask(
      () => ref.read(photosRepositoryProvider).chargerDepuisServeur(widget.clientId),
    );
  }

  @override
  void dispose() {
    _ongletsCtrl.dispose();
    super.dispose();
  }

  Future<void> _ajouter(TypePhoto type) async {
    final resultat = await choisirSourceEtImage(context);
    if (resultat == null) return;
    final (fichier, sourceImage) = resultat;

    setState(() => _envoiEnCours = true);
    try {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      await ref.read(photosRepositoryProvider).ajouterPhoto(
            atelierId: utilisateur!.atelierId,
            clientId: widget.clientId,
            type: type,
            source: sourceImage == ImageSource.camera ? SourcePhoto.camera : SourcePhoto.galerie,
            fichier: fichier,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'envoi : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(mesPermissionsProvider);
    final estProprietaire = ref.watch(estProprietaireProvider);
    final peutAjouter = estProprietaire || (permissions.valueOrNull?.ajouterPhotos ?? false);

    final typeOngletCourant = _ongletsCtrl.index == 0 ? TypePhoto.tissu : TypePhoto.modele;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
        bottom: TabBar(
          controller: _ongletsCtrl,
          tabs: const [Tab(text: 'Tissus'), Tab(text: 'Modèles')],
        ),
      ),
      body: TabBarView(
        controller: _ongletsCtrl,
        children: [
          _GrillePhotos(clientId: widget.clientId, type: TypePhoto.tissu),
          _GrillePhotos(clientId: widget.clientId, type: TypePhoto.modele),
        ],
      ),
      floatingActionButton: peutAjouter
          ? FloatingActionButton(
              onPressed: _envoiEnCours ? null : () => _ajouter(typeOngletCourant),
              child: _envoiEnCours
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add_a_photo),
            )
          : null,
    );
  }
}

class _GrillePhotos extends ConsumerWidget {
  const _GrillePhotos({required this.clientId, required this.type});

  final String clientId;
  final TypePhoto type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photosDuClientProvider(clientId));

    return photos.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
      data: (toutes) {
        final liste = toutes.where((p) => p.type == type).toList();
        if (liste.isEmpty) {
          return const Center(child: Text('Aucune photo pour le moment.'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: liste.length,
          itemBuilder: (context, index) {
            final url = liste[index].url;
            return GestureDetector(
              onTap: () => ouvrirPhotoPleinEcran(context, url),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(url, fit: BoxFit.cover),
              ),
            );
          },
        );
      },
    );
  }
}
