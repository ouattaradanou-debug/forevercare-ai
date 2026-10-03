import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/uniformes_providers.dart';

/// Groupes de mesures d'uniformes (promotion, établissement, équipe) :
/// permet de prendre les mesures de plusieurs personnes à la fois, en
/// dehors des fiches clients individuelles.
class EcranGroupesUniformes extends ConsumerStatefulWidget {
  const EcranGroupesUniformes({super.key});

  @override
  ConsumerState<EcranGroupesUniformes> createState() => _EcranGroupesUniformesState();
}

class _EcranGroupesUniformesState extends ConsumerState<EcranGroupesUniformes> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      if (utilisateur != null) {
        await ref.read(groupesUniformesRepositoryProvider).chargerDepuisServeur(utilisateur.atelierId);
      }
    });
  }

  Future<void> _creerGroupe() async {
    final nomCtrl = TextEditingController();
    final repondantNomCtrl = TextEditingController();
    final repondantTelCtrl = TextEditingController();
    final resultat = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nouveau groupe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nom du groupe',
                  hintText: 'Ex. : Promotion 2026, Équipe commerciale...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: repondantNomCtrl,
                decoration: const InputDecoration(labelText: 'Nom du répondant (optionnel)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: repondantTelCtrl,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'Téléphone du répondant (optionnel)'),
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
            child: const Text('Créer'),
          ),
        ],
      ),
    );
    if (resultat != true || nomCtrl.text.trim().isEmpty || !mounted) return;

    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (utilisateur == null) return;
    await ref.read(groupesUniformesRepositoryProvider).creerGroupe(
          atelierId: utilisateur.atelierId,
          nom: nomCtrl.text.trim(),
          repondantNom: repondantNomCtrl.text.trim().isEmpty ? null : repondantNomCtrl.text.trim(),
          repondantTelephone:
              repondantTelCtrl.text.trim().isEmpty ? null : repondantTelCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final groupes = ref.watch(groupesUniformesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mesures des uniformes')),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 90),
              child: groupes.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Impossible de charger les groupes.')),
                data: (liste) => liste.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun groupe pour l\'instant. Crée un groupe pour une '
                          'promotion, un établissement ou une équipe qui commande '
                          'des uniformes.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        itemCount: liste.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final groupe = liste[index];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.groups_outlined),
                              title: Text(groupe.nom),
                              subtitle: groupe.repondantNom == null
                                  ? null
                                  : Text('Répondant : ${groupe.repondantNom}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push(AppRoutes.detailGroupeUniforme(groupe.id)),
                            ),
                          );
                        },
                      ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: FilledButton.icon(
                onPressed: _creerGroupe,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF141B3E),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Nouveau groupe'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
