import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/champ_mesure.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'section_titre.dart';

/// Section "Mesures" : formulaire dynamique généré à partir du gabarit de
/// mesures du sexe du client — plus de choix de "type de tenue" (correctif
/// : un seul gabarit par sexe, résolu automatiquement par la page parente
/// dès que le sexe est renseigné, voir `GabaritRepository.resoudreTypeTenue`
/// et `_FormulaireClientPageState._resoudreTypeTenue`). Aucun champ n'est
/// obligatoire.
///
/// Widget à état pour mettre en cache le flux Drift des champs du gabarit
/// et ne le recréer que lorsque `typeTenueId` change réellement — la page
/// parente se reconstruit à chaque interaction (photo ajoutée, date
/// choisie...), ce qui recréerait sinon inutilement ce flux à chaque fois.
class SectionMesures extends ConsumerStatefulWidget {
  const SectionMesures({
    super.key,
    required this.sexe,
    required this.typeTenueId,
    required this.valeursMesures,
    required this.onValeurChange,
  });

  final String? sexe;
  final String? typeTenueId;
  final Map<String, String> valeursMesures;
  final void Function(String nomChamp, String valeur) onValeurChange;

  @override
  ConsumerState<SectionMesures> createState() => _SectionMesuresState();
}

class _SectionMesuresState extends ConsumerState<SectionMesures> {
  Stream<List<ChampMesure>>? _fluxChamps;

  // Détection manuelle de l'appui long (au lieu de GestureDetector.onLongPress)
  // : un TextFormField a son propre reconnaisseur d'appui long intégré (pour
  // la sélection de texte), qui gagne systématiquement l'arbitrage de gestes
  // face à celui d'un GestureDetector englobant — l'appui long ne
  // déclenchait donc jamais la suppression. Écouter les évènements de
  // pointeur bruts (hors arbitrage de gestes) contourne ce conflit.
  Timer? _minuteurAppuiLong;
  Offset? _positionDepartAppui;

  @override
  void initState() {
    super.initState();
    _reconstruireFluxChamps();
  }

  @override
  void didUpdateWidget(covariant SectionMesures oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.typeTenueId != widget.typeTenueId) {
      _reconstruireFluxChamps();
    }
  }

  @override
  void dispose() {
    _minuteurAppuiLong?.cancel();
    super.dispose();
  }

  void _demarrerAppuiLong(ChampMesure champ, PointerDownEvent evenement) {
    _minuteurAppuiLong?.cancel();
    _positionDepartAppui = evenement.position;
    _minuteurAppuiLong = Timer(const Duration(milliseconds: 450), () {
      _minuteurAppuiLong = null;
      _supprimerChamp(champ);
    });
  }

  void _suivreDeplacementAppui(PointerMoveEvent evenement) {
    final Offset? depart = _positionDepartAppui;
    if (depart == null) return;
    if ((evenement.position - depart).distance > 20) {
      _annulerAppuiLong();
    }
  }

  void _annulerAppuiLong([PointerEvent? evenement]) {
    _minuteurAppuiLong?.cancel();
    _minuteurAppuiLong = null;
    _positionDepartAppui = null;
  }

  void _reconstruireFluxChamps() {
    final String? typeTenueId = widget.typeTenueId;
    _fluxChamps = typeTenueId == null
        ? null
        : ref.read(gabaritRepositoryProvider).observerChampsActifs(typeTenueId);
  }

  /// Supprime (masque) un champ de mesure depuis un appui long — même
  /// action que la case à décocher dans GestionChampsMesurePage, mais
  /// accessible directement depuis le formulaire de mesures.
  Future<void> _supprimerChamp(ChampMesure champ) async {
    final bool? confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce champ ?'),
        content: Text(
          '"${champ.nom}" ne sera plus proposé, ni pour les clients ni '
          "pour les groupes d'uniformes. Tu pourras le rajouter plus tard "
          'depuis "Champs de mesure".',
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

    final String? sexe = widget.sexe;
    final String? atelierId = ref.read(atelierCourantProvider).asData?.value?.id;
    if (sexe == null || atelierId == null) return;

    await ref
        .read(gabaritRepositoryProvider)
        .masquerChampParNom(sexe: sexe, atelierId: atelierId, nom: champ.nom);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitre(
          icone: Icons.straighten,
          titre: 'Mesures',
          couleur: AppColors.terracotta600,
        ),
        const SizedBox(height: AppSpacing.m),
        if (widget.sexe == null)
          Text(
            'Renseigne le sexe du client ci-dessus pour afficher les champs '
            'de mesure.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else if (_fluxChamps == null)
          const SizedBox.shrink()
        else
          StreamBuilder<List<ChampMesure>>(
            stream: _fluxChamps,
            builder: (context, snapshot) {
              final List<ChampMesure> champs = snapshot.data ?? const [];
              if (champs.isEmpty) return const SizedBox.shrink();
              return Column(
                children: [
                  for (final ChampMesure c in champs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.m),
                      child: Listener(
                        onPointerDown: (e) => _demarrerAppuiLong(c, e),
                        onPointerUp: _annulerAppuiLong,
                        onPointerMove: _suivreDeplacementAppui,
                        onPointerCancel: _annulerAppuiLong,
                        child: TextFormField(
                          key: ValueKey(c.id),
                          initialValue: widget.valeursMesures[c.nom],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'),
                            ),
                          ],
                          decoration: InputDecoration(
                            labelText: c.unite != null
                                ? '${c.nom} (${c.unite})'
                                : c.nom,
                          ),
                          onChanged: (v) => widget.onValeurChange(c.nom, v),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}
