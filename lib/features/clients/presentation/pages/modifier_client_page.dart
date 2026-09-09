import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../data/models/brouillon_client.dart' show RendezVousBrouillon;
import '../../../../data/models/client.dart';
import '../../../../data/models/mesure.dart';
import '../../../../shared/widgets/selecteur_photo.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/clients_providers.dart';
import '../widgets/section_infos_client.dart';
import '../widgets/section_mesures.dart';
import '../widgets/section_photos.dart';
import '../widgets/section_rendez_vous.dart';

/// Actualisation d'une fiche client déjà enregistrée : identité, nouvelle
/// prise de mesures (les précédentes restent conservées dans l'historique,
/// voir ClientRepository.actualiserClient), nouvelles photos, nouveaux
/// rendez-vous. Contrairement au formulaire de création, il n'y a pas de
/// brouillon ni de règle de finalisation : la fiche existe déjà.
class ModifierClientPage extends ConsumerStatefulWidget {
  const ModifierClientPage({super.key, required this.client});

  final Client client;

  @override
  ConsumerState<ModifierClientPage> createState() =>
      _ModifierClientPageState();
}

class _ModifierClientPageState extends ConsumerState<ModifierClientPage> {
  late final TextEditingController _nomCtrl = TextEditingController(
    text: widget.client.nom ?? '',
  );
  late final TextEditingController _prenomCtrl = TextEditingController(
    text: widget.client.prenom ?? '',
  );
  late final TextEditingController _telephoneCtrl = TextEditingController(
    text: widget.client.telephone ?? '',
  );

  late String? _sexe = widget.client.sexe;
  late DateTime? _datePriseMesures = widget.client.datePriseMesures;
  String? _typeTenueId;
  Map<String, String> _valeursMesures = {};
  final List<String> _nouvellesPhotosTissu = [];
  final List<String> _nouvellesPhotosModele = [];
  List<RendezVousBrouillon> _nouveauxRendezVous = [];

  bool _chargementInitial = true;
  bool _enregistrementEnCours = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialiser());
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _telephoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _initialiser() async {
    // Pré-remplit avec les dernières valeurs connues : la tailleuse ou le
    // tailleur n'a alors qu'à corriger ce qui a changé plutôt que tout
    // ressaisir. Une nouvelle prise de mesure reste créée à
    // l'enregistrement (historique conservé), jamais une modification de
    // l'ancienne.
    final List<Mesure> mesures = await ref
        .read(clientRepositoryProvider)
        .observerMesuresClient(widget.client.id)
        .first;
    if (mesures.isNotEmpty && mounted) {
      setState(() => _valeursMesures = Map.of(mesures.first.valeurs));
    }
    await _resoudreTypeTenue();
    if (mounted) setState(() => _chargementInitial = false);
  }

  String? _texteOuNull(String v) => v.trim().isEmpty ? null : v.trim();

  void _onSexeChange(String? valeur) {
    setState(() => _sexe = valeur);
    _resoudreTypeTenue();
  }

  void _onDateChange(DateTime? valeur) => setState(() => _datePriseMesures = valeur);

  Future<void> _resoudreTypeTenue() async {
    final String? sexe = _sexe;
    final String? atelierId = ref.read(atelierCourantProvider).asData?.value?.id;
    if (sexe == null || atelierId == null) {
      if (mounted) setState(() => _typeTenueId = null);
      return;
    }
    final String? typeTenueId = await ref
        .read(gabaritRepositoryProvider)
        .resoudreTypeTenue(sexe: sexe, atelierId: atelierId);
    if (mounted) setState(() => _typeTenueId = typeTenueId);
  }

  void _onValeurMesureChange(String nomChamp, String valeur) {
    _valeursMesures[nomChamp] = valeur;
  }

  void _afficherErreurPhoto() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Accès à la caméra ou à la galerie refusé. Vérifie les "
          "autorisations de l'application dans les paramètres du "
          'téléphone.',
        ),
      ),
    );
  }

  Future<void> _ajouterPhotoTissu() async {
    try {
      final photo = await choisirPhoto(context);
      if (photo == null) return;
      final File fichier = await ImageUtils.compresserEtPersister(File(photo.path));
      setState(() => _nouvellesPhotosTissu.add(fichier.path));
    } catch (_) {
      _afficherErreurPhoto();
    }
  }

  Future<void> _ajouterPhotoModele() async {
    try {
      final photo = await choisirPhoto(context);
      if (photo == null) return;
      final File fichier = await ImageUtils.compresserEtPersister(File(photo.path));
      setState(() => _nouvellesPhotosModele.add(fichier.path));
    } catch (_) {
      _afficherErreurPhoto();
    }
  }

  void _supprimerPhotoTissu(String chemin) =>
      setState(() => _nouvellesPhotosTissu.remove(chemin));

  void _supprimerPhotoModele(String chemin) =>
      setState(() => _nouvellesPhotosModele.remove(chemin));

  void _ajouterRendezVous(DateTime dateHeure) {
    setState(
      () => _nouveauxRendezVous = [
        ..._nouveauxRendezVous,
        RendezVousBrouillon(dateHeure: dateHeure, type: 'essayage'),
      ],
    );
  }

  void _supprimerRendezVous(int index) {
    setState(
      () => _nouveauxRendezVous = [..._nouveauxRendezVous]..removeAt(index),
    );
  }

  Future<void> _enregistrer() async {
    final String? utilisateurId = ref.read(idUtilisateurConnecteProvider);
    if (utilisateurId == null) return;

    setState(() => _enregistrementEnCours = true);
    try {
      await ref
          .read(clientRepositoryProvider)
          .actualiserClient(
            client: widget.client,
            nom: _texteOuNull(_nomCtrl.text),
            prenom: _texteOuNull(_prenomCtrl.text),
            telephone: _texteOuNull(_telephoneCtrl.text),
            sexe: _sexe,
            datePriseMesures: _datePriseMesures,
            typeTenueId: _typeTenueId,
            valeursMesures: Map.of(_valeursMesures),
            utilisateurId: utilisateurId,
            cheminsPhotosTissu: List.of(_nouvellesPhotosTissu),
            cheminsPhotosModele: List.of(_nouvellesPhotosModele),
            rendezVous: List.of(_nouveauxRendezVous),
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible d'enregistrer les modifications : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _enregistrementEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_chargementInitial) {
      return Scaffold(
        appBar: AppBar(title: Text('Modifier ${widget.client.nomComplet}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Modifier ${widget.client.nomComplet}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionInfosClient(
              nomCtrl: _nomCtrl,
              prenomCtrl: _prenomCtrl,
              telephoneCtrl: _telephoneCtrl,
              datePriseMesures: _datePriseMesures,
              onDateChange: _onDateChange,
              sexe: _sexe,
              onSexeChange: _onSexeChange,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Une nouvelle prise de mesure sera enregistrée en plus de '
              "l'historique existant, pas à la place.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.s),
            SectionMesures(
              sexe: _sexe,
              typeTenueId: _typeTenueId,
              valeursMesures: _valeursMesures,
              onValeurChange: _onValeurMesureChange,
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionPhotos(
              titre: 'Ajouter des photos du tissu',
              icone: Icons.texture_outlined,
              couleur: AppColors.or600,
              chemins: _nouvellesPhotosTissu,
              onAjouter: _ajouterPhotoTissu,
              onSupprimer: _supprimerPhotoTissu,
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionPhotos(
              titre: 'Ajouter des photos du ou des modèles',
              icone: Icons.checkroom_outlined,
              couleur: AppColors.succes,
              chemins: _nouvellesPhotosModele,
              onAjouter: _ajouterPhotoModele,
              onSupprimer: _supprimerPhotoModele,
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionRendezVous(
              rendezVous: _nouveauxRendezVous,
              onAjouter: _ajouterRendezVous,
              onSupprimer: _supprimerRendezVous,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.s,
            AppSpacing.l,
            AppSpacing.s,
          ),
          child: ElevatedButton(
            onPressed: _enregistrementEnCours ? null : _enregistrer,
            child: _enregistrementEnCours
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Text('Enregistrer les modifications'),
          ),
        ),
      ),
    );
  }
}
