import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/gestion_erreurs.dart';
import '../../../core/utils/telephone.dart';
import '../../../data/models/groupe_uniforme.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/uniformes_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);
const _vertWhatsapp = Color(0xFF25D366);

/// Groupes de mesures d'uniformes (promotion, établissement, équipe) :
/// permet de prendre les mesures de plusieurs personnes à la fois, en
/// dehors des fiches clients individuelles. Organisés en tableau avec
/// contact direct (appel/WhatsApp) du répondant du groupe.
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
        scrollable: true,
        title: const Text('Nouveau groupe', style: TextStyle(color: _bleuSeda)),
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
            style: TextButton.styleFrom(foregroundColor: _bleuSeda),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: _orangeSeda),
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

  Future<void> _appeler(String telephone) => executerAvecErreurAffichee(
        context,
        () => launchUrl(Uri(scheme: 'tel', path: telephone)),
      );

  Future<void> _whatsapp(String telephone) => executerAvecErreurAffichee(
        context,
        () => launchUrl(Uri.parse('https://wa.me/${Telephone.normaliser(telephone)}')),
      );

  @override
  Widget build(BuildContext context) {
    final groupes = ref.watch(groupesUniformesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesures des uniformes'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
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
                    : SingleChildScrollView(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: _bleuSeda, width: 2),
                              boxShadow: const [
                                BoxShadow(color: Color(0x1F000000), blurRadius: 10),
                              ],
                            ),
                            child: Table(
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              columnWidths: const {2: FixedColumnWidth(84)},
                              children: [
                                TableRow(
                                  decoration: const BoxDecoration(color: _bleuSeda),
                                  children: const [
                                    _Cellule('Groupe', entete: true),
                                    _Cellule('Répondant', entete: true),
                                    SizedBox.shrink(),
                                  ],
                                ),
                                for (final entree in liste.asMap().entries)
                                  _ligne(entree.value, entree.key),
                              ],
                            ),
                          ),
                        ),
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
                  backgroundColor: _bleuSeda,
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

  TableRow _ligne(GroupeUniforme groupe, int index) {
    final fondLigne = index.isEven ? Colors.white : const Color(0xFFF6F3EE);

    return TableRow(
      decoration: BoxDecoration(color: fondLigne),
      children: [
        GestureDetector(
          onTap: () => context.push(AppRoutes.detailGroupeUniforme(groupe.id)),
          child: _Cellule(groupe.nom, tronquer: false),
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.detailGroupeUniforme(groupe.id)),
          child: _Cellule(groupe.repondantNom ?? '—', tronquer: false),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: IconButton(
              onPressed: () => _modifierGroupe(groupe),
              tooltip: 'Modifier',
              style: IconButton.styleFrom(
                backgroundColor: _orangeSeda,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                minimumSize: const Size(36, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.add, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  /// Corrige le nom du groupe et/ou les coordonnées du répondant, avec
  /// appel/WhatsApp directement depuis la même boîte — ouverte par le "+"
  /// de chaque ligne.
  Future<void> _modifierGroupe(GroupeUniforme groupe) async {
    final nomCtrl = TextEditingController(text: groupe.nom);
    final repondantNomCtrl = TextEditingController(text: groupe.repondantNom ?? '');
    final repondantTelCtrl = TextEditingController(text: groupe.repondantTelephone ?? '');
    final telephoneActuel = groupe.repondantTelephone;

    final resultat = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text('Modifier : ${groupe.nom}', style: const TextStyle(color: _bleuSeda)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nom du groupe'),
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
        actions: [
          if (telephoneActuel != null && telephoneActuel.isNotEmpty) ...[
            TextButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, false);
                _appeler(telephoneActuel);
              },
              style: TextButton.styleFrom(foregroundColor: _bleuSeda),
              icon: const Icon(Icons.call),
              label: const Text('Appeler'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, false);
                _whatsapp(telephoneActuel);
              },
              style: TextButton.styleFrom(foregroundColor: _vertWhatsapp),
              icon: const Icon(Icons.chat),
              label: const Text('WhatsApp'),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(foregroundColor: _bleuSeda),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: _orangeSeda),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (resultat != true || nomCtrl.text.trim().isEmpty || !mounted) return;

    await executerAvecErreurAffichee(
      context,
      () => ref.read(groupesUniformesRepositoryProvider).modifierGroupe(
            groupe: groupe,
            nom: nomCtrl.text.trim(),
            repondantNom:
                repondantNomCtrl.text.trim().isEmpty ? null : repondantNomCtrl.text.trim(),
            repondantTelephone:
                repondantTelCtrl.text.trim().isEmpty ? null : repondantTelCtrl.text.trim(),
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Text(
        texte,
        maxLines: tronquer ? 1 : 2,
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
