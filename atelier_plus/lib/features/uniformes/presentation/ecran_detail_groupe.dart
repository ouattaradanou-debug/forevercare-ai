import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/gestion_erreurs.dart';
import '../../../core/utils/telephone.dart';
import '../../../data/models/membre_groupe_uniforme.dart';
import '../../../data/models/photo_client.dart';
import '../../../shared/widgets/grille_photos.dart';
import '../../../shared/widgets/selecteur_source_image.dart';
import '../../auth/providers/auth_providers.dart';
import '../../clients/providers/photos_providers.dart';
import '../../mesures/providers/gabarits_providers.dart';
import '../../mesures/utils/choix_gabarit.dart';
import '../providers/uniformes_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);
const _vertWhatsapp = Color(0xFF25D366);

/// Détail d'un groupe d'uniformes : informations du répondant (en tableau,
/// avec appel/WhatsApp direct), liste des membres (avec leur statut "tenue
/// terminée"), et ajout de nouveaux membres. Chaque membre mène à la prise
/// de ses mesures.
class EcranDetailGroupe extends ConsumerStatefulWidget {
  const EcranDetailGroupe({super.key, required this.groupeId});

  final String groupeId;

  @override
  ConsumerState<EcranDetailGroupe> createState() => _EcranDetailGroupeState();
}

class _EcranDetailGroupeState extends ConsumerState<EcranDetailGroupe> {
  final Map<String, bool> _photoEnCours = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(membresGroupeUniformeRepositoryProvider).chargerDepuisServeur(widget.groupeId);
      await ref.read(photosRepositoryProvider).chargerPhotosGroupeDepuisServeur(widget.groupeId);
    });
  }

  String _cleEnCours(TypePhoto type, String sexe) => '${type.name}_$sexe';

  /// Ajoute une photo de tissu ou de modèle au groupe, séparée par sexe —
  /// même logique que EcranNouveauClient._ajouterPhoto, via le même
  /// PhotosRepository partagé (voir GrillePhotosSection).
  Future<void> _ajouterPhotoGroupe(TypePhoto type, String sexe) async {
    final resultat = await choisirSourceEtImage(context);
    if (resultat == null || !mounted) return;
    final (fichier, sourceImage) = resultat;

    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (utilisateur == null || !mounted) return;

    final cle = _cleEnCours(type, sexe);
    setState(() => _photoEnCours[cle] = true);
    try {
      await ref.read(photosRepositoryProvider).ajouterPhoto(
            atelierId: utilisateur.atelierId,
            groupeId: widget.groupeId,
            sexe: sexe,
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
      if (mounted) setState(() => _photoEnCours[cle] = false);
    }
  }

  Future<void> _ajouterMembre() async {
    final resultat = await showDialog<_ResultatNouveauMembre>(
      context: context,
      builder: (dialogContext) => const _DialogueNouveauMembre(),
    );
    if (resultat == null || !mounted) return;

    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (utilisateur == null || !mounted) return;
    final membre = await ref.read(membresGroupeUniformeRepositoryProvider).ajouterMembre(
          atelierId: utilisateur.atelierId,
          groupeId: widget.groupeId,
          nom: resultat.nom,
          prenom: null,
          sexe: resultat.sexe,
        );
    if (!mounted || resultat.sexe == null) return;

    // Ouvre directement la prise de mesure du gabarit par défaut pour ce
    // sexe (même principe que EcranNouveauClient._idGabaritPourSexe), au
    // lieu de laisser retrouver le membre dans la liste puis choisir
    // manuellement un type de tenue.
    final gabarits = await ref.read(typesTenueVisiblesProvider.future);
    final gabarit = choisirGabaritPourSexe(gabarits, utilisateur.atelierId, resultat.sexe!);
    if (!mounted || gabarit == null) return;
    context.push(
      AppRoutes.priseMesureMembre(membre.id, gabarit.id),
      extra: membre.nomComplet,
    );
  }

  Future<void> _basculerTenueTerminee(MembreGroupeUniforme membre) async {
    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (utilisateur == null) return;
    await ref.read(membresGroupeUniformeRepositoryProvider).basculerTenueTerminee(
          atelierId: utilisateur.atelierId,
          membre: membre,
        );
  }

  Future<void> _appeler(String telephone) => executerAvecErreurAffichee(
        context,
        () => launchUrl(Uri(scheme: 'tel', path: telephone)),
      );

  Future<void> _whatsapp(String telephone) => executerAvecErreurAffichee(
        context,
        () => launchUrl(Uri.parse('https://wa.me/${Telephone.normaliser(telephone)}')),
      );

  @override
  Widget build(BuildContext context) {
    final groupe = ref.watch(groupeUniformeParIdProvider(widget.groupeId));
    final membres = ref.watch(membresDuGroupeProvider(widget.groupeId));
    final photosGroupe = ref.watch(photosDuGroupeProvider(widget.groupeId)).valueOrNull ?? [];
    List<PhotoClient> filtrerPhotos(TypePhoto type, String sexe) =>
        photosGroupe.where((p) => p.type == type && p.sexe == sexe).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(groupe.valueOrNull?.nom ?? 'Groupe'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  groupe.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (g) {
                      if (g == null) {
                        return const SizedBox.shrink();
                      }
                      final telephone = g.repondantTelephone;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: _bleuSeda, width: 2),
                              boxShadow: const [
                                BoxShadow(color: Color(0x1F000000), blurRadius: 10),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  decoration: const BoxDecoration(color: _bleuSeda),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Nom du répondant',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Table(
                                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                  columnWidths: const {1: FixedColumnWidth(84)},
                                  children: [
                                    TableRow(
                                      children: [
                                        _CelluleRepondant(g.repondantNom ?? 'Non renseigné'),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6),
                                            child: telephone == null || telephone.isEmpty
                                                ? const SizedBox.shrink()
                                                : Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      _BoutonContact(
                                                        icone: Icons.call,
                                                        couleur: _bleuSeda,
                                                        tooltip: 'Appeler',
                                                        onTap: () => _appeler(telephone),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      _BoutonContact(
                                                        icone: Icons.chat,
                                                        couleur: _vertWhatsapp,
                                                        tooltip: 'WhatsApp',
                                                        onTap: () => _whatsapp(telephone),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(height: 1, color: Color(0xFFE4E7EE)),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SousTitrePhotos('Tissu'),
                                      LigneSexesPhotos(
                                        photosHomme: filtrerPhotos(TypePhoto.tissu, 'Homme'),
                                        photosFemme: filtrerPhotos(TypePhoto.tissu, 'Femme'),
                                        enCoursHomme: _photoEnCours[
                                                _cleEnCours(TypePhoto.tissu, 'Homme')] ??
                                            false,
                                        enCoursFemme: _photoEnCours[
                                                _cleEnCours(TypePhoto.tissu, 'Femme')] ??
                                            false,
                                        onAjouterHomme: () =>
                                            _ajouterPhotoGroupe(TypePhoto.tissu, 'Homme'),
                                        onAjouterFemme: () =>
                                            _ajouterPhotoGroupe(TypePhoto.tissu, 'Femme'),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1, color: Color(0xFFE4E7EE)),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SousTitrePhotos('Modèle'),
                                      LigneSexesPhotos(
                                        photosHomme: filtrerPhotos(TypePhoto.modele, 'Homme'),
                                        photosFemme: filtrerPhotos(TypePhoto.modele, 'Femme'),
                                        enCoursHomme: _photoEnCours[
                                                _cleEnCours(TypePhoto.modele, 'Homme')] ??
                                            false,
                                        enCoursFemme: _photoEnCours[
                                                _cleEnCours(TypePhoto.modele, 'Femme')] ??
                                            false,
                                        onAjouterHomme: () =>
                                            _ajouterPhotoGroupe(TypePhoto.modele, 'Homme'),
                                        onAjouterFemme: () =>
                                            _ajouterPhotoGroupe(TypePhoto.modele, 'Femme'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  membres.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) =>
                        const Center(child: Text('Impossible de charger les membres.')),
                    data: (liste) => liste.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucun membre pour l\'instant. Ajoutez les personnes '
                              'dont vous allez prendre les mesures.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: _bleuSeda, width: 2),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x1F000000), blurRadius: 10),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(color: _bleuSeda),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Membres du groupe (${liste.length})',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    ListView.separated(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: liste.length,
                                      separatorBuilder: (_, __) => const Divider(
                                        height: 1,
                                        color: Color(0xFFE4E7EE),
                                      ),
                                      itemBuilder: (context, index) {
                                        final membre = liste[index];
                                        return Container(
                                          color: index.isEven
                                              ? Colors.white
                                              : const Color(0xFFF6F3EE),
                                          child: ListTile(
                                            leading: Icon(
                                              membre.sexe == 'Femme'
                                                  ? Icons.female
                                                  : Icons.male,
                                              color: _bleuSeda,
                                            ),
                                            title: Text(
                                              membre.nomComplet,
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                            trailing: IconButton(
                                              tooltip: membre.tenueTerminee
                                                  ? 'Tenue terminée'
                                                  : 'Marquer la tenue comme terminée',
                                              icon: Icon(
                                                membre.tenueTerminee
                                                    ? Icons.check_circle
                                                    : Icons.check_circle_outline,
                                                color: membre.tenueTerminee
                                                    ? const Color(0xFF2E7D32)
                                                    : const Color(0xFF6F6259),
                                              ),
                                              onPressed: () => _basculerTenueTerminee(membre),
                                            ),
                                            onTap: () => context.push(
                                              AppRoutes.selectionTypeTenueMembre(membre.id),
                                              extra: membre.nomComplet,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: FilledButton.icon(
                onPressed: _ajouterMembre,
                style: FilledButton.styleFrom(
                  backgroundColor: _bleuSeda,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('Nouveau membre'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CelluleRepondant extends StatelessWidget {
  const _CelluleRepondant(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Text(
        texte,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF231A14),
          fontSize: 14,
        ),
      ),
    );
  }
}

/// Petit bouton rond coloré pour contacter le répondant — même langage
/// visuel que les autres boutons d'action ronds de l'application.
class _BoutonContact extends StatelessWidget {
  const _BoutonContact({
    required this.icone,
    required this.couleur,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icone;
  final Color couleur;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: couleur,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        minimumSize: const Size(30, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
      ),
      icon: Icon(icone, size: 14),
    );
  }
}

class _ResultatNouveauMembre {
  const _ResultatNouveauMembre({required this.nom, required this.sexe});

  final String nom;
  final String? sexe;
}

/// Formulaire "Nouveau membre" : un seul champ nom + prénom (au lieu de
/// deux cases séparées), avec dictée vocale — pratique pour un tailleur
/// peu à l'aise à l'écrit, comme pour le nom d'un client.
class _DialogueNouveauMembre extends StatefulWidget {
  const _DialogueNouveauMembre();

  @override
  State<_DialogueNouveauMembre> createState() => _DialogueNouveauMembreState();
}

class _DialogueNouveauMembreState extends State<_DialogueNouveauMembre> {
  final _nomCtrl = TextEditingController();
  String? _sexe;
  final _dicteeVocale = stt.SpeechToText();
  bool _dicteeDisponible = false;
  bool _enEcoute = false;

  @override
  void dispose() {
    _dicteeVocale.stop();
    _nomCtrl.dispose();
    super.dispose();
  }

  Future<void> _basculerDictee() async {
    if (_enEcoute) {
      await _dicteeVocale.stop();
      if (mounted) setState(() => _enEcoute = false);
      return;
    }

    if (!_dicteeDisponible) {
      _dicteeDisponible = await _dicteeVocale.initialize(
        onStatus: (statut) {
          if ((statut == 'done' || statut == 'notListening') && mounted) {
            setState(() => _enEcoute = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _enEcoute = false);
        },
      );
      if (!_dicteeDisponible) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dictée vocale indisponible sur cet appareil.')),
          );
        }
        return;
      }
    }

    setState(() => _enEcoute = true);
    await _dicteeVocale.listen(
      localeId: 'fr_FR',
      onResult: (resultat) {
        _nomCtrl.text = resultat.recognizedWords;
        _nomCtrl.selection = TextSelection.collapsed(offset: _nomCtrl.text.length);
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Nouveau membre', style: TextStyle(color: _bleuSeda)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nomCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Nom et prénom',
              prefixIcon: IconButton(
                icon: Icon(_enEcoute ? Icons.mic : Icons.mic_none),
                color: _enEcoute ? Colors.red : _bleuSeda,
                tooltip: 'Dicter le nom',
                onPressed: _basculerDictee,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Homme', label: Text('Homme')),
              ButtonSegment(value: 'Femme', label: Text('Femme')),
            ],
            selected: _sexe == null ? {} : {_sexe!},
            emptySelectionAllowed: true,
            onSelectionChanged: (selection) =>
                setState(() => _sexe = selection.isEmpty ? null : selection.first),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: _bleuSeda),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            final nom = _nomCtrl.text.trim();
            if (nom.isEmpty) return;
            Navigator.of(context).pop(_ResultatNouveauMembre(nom: nom, sexe: _sexe));
          },
          style: FilledButton.styleFrom(backgroundColor: _orangeSeda),
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
