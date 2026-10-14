import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/gestion_erreurs.dart';
import '../../../data/models/commande.dart';
import '../../../data/models/paiement.dart';
import '../../auth/providers/auth_providers.dart';
import '../../branding/providers/branding_providers.dart';
import '../../clients/providers/clients_providers.dart';
import '../data/calcul_solde.dart';
import '../providers/finances_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);

/// Contenu financier d'un client : commande en cours (montant total,
/// avance, reste à payer calculé automatiquement, case "Tenue retirée",
/// historique des paiements), et historique des commandes précédentes —
/// un client qui revient pour une nouvelle couture garde l'historique
/// complet de ses commandes passées, jamais écrasé.
///
/// Extrait en widget partagé pour être affiché à la fois par l'écran dédié
/// `EcranFinancesClient` et directement sur la fiche client — l'appelant
/// est responsable de vérifier que l'utilisateur est bien propriétaire
/// avant d'afficher ce widget (donnée financière, jamais montrée à un
/// apprenti).
class SectionFinancesClient extends ConsumerStatefulWidget {
  const SectionFinancesClient({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<SectionFinancesClient> createState() => _SectionFinancesClientState();
}

class _SectionFinancesClientState extends ConsumerState<SectionFinancesClient> {
  bool _historiqueVisible = false;

  // Carrousel des commandes du client (voir build()) : le tailleur glisse
  // de gauche (Commande N°1, la plus ancienne) à droite (la plus récente)
  // et vice versa. _pageInitialisee déclenche un saut automatique vers la
  // dernière page une fois les commandes chargées (ou une nouvelle créée),
  // la liste n'étant connue qu'après le premier chargement asynchrone.
  final PageController _pageController = PageController();
  int _pageCourante = 0;
  bool _pageInitialisee = false;

  // Tant que le rapatriement serveur n'est pas terminé, une liste de
  // commandes vide ne veut rien dire (le cache local peut tout simplement
  // ne pas encore avoir reçu la commande existante) : on ne doit jamais
  // proposer "Créer une commande" sur la seule foi d'un cache encore vide
  // à cet instant précis, sous peine de créer un doublon si le tailleur
  // appuie avant la fin de ce chargement.
  bool _chargementInitial = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(financesRepositoryProvider).chargerDepuisServeur(widget.clientId);
      if (mounted) setState(() => _chargementInitial = false);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<({double montant, double avance})?> _demanderMontants({
    required String titre,
    double? montantActuel,
    double? avanceActuelle,
  }) async {
    final montantCtrl = TextEditingController(text: montantActuel?.toStringAsFixed(0) ?? '');
    final avanceCtrl = TextEditingController(text: avanceActuelle?.toStringAsFixed(0) ?? '');

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titre, style: const TextStyle(color: _bleuSeda)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: montantCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Montant total (FCFA)',
                labelStyle: TextStyle(fontSize: 13),
              ),
            ),
            TextField(
              controller: avanceCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Avance reçue (FCFA)',
                labelStyle: TextStyle(fontSize: 13),
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
    if (confirme != true) return null;
    return (
      montant: double.tryParse(montantCtrl.text.replaceAll(',', '.')) ?? 0,
      avance: double.tryParse(avanceCtrl.text.replaceAll(',', '.')) ?? 0,
    );
  }

  /// Nouvelle couture pour ce client : crée une commande distincte, sans
  /// toucher à la commande en cours ni à l'historique des précédentes.
  Future<void> _creerNouvelleCommande() async {
    final valeurs = await _demanderMontants(titre: 'Nouvelle commande');
    if (valeurs == null) return;

    if (!mounted) return;
    await executerAvecErreurAffichee(
      context,
      () async {
        final utilisateur = await utilisateurCourantRequis(ref);
        await ref.read(financesRepositoryProvider).creerNouvelleCommande(
              atelierId: utilisateur.atelierId,
              clientId: widget.clientId,
              montantTotal: valeurs.montant,
              avance: valeurs.avance,
            );
      },
    );
    ref.invalidate(commandesDuClientProvider(widget.clientId));
    // Refait sauter le carrousel vers la nouvelle dernière page une fois la
    // commande fraîchement créée rechargée (voir build()).
    if (mounted) setState(() => _pageInitialisee = false);
  }

  /// Corrige le montant total, l'avance et le paiement reçu de la commande
  /// en cours (erreur de saisie) — ne crée jamais une nouvelle commande.
  /// Corriger le paiement reçu remplace l'historique détaillé des
  /// paiements individuels par une seule ligne correspondant au nouveau
  /// total (voir FinancesRepository.definirPaiementTotal).
  Future<void> _modifierCommandeCourante(Commande courante, double sommePaiementsActuelle) async {
    final montantCtrl = TextEditingController(text: courante.montantTotal.toStringAsFixed(0));
    final avanceCtrl = TextEditingController(text: courante.avance.toStringAsFixed(0));
    final paiementCtrl = TextEditingController(text: sommePaiementsActuelle.toStringAsFixed(0));

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Modifier Montant/Avance/Paiement',
          style: TextStyle(color: _bleuSeda, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: montantCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Montant total (FCFA)',
                labelStyle: TextStyle(fontSize: 13),
              ),
            ),
            TextField(
              controller: avanceCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Avance reçue (FCFA)',
                labelStyle: TextStyle(fontSize: 13),
              ),
            ),
            TextField(
              controller: paiementCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Paiement reçu (FCFA)',
                labelStyle: TextStyle(fontSize: 13),
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

    final montant = double.tryParse(montantCtrl.text.replaceAll(',', '.')) ?? 0;
    final avance = double.tryParse(avanceCtrl.text.replaceAll(',', '.')) ?? 0;
    final paiement = double.tryParse(paiementCtrl.text.replaceAll(',', '.')) ?? 0;

    if (!mounted) return;
    await executerAvecErreurAffichee(context, () async {
      final utilisateur = await utilisateurCourantRequis(ref);
      final repo = ref.read(financesRepositoryProvider);
      await repo.modifierCommande(
        atelierId: utilisateur.atelierId,
        commande: courante,
        montantTotal: montant,
        avance: avance,
      );
      if (paiement != sommePaiementsActuelle) {
        await repo.definirPaiementTotal(
          atelierId: utilisateur.atelierId,
          commande: courante,
          nouveauTotal: paiement,
        );
      }
    });
    ref.invalidate(commandesDuClientProvider(widget.clientId));
  }

  Future<void> _ajouterPaiement(String commandeId) async {
    final montantCtrl = TextEditingController();
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un paiement', style: TextStyle(color: _bleuSeda)),
        content: TextField(
          controller: montantCtrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 15),
          decoration: const InputDecoration(
            labelText: 'Montant reçu (FCFA)',
            labelStyle: TextStyle(fontSize: 13),
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
    final montant = double.tryParse(montantCtrl.text.replaceAll(',', '.')) ?? 0;
    if (montant <= 0) return;

    if (!mounted) return;
    await executerAvecErreurAffichee(context, () async {
      final utilisateur = await utilisateurCourantRequis(ref);
      await ref.read(financesRepositoryProvider).ajouterPaiement(
            atelierId: utilisateur.atelierId,
            commandeId: commandeId,
            montant: montant,
          );
    });
  }

  /// Génère la facture (convertie en image) et affiche un écran de
  /// vérification avant l'envoi : le tailleur voit la facture telle qu'elle
  /// sera reçue, puis appuie sur l'unique bouton "Envoyer via WhatsApp", qui
  /// ouvre le menu de partage standard du téléphone — le tailleur y
  /// choisit WhatsApp puis le contact. La facture est en image (pas en
  /// PDF) : WhatsApp l'affiche alors comme une photo, sans que le client
  /// ait besoin d'une application de lecture PDF.
  ///
  /// Un mécanisme antérieur tentait d'ouvrir directement la conversation
  /// WhatsApp du client (sans ce choix manuel), via un canal natif Android
  /// non documenté officiellement (un "jid" caché dans l'intent de
  /// partage). Retiré : WhatsApp ne confirme jamais réellement avoir reçu
  /// le fichier à ce niveau (l'appel Android réussit même si WhatsApp ne
  /// peut pas résoudre la conversation, par exemple si le numéro n'est pas
  /// enregistré dans les Contacts du téléphone) — ce qui produisait des
  /// envois silencieusement sans effet, sans jamais se rabattre sur le
  /// menu de partage. Le menu de partage standard est fiable, au prix d'un
  /// choix manuel du contact à chaque envoi.
  Future<void> _imprimerFacture(Commande courante, List<Paiement> paiements) async {
    final atelier = await ref.read(atelierCourantProvider.future);
    final client = await ref.read(clientParIdProvider(widget.clientId).future);
    if (!mounted || atelier == null || client == null) return;

    Uint8List png;
    try {
      final pdf = await ref.read(pdfExportServiceProvider).genererFacturePdf(
            atelier: atelier,
            client: client,
            commande: courante,
            paiements: paiements,
          );
      final page = await Printing.raster(pdf, dpi: 150).first;
      png = await page.toPng();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
      return;
    }
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Vérifiez la facture',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _bleuSeda),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: Image.memory(png, fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await executerAvecErreurAffichee(this.context, () async {
                      final dossier = await getTemporaryDirectory();
                      final fichier =
                          await File('${dossier.path}/facture.png').writeAsBytes(png);
                      await Share.shareXFiles([XFile(fichier.path)]);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text('Envoyer via WhatsApp'),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: _bleuSeda),
                child: const Text('Fermer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _basculerTenueRetiree(Commande courante, bool? valeur) async {
    if (!mounted) return;
    await executerAvecErreurAffichee(context, () async {
      final utilisateur = await utilisateurCourantRequis(ref);
      await ref.read(financesRepositoryProvider).definirTenueRetiree(
            atelierId: utilisateur.atelierId,
            commande: courante,
            tenueRetiree: valeur ?? false,
          );
    });
    ref.invalidate(commandesDuClientProvider(widget.clientId));
  }

  @override
  Widget build(BuildContext context) {
    final commandesAsync = ref.watch(commandesDuClientProvider(widget.clientId));

    return commandesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
      data: (commandes) {
        if (commandes.isEmpty) {
          if (_chargementInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: ElevatedButton.icon(
              onPressed: _creerNouvelleCommande,
              style: ElevatedButton.styleFrom(
                backgroundColor: _orangeSeda,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Créer une commande'),
            ),
          );
        }

        // Ordre chronologique croissant : Commande N°1 = la toute première
        // commande du client, quel que soit l'ordre renvoyé par le serveur
        // (commandesDuClientProvider donne la plus récente en premier).
        final commandesParAnciennete = [...commandes]
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        final numeroCommande = {
          for (final entree in commandesParAnciennete.asMap().entries)
            entree.value.id: entree.key + 1,
        };

        // Saute vers la dernière page (la commande la plus récente) une
        // fois la liste chargée — à l'ouverture, et de nouveau après
        // "Nouvelle commande" (voir _creerNouvelleCommande).
        if (!_pageInitialisee) {
          _pageInitialisee = true;
          _pageCourante = commandesParAnciennete.length - 1;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(commandesParAnciennete.length - 1);
            }
          });
        }
        final indexActif = _pageCourante.clamp(0, commandesParAnciennete.length - 1);
        final active = commandesParAnciennete[indexActif];
        final paiementsActive = ref.watch(paiementsDeLaCommandeProvider(active.id));

        // Historique complet : tous les paiements de toutes les commandes du
        // client (actuelle et précédentes), numérotées par ordre
        // chronologique.
        final historiqueComplet = <(int numero, Paiement paiement)>[];
        for (final c in commandes) {
          final paiementsCommande = c.id == active.id
              ? paiementsActive.valueOrNull
              : ref.watch(paiementsDeLaCommandeProvider(c.id)).valueOrNull;
          for (final p in paiementsCommande ?? const <Paiement>[]) {
            historiqueComplet.add((numeroCommande[c.id]!, p));
          }
        }
        historiqueComplet.sort((a, b) => b.$2.datePaiement.compareTo(a.$2.datePaiement));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              // Un peu plus haut que le contenu le plus large attendu (voir
              // _CarteCommande, qui scrolle elle-même par sécurité si jamais
              // une commande dépasse quand même, ex. réglage d'accessibilité
              // "texte plus grand" sur le téléphone).
              height: 340,
              child: PageView.builder(
                controller: _pageController,
                itemCount: commandesParAnciennete.length,
                onPageChanged: (index) => setState(() => _pageCourante = index),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _CarteCommande(
                    commande: commandesParAnciennete[index],
                    numero: index + 1,
                    onModifier: _modifierCommandeCourante,
                    onTenueRetiree: _basculerTenueRetiree,
                  ),
                ),
              ),
            ),
            if (commandesParAnciennete.length > 1) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < commandesParAnciennete.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == indexActif ? 10 : 7,
                      height: i == indexActif ? 10 : 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == indexActif ? _bleuSeda : const Color(0xFFD9D2C8),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _ajouterPaiement(active.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orangeSeda,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Ajouter un paiement'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _creerNouvelleCommande,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _bleuSeda,
                      side: const BorderSide(color: _bleuSeda),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('Nouvelle commande'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  _imprimerFacture(active, paiementsActive.valueOrNull ?? const []),
              style: OutlinedButton.styleFrom(
                foregroundColor: _bleuSeda,
                side: const BorderSide(color: _bleuSeda),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Imprimer la facture'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => setState(() => _historiqueVisible = !_historiqueVisible),
              style: OutlinedButton.styleFrom(
                foregroundColor: _bleuSeda,
                side: const BorderSide(color: _bleuSeda),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              icon: Icon(_historiqueVisible ? Icons.expand_less : Icons.expand_more),
              label: const Text('Historique des paiements'),
            ),
            if (_historiqueVisible) ...[
              const SizedBox(height: 12),
              _TableauHistoriquePaiements(lignes: historiqueComplet),
            ],
          ],
        );
      },
    );
  }
}

class _LigneMontant extends StatelessWidget {
  const _LigneMontant(this.libelle, this.montant, {this.accent = false});

  final String libelle;
  final double montant;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final style = accent
        ? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _orangeSeda)
        : const TextStyle(fontSize: 15, color: Color(0xFF231A14));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(libelle, style: style),
          Text(Formatters.montant(montant), style: style),
        ],
      ),
    );
  }
}

/// Une page du carrousel de commandes (voir build()) : montant total,
/// avance (+ paiements reçus depuis), reste à payer, bouton de correction
/// et case "Tenue retirée" — tout est propre à [commande], jamais mélangé
/// avec les autres commandes du client.
class _CarteCommande extends ConsumerWidget {
  const _CarteCommande({
    required this.commande,
    required this.numero,
    required this.onModifier,
    required this.onTenueRetiree,
  });

  final Commande commande;
  final int numero;
  final void Function(Commande commande, double sommePaiements) onModifier;
  final void Function(Commande commande, bool? valeur) onTenueRetiree;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paiements = ref.watch(paiementsDeLaCommandeProvider(commande.id));
    final sommePaiements =
        paiements.valueOrNull?.fold<double>(0, (total, p) => total + p.montant) ?? 0;
    final reste = resteAPayer(
      montantTotal: commande.montantTotal,
      avance: commande.avance,
      sommePaiements: sommePaiements,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        // Scrollable par sécurité : si jamais le contenu dépasse la hauteur
        // allouée au carrousel (ex. réglage "texte plus grand" du
        // téléphone), le tailleur peut faire défiler cette carte plutôt que
        // de voir du contenu tronqué ou le bandeau noir/jaune de
        // débordement de Flutter.
        child: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Commande N°$numero',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _bleuSeda),
            ),
            const SizedBox(height: 6),
            _LigneMontant('Montant total', commande.montantTotal),
            // Avance + tous les paiements ajoutés depuis — augmente donc
            // visiblement à chaque nouveau paiement, plutôt que de rester
            // figée sur le montant initial.
            _LigneMontant('Avance', commande.avance + sommePaiements),
            _LigneMontant('Reste à payer', reste > 0 ? reste : 0, accent: true),
            const Divider(),
            const SizedBox(height: 4),
            OutlinedButton(
              onPressed: () => onModifier(commande, sommePaiements),
              style: OutlinedButton.styleFrom(
                foregroundColor: _bleuSeda,
                side: const BorderSide(color: _bleuSeda),
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              child: const Text('Modifier Montant/Avance/Paiement', textAlign: TextAlign.center),
            ),
            CheckboxListTile(
              value: commande.tenueRetiree,
              activeColor: _bleuSeda,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text(
                'Tenue retirée',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              onChanged: (valeur) => onTenueRetiree(commande, valeur),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

/// Tableau de l'historique des paiements, toutes commandes confondues (voir
/// le bouton "Historique des paiements") — numéro de commande (1 = la toute
/// première commande du client, par ordre chronologique), date et montant
/// de chaque paiement, du plus récent au plus ancien.
class _TableauHistoriquePaiements extends StatelessWidget {
  const _TableauHistoriquePaiements({required this.lignes});

  final List<(int numero, Paiement paiement)> lignes;

  @override
  Widget build(BuildContext context) {
    if (lignes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text('Aucun paiement enregistré.', style: TextStyle(fontSize: 14)),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _bleuSeda, width: 2),
          boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 10)],
        ),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: const BoxDecoration(color: _bleuSeda),
              children: const [
                _CelluleTableau('N° commande', entete: true),
                _CelluleTableau('Date', entete: true),
                _CelluleTableau('Montant', entete: true),
              ],
            ),
            for (final entree in lignes.asMap().entries)
              TableRow(
                decoration: BoxDecoration(
                  color: entree.key.isEven ? Colors.white : const Color(0xFFF6F3EE),
                ),
                children: [
                  _CelluleTableau('N°${entree.value.$1}'),
                  _CelluleTableau(Formatters.dateCourte(entree.value.$2.datePaiement)),
                  _CelluleTableau(Formatters.montant(entree.value.$2.montant)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CelluleTableau extends StatelessWidget {
  const _CelluleTableau(this.texte, {this.entete = false});

  final String texte;
  final bool entete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
