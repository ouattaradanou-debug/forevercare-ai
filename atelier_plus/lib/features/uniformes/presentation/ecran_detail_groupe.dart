import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../data/models/membre_groupe_uniforme.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/uniformes_providers.dart';

/// Détail d'un groupe d'uniformes : informations du répondant, liste des
/// membres (avec leur statut "tenue terminée"), et ajout de nouveaux
/// membres. Chaque membre mène à la prise de ses mesures.
class EcranDetailGroupe extends ConsumerStatefulWidget {
  const EcranDetailGroupe({super.key, required this.groupeId});

  final String groupeId;

  @override
  ConsumerState<EcranDetailGroupe> createState() => _EcranDetailGroupeState();
}

class _EcranDetailGroupeState extends ConsumerState<EcranDetailGroupe> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(membresGroupeUniformeRepositoryProvider).chargerDepuisServeur(widget.groupeId);
    });
  }

  Future<void> _ajouterMembre() async {
    final nomCtrl = TextEditingController();
    final prenomCtrl = TextEditingController();
    String? sexe;

    final resultat = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Nouveau membre'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: prenomCtrl,
                  decoration: const InputDecoration(labelText: 'Prénom (optionnel)'),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Homme', label: Text('Homme')),
                    ButtonSegment(value: 'Femme', label: Text('Femme')),
                  ],
                  selected: sexe == null ? {} : {sexe!},
                  emptySelectionAllowed: true,
                  onSelectionChanged: (selection) =>
                      setDialogState(() => sexe = selection.isEmpty ? null : selection.first),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
    if (resultat != true || !mounted) return;
    if (nomCtrl.text.trim().isEmpty && prenomCtrl.text.trim().isEmpty) return;

    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (utilisateur == null) return;
    await ref.read(membresGroupeUniformeRepositoryProvider).ajouterMembre(
          atelierId: utilisateur.atelierId,
          groupeId: widget.groupeId,
          nom: nomCtrl.text.trim().isEmpty ? null : nomCtrl.text.trim(),
          prenom: prenomCtrl.text.trim().isEmpty ? null : prenomCtrl.text.trim(),
          sexe: sexe,
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

  @override
  Widget build(BuildContext context) {
    final groupe = ref.watch(groupeUniformeParIdProvider(widget.groupeId));
    final membres = ref.watch(membresDuGroupeProvider(widget.groupeId));

    return Scaffold(
      appBar: AppBar(
        title: Text(groupe.valueOrNull?.nom ?? 'Groupe'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  groupe.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (g) {
                      if (g == null || (g.repondantNom == null && g.repondantTelephone == null)) {
                        return const SizedBox.shrink();
                      }
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.contact_phone_outlined),
                          title: Text(g.repondantNom ?? 'Répondant'),
                          subtitle:
                              g.repondantTelephone == null ? null : Text(g.repondantTelephone!),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: membres.when(
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
                          : ListView.separated(
                              itemCount: liste.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final membre = liste[index];
                                return Card(
                                  child: ListTile(
                                    leading: Icon(
                                      membre.sexe == 'Femme' ? Icons.female : Icons.male,
                                    ),
                                    title: Text(membre.nomComplet),
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
                  backgroundColor: const Color(0xFF141B3E),
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
