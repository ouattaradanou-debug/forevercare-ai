import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/categorie_vente.dart';
import '../../../data/models/vente.dart';
import '../../auth/providers/auth_providers.dart';
import '../../finances/data/recapitulatif_finances.dart';
import '../providers/ventes_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);

enum _Periode { jour, semaine, mois, annee }

/// Historique de toutes les ventes (les trois catégories confondues),
/// filtrable par période et par catégorie, avec le détail du montant total
/// par catégorie sur la période choisie — le cœur du "suivi efficace"
/// demandé : voir en un coup d'œil ce qui se vend le mieux.
class EcranHistoriqueVentes extends ConsumerStatefulWidget {
  const EcranHistoriqueVentes({super.key});

  @override
  ConsumerState<EcranHistoriqueVentes> createState() => _EcranHistoriqueVentesState();
}

class _EcranHistoriqueVentesState extends ConsumerState<EcranHistoriqueVentes> {
  _Periode _periode = _Periode.mois;
  CategorieVente? _categorie;

  @override
  void initState() {
    super.initState();
    // Le cache local ne contient que les ventes déjà rencontrées sur cet
    // appareil : on rapatrie celles du serveur (autres appareils) dès
    // l'ouverture, comme pour l'historique des dépenses.
    Future.microtask(() async {
      final atelier = await ref.read(atelierCourantProvider.future);
      if (atelier != null) {
        await ref.read(ventesRepositoryProvider).chargerDepuisServeur(atelier.id);
      }
    });
  }

  /// Corrige une vente déjà enregistrée (erreur de saisie : désignation,
  /// quantité, prix ou date).
  Future<void> _modifier(Vente vente) async {
    // Reprend l'unité choisie pour l'article vendu (ex. "pagne"), si la
    // vente en référence un, plutôt que l'unité par défaut de la
    // catégorie — pour que les champs affichent la bonne unité.
    final articleId = vente.articleId;
    final article =
        articleId == null ? null : await ref.read(articlesRepositoryProvider).articleParId(articleId);
    final unite = article?.uniteAffichee ?? vente.categorie.uniteLabel;

    final designationCtrl = TextEditingController(text: vente.designation);
    final quantiteCtrl = TextEditingController(text: Formatters.nombre(vente.quantite));
    final prixCtrl = TextEditingController(text: vente.prixUnitaire.toStringAsFixed(0));
    var date = vente.date;

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          scrollable: true,
          title: const Text('Modifier la vente', style: TextStyle(color: _bleuSeda)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: designationCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Désignation'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantiteCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Quantité ($unite)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: prixCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Prix par $unite (FCFA)',
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined, color: _bleuSeda),
                title: const Text('Date'),
                subtitle: Text(Formatters.dateLongue(date)),
                onTap: () async {
                  final choisie = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (choisie != null) setStateDialog(() => date = choisie);
                },
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

    final designation = designationCtrl.text.trim();
    if (designation.isEmpty) return;
    final quantite = double.tryParse(quantiteCtrl.text.replaceAll(',', '.')) ?? 0;
    final prix = double.tryParse(prixCtrl.text.replaceAll(',', '.')) ?? 0;
    if (quantite <= 0 || prix <= 0) return;

    try {
      await ref.read(ventesRepositoryProvider).modifierVente(
            vente: vente,
            designation: designation,
            quantite: quantite,
            prixUnitaire: prix,
            date: date,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  (DateTime, DateTime) _bornesPeriode(_Periode periode) {
    final now = DateTime.now();
    switch (periode) {
      case _Periode.jour:
        return (debutDuJour(now), debutDuJour(now).add(const Duration(days: 1)));
      case _Periode.semaine:
        return (debutDeLaSemaine(now), debutDeLaSemaine(now).add(const Duration(days: 7)));
      case _Periode.mois:
        return (debutDuMois(now), DateTime(now.year, now.month + 1));
      case _Periode.annee:
        return (debutDeLAnnee(now), DateTime(now.year + 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ventes = ref.watch(ventesDeLAtelierProvider);
    final (debut, finExclusive) = _bornesPeriode(_periode);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des ventes'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _GrilleFiltres(
                nombreColonnes: 4,
                enfants: [
                  for (final p in _Periode.values)
                    _BoutonFiltre(
                      libelle: _libellePeriode(p),
                      selectionne: _periode == p,
                      onTap: () => setState(() => _periode = p),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: _GrilleFiltres(
                nombreColonnes: 2,
                enfants: [
                  _BoutonFiltre(
                    libelle: 'Toutes',
                    selectionne: _categorie == null,
                    onTap: () => setState(() => _categorie = null),
                  ),
                  for (final c in CategorieVente.values)
                    _BoutonFiltre(
                      libelle: _libelleCourtCategorie(c),
                      selectionne: _categorie == c,
                      onTap: () => setState(() => _categorie = c),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ventes.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
                data: (liste) {
                  final dePeriode = liste
                      .where((v) => !v.date.isBefore(debut) && v.date.isBefore(finExclusive))
                      .toList();
                  final filtrees = _categorie == null
                      ? dePeriode
                      : dePeriode.where((v) => v.categorie == _categorie).toList();

                  if (filtrees.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Aucune vente sur cette période.'),
                      ),
                    );
                  }

                  final total = filtrees.fold<double>(0, (s, v) => s + v.montantTotal);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _RecapitulatifParCategorie(ventes: dePeriode),
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Touchez une vente pour corriger une erreur de saisie.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF6F6259)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _bleuSeda, width: 2),
                            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 6)],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Table(
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            columnWidths: const {
                              0: FixedColumnWidth(80),
                              3: FixedColumnWidth(50),
                            },
                            children: [
                              TableRow(
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: _orangeSeda, width: 2)),
                                ),
                                children: const [
                                  _Cellule('Date', entete: true),
                                  _Cellule('Désignation', entete: true),
                                  _Cellule('Montant', entete: true),
                                  _Cellule('Qté', entete: true),
                                ],
                              ),
                              for (final vente in filtrees) _ligne(vente),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: _bleuSeda,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: TextStyle(color: Colors.white)),
                              Text(
                                Formatters.montant(total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _orangeSeda,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _ligne(Vente vente) {
    return TableRow(children: [
      for (final cellule in [
        _Cellule(Formatters.dateCourte(vente.date)),
        _Cellule(vente.designation, tronquer: false),
        _Cellule(Formatters.nombre(vente.montantTotal)),
        _Cellule(Formatters.nombre(vente.quantite)),
      ])
        GestureDetector(onTap: () => _modifier(vente), child: cellule),
    ]);
  }
}

/// Montant total par catégorie sur la période affichée (toujours les trois
/// catégories, indépendamment du filtre catégorie en cours) : la vue
/// d'ensemble qui permet de voir en un coup d'œil ce qui se vend le mieux.
class _RecapitulatifParCategorie extends StatelessWidget {
  const _RecapitulatifParCategorie({required this.ventes});

  final List<Vente> ventes;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Par catégorie, sur la période',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _bleuSeda),
          ),
          const SizedBox(height: 10),
          for (final categorie in CategorieVente.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(categorie.libelle, style: const TextStyle(fontSize: 14)),
                  Text(
                    Formatters.montant(
                      ventes
                          .where((v) => v.categorie == categorie)
                          .fold<double>(0, (s, v) => s + v.montantTotal),
                    ),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

String _libellePeriode(_Periode p) {
  switch (p) {
    case _Periode.jour:
      return 'Jour';
    case _Periode.semaine:
      return 'Semaine';
    case _Periode.mois:
      return 'Mois';
    case _Periode.annee:
      return 'Année';
  }
}

/// Libellé court pour la grille à 2 colonnes : "Article de couture" ne
/// tiendrait pas sur une ligne dans la largeur disponible.
String _libelleCourtCategorie(CategorieVente c) {
  return c == CategorieVente.articleCouture ? 'Couture' : c.libelle;
}

/// Grille de boutons de filtre en pleine largeur, à hauteur fixe pour que
/// le texte ("Semaine", "Article de couture"...) ne se coupe jamais sur
/// plusieurs lignes — remplace les anciens `SegmentedButton`, trop étroits
/// pour des tailleurs peu à l'aise avec la lecture.
class _GrilleFiltres extends StatelessWidget {
  const _GrilleFiltres({required this.nombreColonnes, required this.enfants});

  final int nombreColonnes;
  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: nombreColonnes,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 44,
      ),
      children: enfants,
    );
  }
}

class _BoutonFiltre extends StatelessWidget {
  const _BoutonFiltre({
    required this.libelle,
    required this.selectionne,
    required this.onTap,
  });

  final String libelle;
  final bool selectionne;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selectionne ? _orangeSeda : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _bleuSeda, width: selectionne ? 0 : 1.5),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            libelle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: selectionne ? Colors.white : _bleuSeda,
            ),
          ),
        ),
      ),
    );
  }
}

class _Cellule extends StatelessWidget {
  const _Cellule(
    this.texte, {
    this.entete = false,
    this.tronquer = true,
  });

  final String texte;
  final bool entete;
  final bool tronquer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Text(
        texte,
        textAlign: TextAlign.center,
        maxLines: tronquer ? 1 : null,
        overflow: tronquer ? TextOverflow.ellipsis : TextOverflow.visible,
        style: TextStyle(
          fontWeight: entete ? FontWeight.bold : FontWeight.normal,
          color: entete ? _bleuSeda : const Color(0xFF231A14),
          fontSize: 13,
        ),
      ),
    );
  }
}
