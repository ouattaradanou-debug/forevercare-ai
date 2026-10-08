import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/gestion_erreurs.dart';
import '../../../core/utils/telephone.dart';
import '../../../data/models/membre_groupe_uniforme.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/uniformes_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _vertWhatsapp = Color(0xFF25D366);

/// Détail d'un groupe d'uniformes : informations du répondant (en tableau,
/// avec appel/WhatsApp direct), liste des membres (avec leur statut "tenue
/// terminée"), et ajout de nouveaux membres. Chaque membre mène à la prise
/// de ses mesures.
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
    final groupe = ref.watch(groupeUniformeParIdProvider(widget.groupeId));
    final membres = ref.watch(membresDuGroupeProvider(widget.groupeId));

    return Scaffold(
      appBar: AppBar(
        title: Text(groupe.valueOrNull?.nom ?? 'Groupe'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
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
                      final telephone = g.repondantTelephone;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
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
                              columnWidths: const {1: FixedColumnWidth(84)},
                              children: [
                                TableRow(
                                  decoration: const BoxDecoration(color: _bleuSeda),
                                  children: const [
                                    _CelluleRepondant('Nom du répondant', entete: true),
                                    SizedBox.shrink(),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    _CelluleRepondant(g.repondantNom ?? 'Non renseigné'),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child: telephone == null || telephone.isEmpty
                                            ? const SizedBox.shrink()
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  _BoutonContact(
                                                    icone: Icons.call,
                                                    couleur: _bleuSeda,
                                                    tooltip: 'Appeler',
                                                    onTap: () => _appeler(telephone),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  _BoutonContact(
                                                    icone: Icons.chat,
                                                    couleur: _vertWhatsapp,
                                                    tooltip: 'WhatsApp',
                                                    onTap: () => _whatsapp(telephone),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
                  backgroundColor: _bleuSeda,
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

class _CelluleRepondant extends StatelessWidget {
  const _CelluleRepondant(
    this.texte, {
    this.entete = false,
  });

  final String texte;
  final bool entete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Text(
        texte,
        textAlign: TextAlign.center,
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

/// Petit bouton rond coloré pour contacter le répondant — même langage
/// visuel que les autres boutons d'action ronds de l'application.
class _BoutonContact extends StatelessWidget {
  const _BoutonContact({
    required this.icone,
    required this.couleur,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icone;
  final Color couleur;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: couleur,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        minimumSize: const Size(30, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
      ),
      icon: Icon(icone, size: 14),
    );
  }
}
