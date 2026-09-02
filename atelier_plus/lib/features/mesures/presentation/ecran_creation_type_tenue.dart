import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/validators.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/gabarits_providers.dart';

class EcranCreationTypeTenue extends ConsumerStatefulWidget {
  const EcranCreationTypeTenue({super.key});

  @override
  ConsumerState<EcranCreationTypeTenue> createState() => _EcranCreationTypeTenueState();
}

class _EcranCreationTypeTenueState extends ConsumerState<EcranCreationTypeTenue> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  String _sexe = 'femme';
  bool _chargement = false;
  String? _erreur;

  @override
  void dispose() {
    _nomCtrl.dispose();
    super.dispose();
  }

  Future<void> _creer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _chargement = true;
      _erreur = null;
    });

    try {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      final type = await ref.read(gabaritsRepositoryProvider).creerTypePersonnalise(
            atelierId: utilisateur!.atelierId,
            nom: _nomCtrl.text.trim(),
            sexe: _sexe,
          );
      if (mounted) context.pushReplacement(AppRoutes.gestionChampsTypeTenue(type.id), extra: type);
    } catch (e) {
      setState(() => _erreur = e.toString());
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau type de tenue')),
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
                  decoration: const InputDecoration(labelText: 'Nom du type de tenue'),
                  validator: Validators.nomRequis,
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'femme', label: Text('Femme')),
                    ButtonSegment(value: 'homme', label: Text('Homme')),
                    ButtonSegment(value: 'mixte', label: Text('Mixte')),
                  ],
                  selected: {_sexe},
                  onSelectionChanged: (selection) => setState(() => _sexe = selection.first),
                ),
                if (_erreur != null) ...[
                  const SizedBox(height: 8),
                  Text(_erreur!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _chargement ? null : _creer,
                  child: _chargement
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Créer et ajouter des champs'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
