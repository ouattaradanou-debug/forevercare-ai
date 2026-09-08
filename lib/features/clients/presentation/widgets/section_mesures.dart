import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/champ_mesure.dart';
import '../../../../data/models/type_tenue.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'section_titre.dart';

/// Section "Mesures" : sélection du type de tenue puis formulaire
/// dynamique généré à partir du gabarit correspondant. Aucun champ n'est
/// obligatoire.
///
/// Widget à état pour mettre en cache les flux Drift (types de tenue,
/// champs du gabarit sélectionné) et ne les recréer que lorsque `sexe` ou
/// `typeTenueId` changent réellement — la page parente se reconstruit à
/// chaque interaction (photo ajoutée, date choisie...), ce qui recréerait
/// sinon inutilement ces flux à chaque fois.
class SectionMesures extends ConsumerStatefulWidget {
  const SectionMesures({
    super.key,
    required this.atelierId,
    required this.sexe,
    required this.typeTenueId,
    required this.onTypeTenueChange,
    required this.valeursMesures,
    required this.onValeurChange,
  });

  final String atelierId;
  final String? sexe;
  final String? typeTenueId;
  final ValueChanged<String?> onTypeTenueChange;
  final Map<String, String> valeursMesures;
  final void Function(String nomChamp, String valeur) onValeurChange;

  @override
  ConsumerState<SectionMesures> createState() => _SectionMesuresState();
}

class _SectionMesuresState extends ConsumerState<SectionMesures> {
  Stream<List<TypeTenue>>? _fluxTypes;
  Stream<List<ChampMesure>>? _fluxChamps;

  @override
  void initState() {
    super.initState();
    _reconstruireFluxTypes();
    _reconstruireFluxChamps();
  }

  @override
  void didUpdateWidget(covariant SectionMesures oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sexe != widget.sexe ||
        oldWidget.atelierId != widget.atelierId) {
      _reconstruireFluxTypes();
    }
    if (oldWidget.typeTenueId != widget.typeTenueId) {
      _reconstruireFluxChamps();
    }
  }

  void _reconstruireFluxTypes() {
    final String? sexe = widget.sexe;
    _fluxTypes = sexe == null
        ? null
        : ref
              .read(gabaritRepositoryProvider)
              .observerTypesTenue(sexe: sexe, atelierId: widget.atelierId);
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
        if (_fluxTypes == null)
          Text(
            'Renseigne le sexe du client ci-dessus pour choisir un type de '
            'tenue.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          StreamBuilder<List<TypeTenue>>(
            stream: _fluxTypes,
            builder: (context, snapshot) {
              final List<TypeTenue> types = snapshot.data ?? const [];
              return InputDecorator(
                decoration: const InputDecoration(labelText: 'Type de tenue'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: types.any((t) => t.id == widget.typeTenueId)
                        ? widget.typeTenueId
                        : null,
                    isExpanded: true,
                    hint: const Text('Choisir un type de tenue'),
                    items: [
                      for (final TypeTenue t in types)
                        DropdownMenuItem(value: t.id, child: Text(t.nom)),
                    ],
                    onChanged: widget.onTypeTenueChange,
                  ),
                ),
              );
            },
          ),
        if (_fluxChamps != null) ...[
          const SizedBox(height: AppSpacing.m),
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
      ],
    );
  }
}
