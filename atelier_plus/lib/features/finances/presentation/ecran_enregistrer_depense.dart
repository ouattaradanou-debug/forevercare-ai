import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/finances_providers.dart';

/// Bleu/orange du logo SEDA Tech, repris pour les écrans de dépenses.
const Color _bleuSeda = Color(0xFF1B4FA0);
const Color _orangeSeda = Color(0xFFF5821F);

/// Enregistre une dépense de l'atelier (loyer, fournitures, etc.), prise en
/// compte dans l'écran "Suivi des finances".
///
/// Ouvert à tout utilisateur connecté (propriétaire ou apprenti) — le
/// compte d'un apprenti est identique à celui du propriétaire pour le
/// travail quotidien.
class EcranEnregistrerDepense extends ConsumerStatefulWidget {
  const EcranEnregistrerDepense({super.key});

  @override
  ConsumerState<EcranEnregistrerDepense> createState() => _EcranEnregistrerDepenseState();
}

class _EcranEnregistrerDepenseState extends ConsumerState<EcranEnregistrerDepense> {
  final _montantCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _chargement = false;
  String? _erreur;

  final _dicteeVocale = stt.SpeechToText();
  bool _dicteeDisponible = false;
  String? _champEnDictee;

  @override
  void dispose() {
    _montantCtrl.dispose();
    _descriptionCtrl.dispose();
    _dicteeVocale.stop();
    super.dispose();
  }

  /// Même mécanisme de dictée que dans "Nouveau client" : un tailleur qui
  /// ne sait pas écrire peut dicter le montant (chiffres uniquement) ou la
  /// description (texte libre). Un seul champ à la fois.
  Future<void> _basculerDictee(
    String champ,
    TextEditingController controleur, {
    bool chiffresSeulement = false,
  }) async {
    if (_champEnDictee == champ) {
      await _dicteeVocale.stop();
      if (mounted) setState(() => _champEnDictee = null);
      return;
    }
    if (_champEnDictee != null) await _dicteeVocale.stop();

    if (!_dicteeDisponible) {
      _dicteeDisponible = await _dicteeVocale.initialize(
        onStatus: (statut) {
          if ((statut == 'done' || statut == 'notListening') && mounted) {
            setState(() => _champEnDictee = null);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _champEnDictee = null);
        },
      );
    }
    if (!_dicteeDisponible) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dictée vocale indisponible sur cet appareil.')),
        );
      }
      return;
    }

    setState(() => _champEnDictee = champ);
    await _dicteeVocale.listen(
      localeId: 'fr_FR',
      onResult: (resultat) {
        var texte = resultat.recognizedWords;
        if (chiffresSeulement) {
          texte = texte.replaceAll(RegExp(r'[^0-9]'), '');
        }
        controleur.text = texte;
        controleur.selection = TextSelection.collapsed(offset: controleur.text.length);
      },
    );
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
    final montant = double.tryParse(_montantCtrl.text.replaceAll(',', '.'));
    if (montant == null || montant <= 0) {
      setState(() => _erreur = 'Entrez un montant valide.');
      return;
    }
    setState(() {
      _chargement = true;
      _erreur = null;
    });

    try {
      final utilisateur = await utilisateurCourantRequis(ref);
      final description = _descriptionCtrl.text.trim();
      await ref.read(financesRepositoryProvider).ajouterDepense(
            atelierId: utilisateur.atelierId,
            montant: montant,
            description: description.isEmpty ? null : description,
            date: _date,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _erreur = e.toString());
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enregistrer une dépense'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _montantCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Montant (FCFA)',
                  prefixIcon: IconButton(
                    icon: Icon(_champEnDictee == 'montant' ? Icons.mic : Icons.mic_none),
                    color: _champEnDictee == 'montant' ? Colors.red : _bleuSeda,
                    onPressed: () =>
                        _basculerDictee('montant', _montantCtrl, chiffresSeulement: true),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionCtrl,
                decoration: InputDecoration(
                  labelText: 'Description (optionnel)',
                  prefixIcon: IconButton(
                    icon: Icon(_champEnDictee == 'description' ? Icons.mic : Icons.mic_none),
                    color: _champEnDictee == 'description' ? Colors.red : _bleuSeda,
                    onPressed: () => _basculerDictee('description', _descriptionCtrl),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined, color: _bleuSeda),
                title: const Text('Date'),
                subtitle: Text(Formatters.dateLongue(_date)),
                onTap: _choisirDate,
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
                    : const Text('Enregistrer'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push(AppRoutes.historiqueDepenses),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _bleuSeda,
                  side: const BorderSide(color: _bleuSeda),
                ),
                child: const Text('Historique des dépenses'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
