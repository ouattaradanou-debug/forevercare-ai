import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/groupe_uniforme.dart';
import '../../../../shared/widgets/selecteur_sexe.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../clients/presentation/widgets/section_mesures.dart';
import '../providers/uniformes_providers.dart';

/// Ajout d'un membre à un groupe d'uniformes : identité (nom, prénom,
/// sexe) et mesures, sur un seul écran continu — comme pour un client
/// classique (voir FormulaireClientPage/SectionInfosClient) : les champs
/// de mesure se déroulent automatiquement dès que le sexe est choisi,
/// sans avoir à passer par un second écran.
class AjouterMembrePage extends ConsumerStatefulWidget {
  const AjouterMembrePage({super.key, required this.groupe});

  final GroupeUniforme groupe;

  @override
  ConsumerState<AjouterMembrePage> createState() => _AjouterMembrePageState();
}

class _AjouterMembrePageState extends ConsumerState<AjouterMembrePage> {
  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _prenomCtrl = TextEditingController();
  String? _sexe;
  String? _typeTenueId;
  Map<String, String> _valeursMesures = {};
  bool _enregistrementEnCours = false;
  bool _erreurSexe = false;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    super.dispose();
  }

  /// Résout automatiquement le gabarit de mesures (Homme ou Femme) dès
  /// que le sexe est choisi — même mécanisme que pour un client, voir
  /// GabaritRepository.resoudreTypeTenue.
  Future<void> _resoudreTypeTenue(String sexe) async {
    final String? atelierId = ref.read(atelierCourantProvider).asData?.value?.id;
    if (atelierId == null) return;
    final String? typeTenueId = await ref
        .read(gabaritRepositoryProvider)
        .resoudreTypeTenue(sexe: sexe, atelierId: atelierId);
    if (mounted) setState(() => _typeTenueId = typeTenueId);
  }

  void _onSexeChange(String? valeur) {
    setState(() {
      _sexe = valeur;
      _erreurSexe = false;
      _typeTenueId = null;
      _valeursMesures = {};
    });
    if (valeur != null) _resoudreTypeTenue(valeur);
  }

  void _onValeurMesureChange(String nomChamp, String valeur) {
    setState(() => _valeursMesures[nomChamp] = valeur);
  }

  Future<void> _enregistrer() async {
    // Le sexe est indispensable pour savoir quel gabarit de mesures
    // afficher (Homme ou Femme).
    if (_sexe == null) {
      setState(() => _erreurSexe = true);
      return;
    }

    final String? utilisateurId = ref.read(idUtilisateurConnecteProvider);
    if (utilisateurId == null) return;

    setState(() => _enregistrementEnCours = true);
    try {
      final membre = await ref
          .read(uniformeRepositoryProvider)
          .ajouterMembre(
            groupeId: widget.groupe.id,
            nom: _texteOuNull(_nomCtrl.text),
            prenom: _texteOuNull(_prenomCtrl.text),
            sexe: _sexe,
          );

      final bool aDesValeurs = _valeursMesures.values.any(
        (v) => v.trim().isNotEmpty,
      );
      if (_typeTenueId != null && aDesValeurs) {
        await ref
            .read(uniformeRepositoryProvider)
            .enregistrerMesuresMembre(
              membreId: membre.id,
              typeTenueId: _typeTenueId!,
              valeursMesures: Map.of(_valeursMesures),
              prisePar: utilisateurId,
            );
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible d'ajouter le membre : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _enregistrementEnCours = false);
    }
  }

  String? _texteOuNull(String v) => v.trim().isEmpty ? null : v.trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un membre')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.xxl,
        ),
        children: [
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
          Text('Sexe', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.s),
          SelecteurSexe(sexe: _sexe, onChange: _onSexeChange),
          if (_erreurSexe) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              'Choisis le sexe du membre : les champs de mesure Homme ou '
              'Femme en dépendent.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_sexe != null) ...[
            const SizedBox(height: AppSpacing.xl),
            SectionMesures(
              sexe: _sexe,
              typeTenueId: _typeTenueId,
              valeursMesures: _valeursMesures,
              onValeurChange: _onValeurMesureChange,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: _enregistrementEnCours ? null : _enregistrer,
            child: _enregistrementEnCours
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Text('Enregistrer le membre'),
          ),
        ],
      ),
    );
  }
}
