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

/// Catalogue d'articles suivis en stock, filtrable par catégorie, avec
/// alerte visuelle sous le seuil défini et actions de réapprovisionnement.
class EcranGestionStock extends ConsumerStatefulWidget {
  const EcranGestionStock({super.key});

  @override
  ConsumerState<EcranGestionStock> createState() => _EcranGestionStockState();
}

class _EcranGestionStockState extends ConsumerState<EcranGestionStock> {
  CategorieVente? _filtre;

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
    final resultat = await showModalBottomSheet<_FormulaireArticleResultat>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FeuilleFormulaireArticle(categorieInitiale: _filtre),
    );
    if (resultat == null) return;

    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (!mounted) return;
    try {
      await ref.read(articlesRepositoryProvider).ajouterArticle(
            atelierId: utilisateur!.atelierId,
            categorie: resultat.categorie,
            nom: resultat.nom,
            prixUnitaireDefaut: resultat.prixUnitaireDefaut,
            quantiteInitiale: resultat.quantite,
            seuilAlerte: resultat.seuilAlerte,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _ouvrirActions(Article article) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_box_outlined, color: _bleuSeda),
              title: const Text('Réapprovisionner'),
              onTap: () => Navigator.pop(context, 'reapprovisionner'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: _bleuSeda),
              title: const Text('Modifier l\'article'),
              onTap: () => Navigator.pop(context, 'modifier'),
            ),
          ],
        ),
      ),
    );

    if (action == 'reapprovisionner') {
      await _reapprovisionner(article);
    } else if (action == 'modifier') {
      await _modifier(article);
    }
  }

  Future<void> _reapprovisionner(Article article) async {
    final quantiteCtrl = TextEditingController();
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Réapprovisionner « ${article.nom} »'),
        content: TextField(
          controller: quantiteCtrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Quantité ajoutée (${article.categorie.uniteLabel})',
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
    final resultat = await showModalBottomSheet<_FormulaireArticleResultat>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FeuilleFormulaireArticle(articleExistant: article),
    );
    if (resultat == null) return;

    try {
      await ref.read(articlesRepositoryProvider).modifierArticle(
            article: article,
            nom: resultat.nom,
            prixUnitaireDefaut: resultat.prixUnitaireDefaut,
            seuilAlerte: resultat.seuilAlerte,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final articles = ref.watch(articlesDeLAtelierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion du stock'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<CategorieVente?>(
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: _bleuSeda,
                    selectedForegroundColor: Colors.white,
                    foregroundColor: _bleuSeda,
                  ),
                  segments: [
                    const ButtonSegment(value: null, label: Text('Toutes')),
                    for (final c in CategorieVente.values)
                      ButtonSegment(value: c, label: Text(c.libelle)),
                  ],
                  selected: {_filtre},
                  onSelectionChanged: (selection) => setState(() => _filtre = selection.first),
                ),
              ),
            ),
            Expanded(
              child: articles.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
                data: (liste) {
                  final filtrees = _filtre == null
                      ? liste
                      : liste.where((a) => a.categorie == _filtre).toList();

                  if (filtrees.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Aucun article dans le catalogue pour le moment.'),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filtrees.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final article = filtrees[index];
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        elevation: 1,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _ouvrirActions(article),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      article.stockBas ? _rougeAlerte : const Color(0xFFDCEADF),
                                  child: Icon(
                                    article.stockBas
                                        ? Icons.warning_amber_outlined
                                        : Icons.inventory_2_outlined,
                                    color: article.stockBas ? Colors.white : const Color(0xFF2E7D32),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.nom,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        '${article.categorie.libelle} · ${Formatters.montant(article.prixUnitaireDefaut)} / ${article.categorie.uniteLabel}',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF6F6259)),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${Formatters.nombre(article.quantiteStock)} ${article.categorie.uniteLabel}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: article.stockBas ? _rougeAlerte : _bleuSeda,
                                      ),
                                    ),
                                    if (article.stockBas)
                                      const Text(
                                        'Stock bas',
                                        style: TextStyle(fontSize: 11, color: _rougeAlerte),
                                      ),
                                  ],
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _orangeSeda,
        onPressed: _ajouterArticle,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _FormulaireArticleResultat {
  const _FormulaireArticleResultat({
    required this.categorie,
    required this.nom,
    required this.prixUnitaireDefaut,
    required this.quantite,
    required this.seuilAlerte,
  });

  final CategorieVente categorie;
  final String nom;
  final double prixUnitaireDefaut;
  final double quantite;
  final double seuilAlerte;
}

/// Formulaire d'ajout (quantité initiale demandée) ou de modification
/// (nom/prix/seuil uniquement, le stock se gère via "Réapprovisionner").
class _FeuilleFormulaireArticle extends StatefulWidget {
  const _FeuilleFormulaireArticle({this.categorieInitiale, this.articleExistant});

  final CategorieVente? categorieInitiale;
  final Article? articleExistant;

  @override
  State<_FeuilleFormulaireArticle> createState() => _FeuilleFormulaireArticleState();
}

class _FeuilleFormulaireArticleState extends State<_FeuilleFormulaireArticle> {
  late CategorieVente _categorie;
  late final TextEditingController _nomCtrl;
  late final TextEditingController _prixCtrl;
  late final TextEditingController _quantiteCtrl;
  late final TextEditingController _seuilCtrl;

  bool get _modification => widget.articleExistant != null;

  @override
  void initState() {
    super.initState();
    final article = widget.articleExistant;
    _categorie = article?.categorie ?? widget.categorieInitiale ?? CategorieVente.pretAPorter;
    _nomCtrl = TextEditingController(text: article?.nom ?? '');
    _prixCtrl = TextEditingController(
      text: article == null ? '' : article.prixUnitaireDefaut.toStringAsFixed(0),
    );
    _quantiteCtrl = TextEditingController(text: '0');
    _seuilCtrl = TextEditingController(
      text: (article?.seuilAlerte ?? 3).toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prixCtrl.dispose();
    _quantiteCtrl.dispose();
    _seuilCtrl.dispose();
    super.dispose();
  }

  void _valider() {
    final nom = _nomCtrl.text.trim();
    if (nom.isEmpty) return;
    final prix = double.tryParse(_prixCtrl.text.replaceAll(',', '.')) ?? 0;
    final quantite = double.tryParse(_quantiteCtrl.text.replaceAll(',', '.')) ?? 0;
    final seuil = double.tryParse(_seuilCtrl.text.replaceAll(',', '.')) ?? 3;

    Navigator.pop(
      context,
      _FormulaireArticleResultat(
        categorie: _categorie,
        nom: nom,
        prixUnitaireDefaut: prix,
        quantite: quantite,
        seuilAlerte: seuil,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _modification ? 'Modifier l\'article' : 'Nouvel article',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _bleuSeda),
            ),
            const SizedBox(height: 16),
            if (!_modification) ...[
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<CategorieVente>(
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: _bleuSeda,
                    selectedForegroundColor: Colors.white,
                    foregroundColor: _bleuSeda,
                  ),
                  segments: [
                    for (final c in CategorieVente.values)
                      ButtonSegment(value: c, label: Text(c.libelle)),
                  ],
                  selected: {_categorie},
                  onSelectionChanged: (selection) => setState(() => _categorie = selection.first),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _nomCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Nom de l\'article',
                hintText: _categorie.exempleDesignation,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _prixCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Prix par ${_categorie.uniteLabel} (FCFA)',
              ),
            ),
            const SizedBox(height: 16),
            if (!_modification)
              TextField(
                controller: _quantiteCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Quantité initiale en stock (${_categorie.uniteLabel})',
                ),
              ),
            if (!_modification) const SizedBox(height: 16),
            TextField(
              controller: _seuilCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Seuil d\'alerte stock bas',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _valider,
              style: ElevatedButton.styleFrom(
                backgroundColor: _orangeSeda,
                foregroundColor: Colors.white,
              ),
              child: Text(_modification ? 'Enregistrer' : 'Ajouter au catalogue'),
            ),
          ],
        ),
      ),
    );
  }
}
