import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/champ_mesure.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Permet au tailleur (ou à un apprenti autorisé, voir
/// `PermissionsApprenti.modifierGabarits`) de masquer un champ de mesure
/// par défaut qui ne le concerne pas, ou d'en ajouter un personnalisé qui
/// ne figure pas dans la liste fournie par Atelier+.
///
/// Le gabarit par défaut n'est jamais modifié directement (RLS, voir
/// schema.sql) : au premier changement pour un sexe donné, ce widget
/// déclenche la copie propre à l'atelier via
/// `GabaritRepository.assurerGabaritPersonnalise`, puis agit sur cette
/// copie pour tous les changements suivants.
class GestionChampsMesurePage extends ConsumerStatefulWidget {
  const GestionChampsMesurePage({super.key});

  @override
  ConsumerState<GestionChampsMesurePage> createState() =>
      _GestionChampsMesurePageState();
}

class _GestionChampsMesurePageState
    extends ConsumerState<GestionChampsMesurePage> {
  String _sexe = 'Homme';
  String? _atelierIdResolu;
  String? _typeTenueId;
  bool _enChargement = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resoudreGabarit();
  }

  Future<void> _resoudreGabarit() async {
    final String? atelierId = ref.read(atelierCourantProvider).asData?.value?.id;
    if (atelierId == null ||
        (atelierId == _atelierIdResolu && _typeTenueId != null)) {
      return;
    }
    setState(() => _enChargement = true);
    final String typeTenueId = await ref
        .read(gabaritRepositoryProvider)
        .assurerGabaritPersonnalise(sexe: _sexe, atelierId: atelierId);
    if (!mounted) return;
    setState(() {
      _atelierIdResolu = atelierId;
      _typeTenueId = typeTenueId;
      _enChargement = false;
    });
  }

  void _changerSexe(String sexe) {
    if (sexe == _sexe) return;
    setState(() {
      _sexe = sexe;
      _typeTenueId = null;
    });
    _resoudreGabarit();
  }

  Future<void> _basculerStatut(ChampMesure champ) async {
    await ref
        .read(gabaritRepositoryProvider)
        .definirStatutChamp(champId: champ.id, actif: !champ.estActif);
  }

  Future<void> _ouvrirDialogueAjout() async {
    final String? typeTenueId = _typeTenueId;
    if (typeTenueId == null) return;

    final TextEditingController nomCtrl = TextEditingController();
    final TextEditingController uniteCtrl = TextEditingController(text: 'cm');

    final bool? confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un champ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nom du champ'),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: uniteCtrl,
              decoration: const InputDecoration(labelText: 'Unité (optionnel)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (confirme != true || nomCtrl.text.trim().isEmpty) return;

    await ref.read(gabaritRepositoryProvider).ajouterChamp(
          typeTenueId: typeTenueId,
          nom: nomCtrl.text.trim(),
          unite: uniteCtrl.text.trim().isEmpty ? null : uniteCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Champs de mesure')),
      floatingActionButton: _typeTenueId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _ouvrirDialogueAjout,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un champ'),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Homme', label: Text('Homme')),
                ButtonSegment(value: 'Femme', label: Text('Femme')),
              ],
              selected: {_sexe},
              onSelectionChanged: (selection) => _changerSexe(selection.first),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: Text(
              'Désactive les champs qui ne concernent pas ton atelier, ou '
              'ajoute-en un qui ne figure pas dans la liste.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Expanded(
            child: _enChargement || _typeTenueId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<ChampMesure>>(
                    stream: ref
                        .read(gabaritRepositoryProvider)
                        .observerTousLesChamps(_typeTenueId!),
                    builder: (context, snapshot) {
                      final List<ChampMesure> champs = snapshot.data ?? const [];
                      if (champs.isEmpty) {
                        return const Center(child: Text('Aucun champ.'));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.l,
                          0,
                          AppSpacing.l,
                          AppSpacing.xxl,
                        ),
                        itemCount: champs.length,
                        itemBuilder: (context, index) {
                          final ChampMesure champ = champs[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.s),
                            child: SwitchListTile(
                              title: Text(
                                champ.unite != null
                                    ? '${champ.nom} (${champ.unite})'
                                    : champ.nom,
                              ),
                              value: champ.estActif,
                              onChanged: (_) => _basculerStatut(champ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
