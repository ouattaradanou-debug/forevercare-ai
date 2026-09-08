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

  void _reconstruireFluxChamps() {
    final String? typeTenueId = widget.typeTenueId;
    _fluxChamps = typeTenueId == null
        ? null
        : ref.read(gabaritRepositoryProvider).observerChampsActifs(typeTenueId);
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
                ],
              );
            },
          ),
      ],
    );
  }
}
