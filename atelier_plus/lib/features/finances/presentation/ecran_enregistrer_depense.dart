import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/finances_providers.dart';

/// Enregistre une dépense de l'atelier (loyer, fournitures, etc.), prise en
/// compte dans l'écran "Suivi des finances".
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

  @override
  void dispose() {
    _montantCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
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
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      final description = _descriptionCtrl.text.trim();
      await ref.read(financesRepositoryProvider).ajouterDepense(
            atelierId: utilisateur!.atelierId,
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
      appBar: AppBar(title: const Text('Enregistrer une dépense')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _montantCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Description (optionnel)'),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
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
                child: _chargement
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
