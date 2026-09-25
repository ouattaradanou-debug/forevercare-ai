import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/ventes/commande.dart';
import '../../core/ventes/commande_ligne.dart';
import '../../core/ventes/facture_texte.dart';
import '../../core/ventes/ventes_providers.dart';

/// Facture d'une commande (Phase 5) : texte généré par
/// `genererTexteFacture` (fonction pure, testée séparément), avec un
/// bouton pour l'envoyer via WhatsApp. Choix délibéré : un lien "wa.me"
/// ouvert par le téléphone lui-même, jamais l'API WhatsApp Business
/// (aucun compte professionnel Meta, aucune clé payante, aucun serveur à
/// maintenir — voir PHASE5.md section 2). Si le client a un numéro
/// enregistré, WhatsApp s'ouvre directement sur sa conversation ; sinon,
/// l'utilisateur choisit lui-même le contact dans WhatsApp.
class FactureScreen extends ConsumerWidget {
  const FactureScreen(
      {super.key, required this.commande, required this.lignes});

  final Commande commande;
  final List<CommandeLigne> lignes;

  Future<void> _envoyerViaWhatsApp(BuildContext context, String texte,
      String? telephoneClient) async {
    final numero = telephoneClient?.trim().replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse(
        'https://wa.me/${numero != null && numero.isNotEmpty ? numero : ''}'
        '?text=${Uri.encodeComponent(texte)}');
    final ouvert = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ouvert && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Impossible d\'ouvrir WhatsApp.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infosCave = ref.watch(infosCaveProvider).valueOrNull;
    final clients = ref.watch(clientsProvider).valueOrNull ?? const [];
    final clientsTrouves =
        clients.where((c) => c.id == commande.clientId);
    final client = clientsTrouves.isEmpty ? null : clientsTrouves.first;

    final texte = genererTexteFacture(
      cave: infosCave,
      commande: commande,
      lignes: lignes,
      client: client,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Facture')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(texte,
                          style: const TextStyle(
                              fontFamily: 'monospace', fontSize: 14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    _envoyerViaWhatsApp(context, texte, client?.telephone),
                icon: const Icon(Icons.chat),
                label: const Text('Envoyer via WhatsApp'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
