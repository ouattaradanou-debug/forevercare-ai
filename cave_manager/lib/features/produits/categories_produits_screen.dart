import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/produits/produits_providers.dart';

/// Gestion des catégories de boissons (Bières, Vins rouges, ...) : ajout,
/// masquage (visible/invisible) et suppression — réservée à
/// Propriétaire/Propriétaire-Gérant/Gérant (`estResponsable`), comme le
/// reste de la gestion du catalogue.
class CategoriesProduitsScreen extends ConsumerWidget {
  const CategoriesProduitsScreen({super.key, required this.caveId});

  final String caveId;

  Future<void> _ajouterCategorie(BuildContext context, WidgetRef ref) async {
    final nomCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle catégorie'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nomCtrl,
            decoration: const InputDecoration(labelText: 'Nom de la catégorie'),
            autofocus: true,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    final categories = ref.read(categoriesProduitsProvider).valueOrNull ?? [];
    final ordreSuivant = categories.isEmpty
        ? 0
        : categories.map((c) => c.ordre).reduce((a, b) => a > b ? a : b) + 1;

    try {
      await ref.read(produitsServiceProvider).creerCategorie(
            caveId: caveId,
            nom: nomCtrl.text.trim(),
            ordre: ordreSuivant,
          );
      ref.invalidate(categoriesProduitsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  Future<void> _supprimerCategorie(
      BuildContext context, WidgetRef ref, String categorieId, String nom) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la catégorie ?'),
        content: Text(
            '"$nom" sera définitivement supprimée. Impossible si des produits y sont encore rattachés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    try {
      await ref.read(produitsServiceProvider).supprimerCategorie(categorieId);
      ref.invalidate(categoriesProduitsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e'.replaceFirst('Exception: ', ''))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProduitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catégories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _ajouterCategorie(context, ref),
        tooltip: 'Nouvelle catégorie',
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Impossible de charger : $e')),
          data: (categories) => ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final categorie = categories[index];
              return ListTile(
                title: Text(categorie.nom),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: categorie.visible,
                      onChanged: (v) async {
                        try {
                          await ref
                              .read(produitsServiceProvider)
                              .modifierVisibiliteCategorie(
                                  categorieId: categorie.id, visible: v);
                          ref.invalidate(categoriesProduitsProvider);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur : $e')));
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Supprimer',
                      onPressed: () => _supprimerCategorie(
                          context, ref, categorie.id, categorie.nom),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
