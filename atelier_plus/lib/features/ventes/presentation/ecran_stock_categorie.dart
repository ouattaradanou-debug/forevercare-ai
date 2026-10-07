import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/article.dart';
import '../../../data/models/categorie_vente.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/ventes_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);
const _rougeAlerte = Color(0xFFB3261E);

/// Seuil d'alerte par défaut (nombre de pièces ou de mètres restants) :
/// fixé une fois pour toutes plutôt que demandé à la création, pour éviter
/// un champ supplémentaire peu clair à un tailleur peu à l'aise à l'écrit.
const double _seuilAlerteParDefaut = 3;

/// Stock d'une seule catégorie : liste simple (nom, prix, quantité restante)
/// avec un gros bouton "+" directement visible sur chaque article pour
/// recevoir une nouvelle livraison — pas de menu caché à faire apparaître
/// en appui long. Toucher le reste de la carte permet de corriger le nom
/// ou le prix.
class EcranStockCategorie extends ConsumerStatefulWidget {
  const EcranStockCategorie({super.key, required this.categorie});

  final CategorieVente categorie;

  @override
  ConsumerState<EcranStockCategorie> createState() => _EcranStockCategorieState();
}

class _EcranStockCategorieState extends ConsumerState<EcranStockCategorie> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final atelier = await ref.read(atelierCourantProvider.future);
      if (atelier != null) {
        await ref.read(articlesRepositoryProvider).chargerDepuisServeur(atelier.id);
      }
    });
  }

  Future<void> _ajouterArticle() async {
    final nomCtrl = TextEditingController();
    final prixCtrl = TextEditingController();
    final quantiteCtrl = TextEditingController();

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvel article', style: TextStyle(color: _bleuSeda)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Nom de l\'article',
                hintText: widget.categorie.exempleDesignation,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: prixCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Prix par ${widget.categorie.uniteLabel} (FCFA)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantiteCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Quantité en stock (${widget.categorie.uniteLabel})',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: _bleuSeda),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: _orangeSeda),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    final nom = nomCtrl.text.trim();
    if (nom.isEmpty) return;
    final prix = double.tryParse(prixCtrl.text.replaceAll(',', '.')) ?? 0;
    final quantite = double.tryParse(quantiteCtrl.text.replaceAll(',', '.')) ?? 0;

    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (!mounted) return;
    try {
      await ref.read(articlesRepositoryProvider).ajouterArticle(
            atelierId: utilisateur!.atelierId,
            categorie: widget.categorie,
            nom: nom,
            prixUnitaireDefaut: prix,
            quantiteInitiale: quantite,
            seuilAlerte: _seuilAlerteParDefaut,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _reapprovisionner(Article article) async {
    final quantiteCtrl = TextEditingController();
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouvelle livraison : ${article.nom}', style: const TextStyle(color: _bleuSeda)),
        content: TextField(
          controller: quantiteCtrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Quantité reçue (${article.categorie.uniteLabel})',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: _bleuSeda),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: _orangeSeda),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    final quantite = double.tryParse(quantiteCtrl.text.replaceAll(',', '.')) ?? 0;
    if (quantite <= 0) return;

    try {
      await ref
          .read(articlesRepositoryProvider)
          .reapprovisionner(article: article, quantiteAjoutee: quantite);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _modifier(Article article) async {
    final nomCtrl = TextEditingController(text: article.nom);
    final prixCtrl = TextEditingController(text: article.prixUnitaireDefaut.toStringAsFixed(0));

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'article', style: TextStyle(color: _bleuSeda)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nom de l\'article'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: prixCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Prix par ${article.categorie.uniteLabel} (FCFA)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: _bleuSeda),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: _orangeSeda),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    final nom = nomCtrl.text.trim();
    if (nom.isEmpty) return;
    final prix = double.tryParse(prixCtrl.text.replaceAll(',', '.')) ?? 0;

    try {
      await ref.read(articlesRepositoryProvider).modifierArticle(
            article: article,
            nom: nom,
            prixUnitaireDefaut: prix,
            seuilAlerte: article.seuilAlerte,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorie = widget.categorie;
    final articles = ref.watch(articlesDeLAtelierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Stock de ${categorie.libelle.toLowerCase()}'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: articles.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
          data: (liste) {
            final filtrees = liste.where((a) => a.categorie == categorie).toList();

            if (filtrees.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Aucun article pour le moment.\nAppuyez sur "+" pour en ajouter un.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF6F6259)),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtrees.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final article = filtrees[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  elevation: 1,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _modifier(article),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article.nom,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  Formatters.montant(article.prixUnitaireDefaut),
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF6F6259)),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    if (article.stockBas)
                                      const Padding(
                                        padding: EdgeInsets.only(right: 6),
                                        child: Icon(
                                          Icons.warning_amber_outlined,
                                          color: _rougeAlerte,
                                          size: 18,
                                        ),
                                      ),
                                    Text(
                                      '${Formatters.nombre(article.quantiteStock)} ${article.categorie.uniteLabel} en stock',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: article.stockBas ? _rougeAlerte : _bleuSeda,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _reapprovisionner(article),
                            tooltip: 'Nouvelle livraison',
                            style: IconButton.styleFrom(
                              backgroundColor: _orangeSeda,
                              foregroundColor: Colors.white,
                              shape: const CircleBorder(),
                            ),
                            icon: const Icon(Icons.add, size: 28),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _bleuSeda,
        onPressed: _ajouterArticle,
        tooltip: 'Nouvel article',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
