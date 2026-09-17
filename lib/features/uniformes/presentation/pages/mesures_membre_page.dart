import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/groupe_uniforme.dart';
import '../../../../data/models/membre_groupe_uniforme.dart';
import '../../../../data/models/mesure_uniforme.dart';
import '../../../../shared/widgets/selecteur_sexe.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../clients/presentation/widgets/indicateur_sauvegarde.dart';
import '../../../clients/presentation/widgets/section_mesures.dart';
import '../providers/uniformes_providers.dart';

/// Fiche complète d'un membre de groupe d'uniformes : identité (auto-
/// enregistrée), sexe, "couture terminée" (auto-enregistrée), et prise ou
/// consultation/modification de ses mesures. Réutilise SectionMesures
/// telle quelle (même gabarit Homme/Femme que pour un client) : seule la
/// destination de l'enregistrement diffère (UniformeRepository, table
/// `mesures_uniforme`, séparée de `mesures`).
///
/// Chaque enregistrement DE MESURES crée une nouvelle prise historisée
/// (comme pour un client) : contrairement à l'identité et à "couture
/// terminée" (simples attributs, auto-enregistrés), les mesures ne
/// s'auto-enregistrent pas à chaque frappe — resterait sinon un
/// enregistrement conservé pour de bon à chaque appui explicite.
class MesuresMembrePage extends ConsumerStatefulWidget {
  const MesuresMembrePage({
    super.key,
    required this.groupe,
    required this.membre,
  });

  final GroupeUniforme groupe;
  final MembreGroupeUniforme membre;

  @override
  ConsumerState<MesuresMembrePage> createState() => _MesuresMembrePageState();
}

class _MesuresMembrePageState extends ConsumerState<MesuresMembrePage> {
  late MembreGroupeUniforme _membre;
  late final TextEditingController _nomCtrl;
  late final TextEditingController _prenomCtrl;
  bool _chargement = true;
  String? _typeTenueId;
  Map<String, String> _valeursMesures = {};
  bool _enregistrementEnCours = false;

  Timer? _debounceIdentite;
  Timer? _timerIndicateur;
  bool _indicateurVisible = false;

  @override
  void initState() {
    super.initState();
    _membre = widget.membre;
    _nomCtrl = TextEditingController(text: _membre.nom ?? '');
    _prenomCtrl = TextEditingController(text: _membre.prenom ?? '');
    _nomCtrl.addListener(_programmerSauvegardeIdentite);
    _prenomCtrl.addListener(_programmerSauvegardeIdentite);
    WidgetsBinding.instance.addPostFrameCallback((_) => _charger());
  }

  @override
  void dispose() {
    _debounceIdentite?.cancel();
    _timerIndicateur?.cancel();
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    final String? sexe = _membre.sexe;
    if (sexe == null) {
      if (mounted) setState(() => _chargement = false);
      return;
    }

    final String? atelierId = ref.read(atelierCourantProvider).asData?.value?.id;
    if (atelierId == null) return;

    final String? typeTenueId = await ref
        .read(gabaritRepositoryProvider)
        .resoudreTypeTenue(sexe: sexe, atelierId: atelierId);

    final List<MesureUniforme> historique = await ref
        .read(uniformeRepositoryProvider)
        .observerMesuresMembre(_membre.id)
        .first;
    final MesureUniforme? derniere = historique.isEmpty
        ? null
        : historique.first;

    if (!mounted) return;
    setState(() {
      _typeTenueId = typeTenueId;
      _valeursMesures = derniere != null ? Map.of(derniere.valeurs) : {};
      _chargement = false;
    });
  }

  void _programmerSauvegardeIdentite() {
    _debounceIdentite?.cancel();
    _debounceIdentite = Timer(
      const Duration(seconds: 1),
      _sauvegarderIdentite,
    );
  }

  Future<void> _sauvegarderIdentite() async {
    final MembreGroupeUniforme misAJour = await ref
        .read(uniformeRepositoryProvider)
        .actualiserMembre(
          membre: _membre,
          nom: _texteOuNull(_nomCtrl.text),
          prenom: _texteOuNull(_prenomCtrl.text),
          sexe: _membre.sexe,
        );
    if (!mounted) return;
    setState(() => _membre = misAJour);
    _timerIndicateur?.cancel();
    setState(() => _indicateurVisible = true);
    _timerIndicateur = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _indicateurVisible = false);
    });
  }

  String? _texteOuNull(String v) => v.trim().isEmpty ? null : v.trim();

  Future<void> _choisirSexe(String? sexe) async {
    if (sexe == null) return;
    // Annule une éventuelle sauvegarde du nom/prénom déjà programmée pour
    // éviter d'écraser une saisie toute récente avec l'ancienne valeur de
    // `_membre` (voir _sauvegarderIdentite) : ce qui est déjà à l'écran
    // dans les champs fait foi.
    _debounceIdentite?.cancel();
    setState(() => _chargement = true);
    final MembreGroupeUniforme misAJour = await ref
        .read(uniformeRepositoryProvider)
        .actualiserMembre(
          membre: _membre,
          nom: _texteOuNull(_nomCtrl.text),
          prenom: _texteOuNull(_prenomCtrl.text),
          sexe: sexe,
        );
    if (!mounted) return;
    setState(() => _membre = misAJour);
    await _charger();
  }

  Future<void> _definirTenueTerminee(bool? terminee) async {
    await ref
        .read(uniformeRepositoryProvider)
        .definirTenueTerminee(membre: _membre, terminee: terminee ?? false);
    if (!mounted) return;
    setState(
      () => _membre = MembreGroupeUniforme(
        id: _membre.id,
        groupeId: _membre.groupeId,
        nom: _membre.nom,
        prenom: _membre.prenom,
        sexe: _membre.sexe,
        tenueTerminee: terminee ?? false,
        createdAt: _membre.createdAt,
        updatedAt: DateTime.now(),
        synced: false,
      ),
    );
  }

  void _onValeurChange(String nomChamp, String valeur) {
    setState(() => _valeursMesures[nomChamp] = valeur);
  }

  Future<void> _enregistrer() async {
    final String? typeTenueId = _typeTenueId;
    final String? utilisateurId = ref.read(idUtilisateurConnecteProvider);
    if (typeTenueId == null || utilisateurId == null) return;

    setState(() => _enregistrementEnCours = true);
    try {
      await ref
          .read(uniformeRepositoryProvider)
          .enregistrerMesuresMembre(
            membreId: _membre.id,
            typeTenueId: typeTenueId,
            valeursMesures: Map.of(_valeursMesures),
            prisePar: utilisateurId,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mesures enregistrées.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible d'enregistrer les mesures : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _enregistrementEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mesures de ${_membre.nomComplet}')),
      body: _chargement
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.xxl,
              ),
              children: [
                IndicateurSauvegarde(visible: _indicateurVisible),
                const SizedBox(height: AppSpacing.s),
                TextFormField(
                  controller: _nomCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                const SizedBox(height: AppSpacing.m),
                TextFormField(
                  controller: _prenomCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                ),
                const SizedBox(height: AppSpacing.m),
                if (_membre.sexe == null) ...[
                  Text(
                    'Sexe',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  SelecteurSexe(sexe: _membre.sexe, onChange: _choisirSexe),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'Choisis le sexe du membre pour afficher les champs de '
                    'mesure correspondants.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ] else ...[
                  SectionMesures(
                    sexe: _membre.sexe,
                    typeTenueId: _typeTenueId,
                    valeursMesures: _valeursMesures,
                    onValeurChange: _onValeurChange,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Container(
                    decoration: BoxDecoration(
                      color: _membre.tenueTerminee
                          ? AppColors.vertClair
                          : null,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.champ),
                    ),
                    child: CheckboxListTile(
                      value: _membre.tenueTerminee,
                      onChanged: _definirTenueTerminee,
                      title: Text(
                        'Couture terminée',
                        style: _membre.tenueTerminee
                            ? const TextStyle(
                                color: AppColors.anthracite900,
                                fontWeight: FontWeight.w600,
                              )
                            : null,
                      ),
                      subtitle: Text(
                        'La tenue de ce membre est confectionnée',
                        style: TextStyle(
                          color: _membre.tenueTerminee
                              ? AppColors.anthracite900.withValues(alpha: 0.75)
                              : null,
                        ),
                      ),
                      checkColor: Colors.white,
                      activeColor: AppColors.vertFonce,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ElevatedButton(
                    onPressed: _enregistrementEnCours ? null : _enregistrer,
                    child: _enregistrementEnCours
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text('Enregistrer les mesures'),
                  ),
                ],
              ],
            ),
    );
  }
}
