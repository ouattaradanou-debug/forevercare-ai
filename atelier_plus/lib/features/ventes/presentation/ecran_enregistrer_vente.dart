import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/article.dart';
import '../../../data/models/categorie_vente.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/ventes_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);

/// Enregistre une vente directe (prêt-à-porter, tissu ou article de
/// couture) : les libellés et l'unité de quantité s'adaptent à [categorie],
/// pour un formulaire pertinent dans chaque cas sans dupliquer l'écran.
///
/// Choisir un article du catalogue (voir `EcranGestionStock`) décrémente
/// automatiquement son stock ; laisser "Vente libre" garde le formulaire
/// utilisable même pour un article non suivi en stock.
class EcranEnregistrerVente extends ConsumerStatefulWidget {
  const EcranEnregistrerVente({super.key, required this.categorie});

  final CategorieVente categorie;

  @override
  ConsumerState<EcranEnregistrerVente> createState() => _EcranEnregistrerVenteState();
}

class _EcranEnregistrerVenteState extends ConsumerState<EcranEnregistrerVente> {
  final _designationCtrl = TextEditingController();
  final _quantiteCtrl = TextEditingController(text: '1');
  final _prixUnitaireCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  Article? _articleChoisi;
  bool _chargement = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _quantiteCtrl.addListener(() => setState(() {}));
    _prixUnitaireCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _designationCtrl.dispose();
    _quantiteCtrl.dispose();
    _prixUnitaireCtrl.dispose();
    super.dispose();
  }

  double get _quantite => double.tryParse(_quantiteCtrl.text.replaceAll(',', '.')) ?? 0;
  double get _prixUnitaire => double.tryParse(_prixUnitaireCtrl.text.replaceAll(',', '.')) ?? 0;
  double get _montantTotal => _quantite * _prixUnitaire;

  void _appliquerChoixArticle(Article? article) {
    setState(() {
      _articleChoisi = article;
      if (article != null) {
        _designationCtrl.text = article.nom;
        _prixUnitaireCtrl.text = article.prixUnitaireDefaut.toStringAsFixed(0);
      }
    });
  }

  Future<void> _ouvrirChoixArticle(List<Article> articles) async {
    final resultat = await showDialog<_ChoixArticle>(
      context: context,
      builder: (context) =>
          _DialogueChoixArticle(articles: articles, articleActuel: _articleChoisi),
    );
    if (resultat != null) _appliquerChoixArticle(resultat.article);
  }

  Future<void> _choisirDate() async {
    final choisie = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (choisie != null) setState(() => _date = choisie);
  }

  Future<void> _enregistrer() async {
    final designation = _designationCtrl.text.trim();
    if (designation.isEmpty) {
      setState(() => _erreur = 'Entrez une désignation.');
      return;
    }
    if (_quantite <= 0) {
      setState(() => _erreur = 'Entrez une quantité valide.');
      return;
    }
    if (_prixUnitaire <= 0) {
      setState(() => _erreur = 'Entrez un prix unitaire valide.');
      return;
    }

    final article = _articleChoisi;
    if (article != null && _quantite > article.quantiteStock) {
      final continuer = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Stock insuffisant'),
          content: Text(
            'Il ne reste que ${Formatters.nombre(article.quantiteStock)} '
            '${article.uniteAffichee} en stock pour « ${article.nom} ». '
            'Enregistrer cette vente quand même ?',
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
              child: const Text('Continuer'),
            ),
          ],
        ),
      );
      if (continuer != true) return;
    }

    setState(() {
      _chargement = true;
      _erreur = null;
    });

    try {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      await ref.read(ventesRepositoryProvider).enregistrerVente(
            atelierId: utilisateur!.atelierId,
            categorie: widget.categorie,
            designation: designation,
            quantite: _quantite,
            prixUnitaire: _prixUnitaire,
            date: _date,
            article: article,
          );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Vente enregistrée.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) setState(() => _erreur = e.toString());
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorie = widget.categorie;
    final articlesAsync = ref.watch(articlesDeLAtelierProvider);
    final articlesCategorie = articlesAsync.valueOrNull
            ?.where((a) => a.categorie == categorie)
            .toList() ??
        const <Article>[];

    return Scaffold(
      appBar: AppBar(
        title: Text('Vente de ${categorie.libelle.toLowerCase()}'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (articlesCategorie.isNotEmpty) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _ouvrirChoixArticle(articlesCategorie),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Article du catalogue'),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _articleChoisi?.nom ?? 'Vente libre (non suivie en stock)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: _bleuSeda),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _designationCtrl,
                enabled: _articleChoisi == null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Désignation',
                  hintText: categorie.exempleDesignation,
                ),
                autofocus: articlesCategorie.isEmpty,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantiteCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Quantité (${_articleChoisi?.uniteAffichee ?? categorie.uniteLabel})',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _prixUnitaireCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText:
                      'Prix par ${_articleChoisi?.uniteAffichee ?? categorie.uniteLabel} (FCFA)',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined, color: _bleuSeda),
                title: const Text('Date de la vente'),
                subtitle: Text(Formatters.dateLongue(_date)),
                onTap: _choisirDate,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _bleuSeda,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Montant total', style: TextStyle(color: Colors.white)),
                    Text(
                      Formatters.montant(_montantTotal),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: _orangeSeda),
                    ),
                  ],
                ),
              ),
              if (_erreur != null) ...[
                const SizedBox(height: 8),
                Text(_erreur!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _chargement ? null : _enregistrer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orangeSeda,
                  foregroundColor: Colors.white,
                ),
                child: _chargement
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Enregistrer la vente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Résultat du choix dans [_DialogueChoixArticle] : `article` null signifie
/// explicitement "Vente libre" — à distinguer d'une fermeture du dialogue
/// sans choix (qui renvoie `null` tout court via showDialog).
class _ChoixArticle {
  const _ChoixArticle(this.article);
  final Article? article;
}

/// Liste des articles de la catégorie sous forme de petit tableau (nom à
/// gauche, quantité en stock à l'extrême droite), plus lisible que le menu
/// déroulant standard pour un tailleur peu à l'aise à l'écrit.
class _DialogueChoixArticle extends StatelessWidget {
  const _DialogueChoixArticle({required this.articles, required this.articleActuel});

  final List<Article> articles;
  final Article? articleActuel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choisir un article',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _bleuSeda),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: SingleChildScrollView(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _bleuSeda, width: 2),
                    ),
                    child: Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      columnWidths: const {1: FixedColumnWidth(92)},
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(color: _bleuSeda),
                          children: [
                            _CelluleChoix('Article', entete: true),
                            _CelluleChoix('Stock', entete: true),
                          ],
                        ),
                        _ligneChoix(
                          context,
                          article: null,
                          nom: 'Vente libre (non suivie en stock)',
                          stock: null,
                          selectionne: articleActuel == null,
                        ),
                        for (final a in articles)
                          _ligneChoix(
                            context,
                            article: a,
                            nom: a.nom,
                            stock: '${Formatters.nombre(a.quantiteStock)} ${a.uniteAffichee}',
                            selectionne: articleActuel?.id == a.id,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: _bleuSeda),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _ligneChoix(
    BuildContext context, {
    required Article? article,
    required String nom,
    required String? stock,
    required bool selectionne,
  }) {
    final fond = selectionne ? const Color(0xFFE3EAF7) : Colors.white;
    void choisir() => Navigator.pop(context, _ChoixArticle(article));
    return TableRow(
      decoration: BoxDecoration(color: fond),
      children: [
        GestureDetector(onTap: choisir, child: _CelluleChoix(nom)),
        GestureDetector(onTap: choisir, child: _CelluleChoix(stock ?? '—', alignDroite: true)),
      ],
    );
  }
}

class _CelluleChoix extends StatelessWidget {
  const _CelluleChoix(this.texte, {this.entete = false, this.alignDroite = false});

  final String texte;
  final bool entete;
  final bool alignDroite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Text(
        texte,
        textAlign: alignDroite ? TextAlign.right : TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: entete ? FontWeight.bold : FontWeight.w600,
          color: entete ? Colors.white : const Color(0xFF231A14),
          fontSize: entete ? 13 : 14,
        ),
      ),
    );
  }
}
