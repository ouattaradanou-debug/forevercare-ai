import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../data/models/brouillon_client.dart';
import '../../../../data/models/utilisateur.dart';
import '../../../../shared/widgets/selecteur_photo.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../permissions/presentation/providers/apprentis_providers.dart';
import '../providers/clients_providers.dart';
import '../widgets/indicateur_sauvegarde.dart';
import '../widgets/section_infos_client.dart';
import '../widgets/section_mesures.dart';
import '../widgets/section_photos.dart';

/// Formulaire continu de création client : toutes les sections sont
/// empilées dans une seule page scrollable, sans étape bloquante, sans
/// champ obligatoire. Sauvegarde automatique en brouillon local (debounce
/// ~1s), reprise du brouillon existant à l'ouverture, et règle de
/// finalisation assouplie (un message doux plutôt qu'un blocage quand
/// aucune mesure n'est encore renseignée).
class FormulaireClientPage extends ConsumerStatefulWidget {
  const FormulaireClientPage({super.key});

  @override
  ConsumerState<FormulaireClientPage> createState() =>
      _FormulaireClientPageState();
}

class _FormulaireClientPageState extends ConsumerState<FormulaireClientPage>
    with WidgetsBindingObserver {
  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _prenomCtrl = TextEditingController();
  final TextEditingController _telephoneCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final GlobalKey _mesuresKey = GlobalKey();

  String? _sexe;
  DateTime? _datePriseMesures;
  String? _typeTenueId;
  Map<String, String> _valeursMesures = {};
  List<String> _photosTissu = [];
  List<String> _photosModele = [];

  Timer? _debounce;
  Timer? _timerIndicateur;
  bool _indicateurVisible = false;
  bool _brouillonCharge = false;
  bool _enregistrementEnCours = false;
  String? _erreurChargement;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _nomCtrl.addListener(_programmerSauvegarde);
    _prenomCtrl.addListener(_programmerSauvegarde);
    _telephoneCtrl.addListener(_programmerSauvegarde);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerBrouillonExistant();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _timerIndicateur?.cancel();
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _telephoneCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _sauvegarderMaintenant();
    }
  }

  Future<void> _chargerBrouillonExistant() async {
    try {
      await _chargerBrouillonExistantInterne();
    } catch (e) {
      if (mounted) {
        setState(() {
          _erreurChargement = '$e';
          _brouillonCharge = true;
        });
      }
    }
  }

  Future<void> _chargerBrouillonExistantInterne() async {
    final String? utilisateurId = ref.read(idUtilisateurConnecteProvider);
    if (utilisateurId == null) {
      setState(() => _brouillonCharge = true);
      return;
    }

    final BrouillonClient? brouillon = await ref
        .read(brouillonRepositoryProvider)
        .recuperer(utilisateurId);

    if (!mounted) return;

    if (brouillon == null || brouillon.estCompletementVide) {
      setState(() => _brouillonCharge = true);
      return;
    }

    final String? choix = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Reprendre ce brouillon ?'),
        content: Text(
          'Une fiche "${brouillon.nom ?? brouillon.prenom ?? "Client sans nom"}" '
          "est en cours de saisie. Veux-tu la reprendre là où tu l'as "
          'laissée ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('nouveau'),
            child: const Text('Nouveau formulaire'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop('reprendre'),
            child: const Text('Reprendre'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (choix == 'nouveau') {
      await ref.read(brouillonRepositoryProvider).supprimer(utilisateurId);
      setState(() => _brouillonCharge = true);
      return;
    }

    setState(() {
      _nomCtrl.text = brouillon.nom ?? '';
      _prenomCtrl.text = brouillon.prenom ?? '';
      _telephoneCtrl.text = brouillon.telephone ?? '';
      _sexe = brouillon.sexe;
      _datePriseMesures = brouillon.datePriseMesures;
      _typeTenueId = brouillon.typeTenueId;
      _valeursMesures = Map.of(brouillon.valeursMesures);
      _photosTissu = List.of(brouillon.photosTissu);
      _photosModele = List.of(brouillon.photosModele);
      _brouillonCharge = true;
    });
  }

  String? _texteOuNull(String v) => v.trim().isEmpty ? null : v.trim();

  void _programmerSauvegarde() {
    if (!_brouillonCharge) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), _sauvegarderMaintenant);
  }

  Future<void> _sauvegarderMaintenant() async {
    _debounce?.cancel();
    if (!_brouillonCharge) return;

    final String? utilisateurId = ref.read(idUtilisateurConnecteProvider);
    final String? atelierId = ref.read(atelierCourantProvider).asData?.value?.id;
    if (utilisateurId == null || atelierId == null) return;

    final BrouillonClient brouillon = BrouillonClient(
      utilisateurId: utilisateurId,
      atelierId: atelierId,
      nom: _texteOuNull(_nomCtrl.text),
      prenom: _texteOuNull(_prenomCtrl.text),
      telephone: _texteOuNull(_telephoneCtrl.text),
      sexe: _sexe,
      datePriseMesures: _datePriseMesures,
      typeTenueId: _typeTenueId,
      valeursMesures: Map.of(_valeursMesures),
      photosTissu: List.of(_photosTissu),
      photosModele: List.of(_photosModele),
      misAJourLe: DateTime.now(),
    );
    await ref.read(brouillonRepositoryProvider).enregistrer(brouillon);

    if (!mounted) return;
    _timerIndicateur?.cancel();
    setState(() => _indicateurVisible = true);
    _timerIndicateur = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _indicateurVisible = false);
    });
  }

  void _onSexeChange(String? valeur) {
    setState(() => _sexe = valeur);
    _programmerSauvegarde();
  }

  void _onDateChange(DateTime? valeur) {
    setState(() => _datePriseMesures = valeur);
    _programmerSauvegarde();
  }

  void _onTypeTenueChange(String? valeur) {
    setState(() => _typeTenueId = valeur);
    _programmerSauvegarde();
  }

  void _onValeurMesureChange(String nomChamp, String valeur) {
    _valeursMesures[nomChamp] = valeur;
    _programmerSauvegarde();
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
      final File fichier = await ImageUtils.compresserEtPersister(
        File(photo.path),
      );
      setState(() => _photosTissu = [..._photosTissu, fichier.path]);
      _programmerSauvegarde();
    } catch (_) {
      _afficherErreurPhoto();
    }
  }

  Future<void> _ajouterPhotoModele() async {
    try {
      final photo = await choisirPhoto(context);
      if (photo == null) return;
      final File fichier = await ImageUtils.compresserEtPersister(
        File(photo.path),
      );
      setState(() => _photosModele = [..._photosModele, fichier.path]);
      _programmerSauvegarde();
    } catch (_) {
      _afficherErreurPhoto();
    }
  }

  void _supprimerPhotoTissu(String chemin) {
    setState(
      () => _photosTissu = _photosTissu.where((c) => c != chemin).toList(),
    );
    _programmerSauvegarde();
  }

  void _supprimerPhotoModele(String chemin) {
    setState(
      () => _photosModele = _photosModele.where((c) => c != chemin).toList(),
    );
    _programmerSauvegarde();
  }

  bool get _aAuMoinsUneMesure =>
      _typeTenueId != null &&
      _valeursMesures.values.any((v) => v.trim().isNotEmpty);

  Future<void> _enregistrerClient() async {
    await _sauvegarderMaintenant();
    if (!mounted) return;

    if (!_aAuMoinsUneMesure) {
      final String? choix = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Aucune mesure enregistrée'),
          content: const Text(
            "Ce client n'a pas encore de mesure enregistrée. Veux-tu "
            'continuer à le compléter plus tard, ou ajouter une mesure '
            'maintenant ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('brouillon'),
              child: const Text('Enregistrer comme brouillon'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop('mesure'),
              child: const Text('Ajouter une mesure maintenant'),
            ),
          ],
        ),
      );

      if (choix == 'mesure') {
        final ctxCible = _mesuresKey.currentContext;
        if (ctxCible != null) {
          await Scrollable.ensureVisible(
            ctxCible,
            duration: const Duration(milliseconds: 400),
          );
        }
        return;
      }

      // 'brouillon' (ou dialogue fermé) : le brouillon est déjà à jour.
      if (mounted) context.pop();
      return;
    }

    final String? utilisateurId = ref.read(idUtilisateurConnecteProvider);
    final String? atelierId = ref.read(atelierCourantProvider).asData?.value?.id;
    if (utilisateurId == null || atelierId == null) return;

    setState(() => _enregistrementEnCours = true);
    try {
      await ref
          .read(clientRepositoryProvider)
          .finaliserClient(
            atelierId: atelierId,
            utilisateurId: utilisateurId,
            nom: _texteOuNull(_nomCtrl.text),
            prenom: _texteOuNull(_prenomCtrl.text),
            telephone: _texteOuNull(_telephoneCtrl.text),
            sexe: _sexe,
            datePriseMesures: _datePriseMesures,
            typeTenueId: _typeTenueId!,
            valeursMesures: Map.of(_valeursMesures),
            cheminsPhotosTissu: List.of(_photosTissu),
            cheminsPhotosModele: List.of(_photosModele),
          );
      await ref.read(brouillonRepositoryProvider).supprimer(utilisateurId);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'enregistrer le client : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _enregistrementEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Utilisateur? utilisateur = ref
        .watch(utilisateurCourantProvider)
        .asData
        ?.value;
    final String? atelierId = ref
        .watch(atelierCourantProvider)
        .asData
        ?.value
        ?.id;

    if (utilisateur != null && !utilisateur.estProprietaire) {
      final permissions = ref
          .watch(permissionsApprentiProvider(utilisateur.id))
          .asData
          ?.value;
      if (permissions == null || !permissions.creerClient) {
        return Scaffold(
          appBar: AppBar(title: const Text('Nouveau client')),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.l),
              child: Text(
                "Tu n'as pas la permission de créer un client. Demande à "
                'la personne responsable de ton atelier de l\'activer.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }
    }

    if (_erreurChargement != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nouveau client')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Impossible de charger le brouillon : $_erreurChargement",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.m),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _erreurChargement = null;
                      _brouillonCharge = false;
                    });
                    _chargerBrouillonExistant();
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (atelierId == null || !_brouillonCharge) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau client')),
      body: SingleChildScrollView(
        controller: _scrollCtrl,
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
            KeyedSubtree(
              key: _mesuresKey,
              child: SectionMesures(
                atelierId: atelierId,
                sexe: _sexe,
                typeTenueId: _typeTenueId,
                onTypeTenueChange: _onTypeTenueChange,
                valeursMesures: _valeursMesures,
                onValeurChange: _onValeurMesureChange,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionPhotos(
              titre: 'Photos du tissu',
              icone: Icons.texture_outlined,
              couleur: AppColors.or600,
              chemins: _photosTissu,
              onAjouter: _ajouterPhotoTissu,
              onSupprimer: _supprimerPhotoTissu,
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionPhotos(
              titre: 'Photos du ou des modèles',
              icone: Icons.checkroom_outlined,
              couleur: AppColors.succes,
              chemins: _photosModele,
              onAjouter: _ajouterPhotoModele,
              onSupprimer: _supprimerPhotoModele,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IndicateurSauvegarde(visible: _indicateurVisible),
              const SizedBox(height: AppSpacing.s),
              ElevatedButton(
                onPressed: _enregistrementEnCours ? null : _enregistrerClient,
                child: _enregistrementEnCours
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Text('Enregistrer le client'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
