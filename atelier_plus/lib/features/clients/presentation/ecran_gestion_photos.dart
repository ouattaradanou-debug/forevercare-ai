import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/ecran_photo_plein_ecran.dart';
import '../../../data/models/photo_client.dart';
import '../../../shared/widgets/selecteur_source_image.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/photos_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);

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
      final utilisateur = await utilisateurCourantRequis(ref);
      await ref.read(photosRepositoryProvider).ajouterPhoto(
            atelierId: utilisateur.atelierId,
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
    final typeOngletCourant = _ongletsCtrl.index == 0 ? TypePhoto.tissu : TypePhoto.modele;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _ongletsCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: _orangeSeda,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          tabs: const [Tab(text: 'Tissus'), Tab(text: 'Modèles')],
        ),
      ),
      body: TabBarView(
        controller: _ongletsCtrl,
        children: [
          _GrillePhotos(clientId: widget.clientId, type: TypePhoto.tissu, peutSupprimer: true),
          _GrillePhotos(clientId: widget.clientId, type: TypePhoto.modele, peutSupprimer: true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _orangeSeda,
        onPressed: _envoiEnCours ? null : () => _ajouter(typeOngletCourant),
        child: _envoiEnCours
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }
}

class _GrillePhotos extends ConsumerWidget {
  const _GrillePhotos({required this.clientId, required this.type, required this.peutSupprimer});

  final String clientId;
  final TypePhoto type;
  final bool peutSupprimer;

  Future<void> _confirmerSuppression(BuildContext context, WidgetRef ref, PhotoClient photo) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette photo ?'),
        content: const Text('Cette action est définitive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: _bleuSeda),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB3261E)),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    try {
      await ref.read(photosRepositoryProvider).supprimerPhoto(photo);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

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
        return Column(
          children: [
            if (peutSupprimer)
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Text(
                  'Appui long sur une photo pour la supprimer',
                  style: TextStyle(color: Color(0xFF6F6259), fontSize: 13),
                ),
              ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: liste.length,
                itemBuilder: (context, index) {
                  final photo = liste[index];
                  return GestureDetector(
                    onTap: () => ouvrirPhotoPleinEcran(
                      context,
                      photo.url,
                      cheminLocal: photo.cheminLocalEnAttente,
                    ),
                    onLongPress: peutSupprimer
                        ? () => _confirmerSuppression(context, ref, photo)
                        : null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (photo.enAttenteEnvoi)
                            Image.file(File(photo.cheminLocalEnAttente!), fit: BoxFit.cover)
                          else
                            CachedNetworkImage(
                              imageUrl: photo.url,
                              fit: BoxFit.cover,
                              fadeInDuration: Duration.zero,
                              placeholder: (context, url) =>
                                  Container(color: const Color(0xFFEDEAE4)),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFFEDEAE4),
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: Color(0xFF6F6259),
                                ),
                              ),
                            ),
                          // Photo ajoutée hors-ligne, pas encore envoyée —
                          // voir GrillePhotosSection pour le même indicateur.
                          if (photo.enAttenteEnvoi)
                            Positioned(
                              bottom: 4,
                              left: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_off, size: 11, color: Colors.white),
                                    SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        'En attente',
                                        style: TextStyle(fontSize: 9, color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
