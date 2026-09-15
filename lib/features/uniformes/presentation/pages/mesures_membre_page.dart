import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/groupe_uniforme.dart';
import '../../../../data/models/membre_groupe_uniforme.dart';
import '../../../../data/models/mesure_uniforme.dart';
import '../../../../shared/widgets/selecteur_sexe.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../clients/presentation/widgets/section_mesures.dart';
import '../providers/uniformes_providers.dart';

/// Prise (ou consultation/modification) des mesures d'un membre de groupe
/// d'uniformes. Réutilise SectionMesures telle quelle (même gabarit
/// Homme/Femme que pour un client) : seule la destination de
/// l'enregistrement diffère (UniformeRepository, table `mesures_uniforme`,
/// séparée de `mesures`).
///
/// Chaque enregistrement crée une nouvelle prise historisée (comme pour un
/// client) : "modifier les mesures" d'un membre ajoute donc une nouvelle
/// ligne plutôt que d'écraser la précédente, pré-remplie avec les dernières
/// valeurs connues pour ne resaisir que ce qui change.
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
  bool _chargement = true;
  String? _typeTenueId;
  Map<String, String> _valeursMesures = {};
  bool _enregistrementEnCours = false;

  @override
  void initState() {
    super.initState();
    _membre = widget.membre;
    WidgetsBinding.instance.addPostFrameCallback((_) => _charger());
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

  Future<void> _choisirSexe(String? sexe) async {
    if (sexe == null) return;
    setState(() => _chargement = true);
    final MembreGroupeUniforme misAJour = await ref
        .read(uniformeRepositoryProvider)
        .definirSexeMembre(membre: _membre, sexe: sexe);
    if (!mounted) return;
    setState(() => _membre = misAJour);
    await _charger();
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
