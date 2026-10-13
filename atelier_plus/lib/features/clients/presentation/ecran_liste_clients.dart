import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/router/app_router.dart';
import '../../../core/utils/texte_suppression_finances.dart';
import '../../../data/models/client.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/clients_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);

/// Liste des clients avec recherche instantanée (nom/prénom/téléphone).
/// Lecture entièrement locale : fonctionne hors-ligne au quotidien.
class EcranListeClients extends ConsumerStatefulWidget {
  const EcranListeClients({super.key});

  @override
  ConsumerState<EcranListeClients> createState() => _EcranListeClientsState();
}

class _EcranListeClientsState extends ConsumerState<EcranListeClients> {
  final _rechercheCtrl = TextEditingController();
  final _dicteeVocale = stt.SpeechToText();
  String _requete = '';
  bool _dicteeDisponible = false;
  bool _enEcoute = false;

  @override
  void initState() {
    super.initState();
    // Rapatriement initial best-effort (silencieux si hors-ligne) : la
    // liste reste utilisable immédiatement via le cache local pendant ce
    // chargement.
    Future.microtask(() async {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      if (utilisateur != null) {
        await ref.read(clientsRepositoryProvider).chargerDepuisServeur(utilisateur.atelierId);
      }
    });
  }

  @override
  void dispose() {
    _dicteeVocale.stop();
    _rechercheCtrl.dispose();
    super.dispose();
  }

  /// Dicter la recherche (nom ou numéro) pour un tailleur qui ne sait pas
  /// écrire — même mécanisme de dictée vocale que "Nouveau client".
  Future<void> _basculerDicteeRecherche() async {
    if (_enEcoute) {
      await _dicteeVocale.stop();
      if (mounted) setState(() => _enEcoute = false);
      return;
    }

    if (!_dicteeDisponible) {
      _dicteeDisponible = await _dicteeVocale.initialize(
        onStatus: (statut) {
          if ((statut == 'done' || statut == 'notListening') && mounted) {
            setState(() => _enEcoute = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _enEcoute = false);
        },
      );
      if (!_dicteeDisponible) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dictée vocale indisponible sur cet appareil.')),
          );
        }
        return;
      }
    }

    setState(() => _enEcoute = true);
    await _dicteeVocale.listen(
      localeId: 'fr_FR',
      onResult: (resultat) {
        _rechercheCtrl.text = resultat.recognizedWords;
        _rechercheCtrl.selection = TextSelection.collapsed(offset: _rechercheCtrl.text.length);
        setState(() => _requete = resultat.recognizedWords);
      },
    );
  }

  /// Supprime [client] après confirmation — réservé au propriétaire, même
  /// principe et même suppression immédiate (y compris hors-ligne) que
  /// EcranFicheClient._supprimerClient.
  Future<void> _confirmerSuppression(BuildContext context, Client client) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce client ?'),
        content: Text(
          'Cette action supprime définitivement "${client.nomComplet}", ainsi que '
          'toutes ses mesures, photos et rendez-vous. '
          '${phraseDevenirFinances(client.createdAt)} '
          'Impossible à annuler.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: _bleuSeda),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB3261E)),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirme != true || !mounted) return;

    try {
      await ref.read(clientsRepositoryProvider).supprimerClient(client);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultats = ref.watch(rechercheClientsProvider(_requete));
    final estProprietaire = ref.watch(estProprietaireProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes clients'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _rechercheCtrl,
              onChanged: (valeur) => setState(() => _requete = valeur),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou téléphone',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: IconButton(
                  icon: Icon(
                    _enEcoute ? Icons.mic : Icons.mic_none,
                    color: _enEcoute ? Colors.red : Colors.white70,
                  ),
                  tooltip: 'Rechercher à la voix',
                  onPressed: _basculerDicteeRecherche,
                ),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: resultats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erreur, _) => Center(child: Text('Erreur : $erreur')),
        data: (clients) {
          if (clients.isEmpty) {
            return Center(
              child: Text(
                _requete.isEmpty ? 'Aucun client pour le moment.' : 'Aucun résultat.',
              ),
            );
          }
          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _bleuSeda,
                  child: Text(
                    client.nom.isNotEmpty ? client.nom[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(client.nomComplet),
                subtitle: client.telephone != null ? Text(client.telephone!) : null,
                onTap: () => context.push(AppRoutes.ficheClient(client.id)),
                onLongPress:
                    estProprietaire ? () => _confirmerSuppression(context, client) : null,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.creationClient),
        backgroundColor: _orangeSeda,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text('Nouveau client', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
