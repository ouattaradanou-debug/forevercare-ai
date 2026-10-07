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
    var uniteChoisie = widget.categorie.uniteLabel;

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
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
              if (widget.categorie.uniteModifiable) ...[
                const SizedBox(height: 12),
                _SelecteurUnite(
                  uniteChoisie: uniteChoisie,
                  onChange: (u) => setStateDialog(() => uniteChoisie = u),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: prixCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Prix par $uniteChoisie (FCFA)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantiteCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Quantité en stock ($uniteChoisie)'),
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
            unite: widget.categorie.uniteModifiable ? uniteChoisie : null,
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
            labelText: 'Quantité reçue (${article.uniteAffichee})',
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
    final quantiteCtrl = TextEditingController(
      text: Formatters.nombre(article.quantiteStock),
    );
    var uniteChoisie = article.uniteAffichee;

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
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
              if (article.categorie.uniteModifiable) ...[
                const SizedBox(height: 12),
                _SelecteurUnite(
                  uniteChoisie: uniteChoisie,
                  onChange: (u) => setStateDialog(() => uniteChoisie = u),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: prixCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Prix par $uniteChoisie (FCFA)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantiteCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Quantité en stock ($uniteChoisie)',
                  helperText: 'À corriger seulement en cas d\'erreur de saisie',
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
      ),
    );
    if (confirme != true) return;

    final nom = nomCtrl.text.trim();
    if (nom.isEmpty) return;
    final prix = double.tryParse(prixCtrl.text.replaceAll(',', '.')) ?? 0;
    final quantite = double.tryParse(quantiteCtrl.text.replaceAll(',', '.')) ?? 0;

    try {
      final repo = ref.read(articlesRepositoryProvider);
      // corrigerStock s'appuie sur le résultat de modifierArticle (pas sur
      // l'article d'origine) : sinon, si les deux ont changé à la fois,
      // la correction de stock écraserait le nouveau nom/prix avec les
      // anciennes valeurs (elle reconstruit l'article complet à partir de
      // celui qu'on lui passe).
      final miseAJour = await repo.modifierArticle(
        article: article,
        nom: nom,
        prixUnitaireDefaut: prix,
        seuilAlerte: article.seuilAlerte,
        unite: article.categorie.uniteModifiable ? uniteChoisie : null,
      );
      if (quantite != article.quantiteStock) {
        await repo.corrigerStock(article: miseAJour, nouvelleQuantite: quantite);
      }
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

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Touchez une ligne pour corriger le nom ou le prix. '
                      'Touchez "+" pour une nouvelle livraison.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6F6259)),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _orangeSeda, width: 2),
                        boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 10)],
                      ),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1.3),
                          1: FixedColumnWidth(78),
                          2: FixedColumnWidth(96),
                          3: FixedColumnWidth(56),
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(color: _bleuSeda),
                            children: const [
                              _Cellule('Article', entete: true),
                              _Cellule('Prix', entete: true, alignDroite: true),
                              _Cellule('Stock', entete: true, alignDroite: true),
                              SizedBox.shrink(),
                            ],
                          ),
                          for (final entree in filtrees.asMap().entries)
                            _ligne(entree.value, entree.key),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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

  TableRow _ligne(Article article, int index) {
    final fondLigne = index.isEven ? Colors.white : const Color(0xFFF6F3EE);
    return TableRow(
      decoration: BoxDecoration(color: fondLigne),
      children: [
        GestureDetector(
          onTap: () => _modifier(article),
          child: _Cellule(article.nom, tronquer: false),
        ),
        GestureDetector(
          onTap: () => _modifier(article),
          child: _Cellule(Formatters.nombre(article.prixUnitaireDefaut), alignDroite: true),
        ),
        GestureDetector(
          onTap: () => _modifier(article),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: _PastilleStock(article: article),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: IconButton(
            onPressed: () => _reapprovisionner(article),
            tooltip: 'Nouvelle livraison',
            style: IconButton.styleFrom(
              backgroundColor: _orangeSeda,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              minimumSize: const Size(36, 36),
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(Icons.add, size: 20),
          ),
        ),
      ],
    );
  }
}

/// Pastille arrondie affichant la quantité restante — verte si le stock est
/// confortable, rouge dès qu'il atteint le seuil d'alerte : plus visible
/// d'un coup d'œil qu'un simple texte coloré.
class _PastilleStock extends StatelessWidget {
  const _PastilleStock({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final bas = article.stockBas;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bas ? const Color(0xFFFBE4E1) : const Color(0xFFDCEADF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${Formatters.nombre(article.quantiteStock)} ${article.uniteAffichee}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: bas ? _rougeAlerte : const Color(0xFF2E7D32),
        ),
      ),
    );
  }
}

/// Choix de l'unité d'un tissu (mètre ou pagne), affiché uniquement pour
/// les catégories où ce choix a du sens (voir CategorieVente.uniteModifiable).
class _SelecteurUnite extends StatelessWidget {
  const _SelecteurUnite({required this.uniteChoisie, required this.onChange});

  final String uniteChoisie;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<String>(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: _bleuSeda,
          selectedForegroundColor: Colors.white,
          foregroundColor: _bleuSeda,
        ),
        segments: [
          for (final u in unitesTissuDisponibles)
            ButtonSegment(value: u, label: Text(u[0].toUpperCase() + u.substring(1))),
        ],
        selected: {uniteChoisie},
        onSelectionChanged: (selection) => onChange(selection.first),
      ),
    );
  }
}

class _Cellule extends StatelessWidget {
  const _Cellule(
    this.texte, {
    this.entete = false,
    this.alignDroite = false,
    this.tronquer = true,
  });

  final String texte;
  final bool entete;
  final bool alignDroite;
  final bool tronquer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: entete ? 14 : 12, horizontal: 8),
      child: Text(
        texte,
        textAlign: alignDroite ? TextAlign.right : TextAlign.left,
        maxLines: tronquer ? 1 : null,
        overflow: tronquer ? TextOverflow.ellipsis : TextOverflow.visible,
        style: TextStyle(
          fontWeight: entete ? FontWeight.bold : FontWeight.w600,
          color: entete ? Colors.white : const Color(0xFF231A14),
          fontSize: entete ? 13 : 14,
          letterSpacing: entete ? 0.3 : 0,
        ),
      ),
    );
  }
}
