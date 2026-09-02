import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validators.dart';
import '../providers/auth_providers.dart';

class EcranCreationApprenti extends ConsumerStatefulWidget {
  const EcranCreationApprenti({super.key});

  @override
  ConsumerState<EcranCreationApprenti> createState() => _EcranCreationApprentiState();
}

class _EcranCreationApprentiState extends ConsumerState<EcranCreationApprenti> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  late final String _pinProvisoire;

  bool _chargement = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _pinProvisoire = _genererPin();
  }

  static String _genererPin() {
    final aleatoire = Random.secure();
    return List.generate(6, (_) => aleatoire.nextInt(10)).join();
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telephoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _creerApprenti() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _chargement = true;
      _erreur = null;
    });

    try {
      await ref.read(apprentiRepositoryProvider).creerApprenti(
            nom: _nomCtrl.text.trim(),
            telephone: _telephoneCtrl.text,
            pinProvisoire: _pinProvisoire,
          );
      if (mounted) _afficherPinAConfirmer();
    } catch (e) {
      setState(() => _erreur = e.toString());
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  void _afficherPinAConfirmer() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Compte apprenti créé'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Communiquez ces identifiants à l\'apprenti maintenant :'),
            const SizedBox(height: 12),
            Text('Téléphone : ${_telephoneCtrl.text}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Code PIN : $_pinProvisoire',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 12),
            const Text(
              'Ce code ne sera plus jamais affiché par l\'application. '
              'Notez-le avant de continuer.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('J\'ai noté'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel apprenti')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nomCtrl,
                  decoration: const InputDecoration(labelText: 'Nom de l\'apprenti'),
                  validator: Validators.nomRequis,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telephoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de téléphone provisoire',
                    helperText: 'Ce numéro servira d\'identifiant de connexion.',
                  ),
                  validator: Validators.telephone,
                ),
                if (_erreur != null) ...[
                  const SizedBox(height: 8),
                  Text(_erreur!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _chargement ? null : _creerApprenti,
                  child: _chargement
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Créer le compte'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
