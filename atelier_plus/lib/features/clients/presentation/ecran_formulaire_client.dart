import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/client.dart';
import '../providers/clients_providers.dart';

/// Modification d'une fiche client existante (la création passe par
/// EcranNouveauClient, qui combine infos/mesures/photos/finances/
/// rendez-vous en un seul écran).
class EcranFormulaireClient extends ConsumerStatefulWidget {
  const EcranFormulaireClient({super.key, required this.clientExistant});

  final Client clientExistant;

  @override
  ConsumerState<EcranFormulaireClient> createState() => _EcranFormulaireClientState();
}

class _EcranFormulaireClientState extends ConsumerState<EcranFormulaireClient> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomCtrl;
  late final TextEditingController _prenomCtrl;
  late final TextEditingController _telephoneCtrl;
  late String _sexe;
  late DateTime _datePriseMesures;
  bool _chargement = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    final client = widget.clientExistant;
    _nomCtrl = TextEditingController(text: client.nom);
    _prenomCtrl = TextEditingController(text: client.prenom);
    _telephoneCtrl = TextEditingController(text: client.telephone);
    _sexe = client.sexe;
    _datePriseMesures = client.datePriseMesures;
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _telephoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final choisie = await showDatePicker(
      context: context,
      initialDate: _datePriseMesures,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (choisie != null) setState(() => _datePriseMesures = choisie);
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _chargement = true;
      _erreur = null;
    });

    try {
      final repo = ref.read(clientsRepositoryProvider);
      final client = await repo.modifierClient(
        widget.clientExistant,
        nom: _nomCtrl.text.trim(),
        prenom: _prenomCtrl.text.trim(),
        telephone: _telephoneCtrl.text.trim(),
        sexe: _sexe,
        datePriseMesures: _datePriseMesures,
      );
      if (mounted) context.pushReplacement(AppRoutes.ficheClient(client.id));
    } catch (e) {
      setState(() => _erreur = e.toString());
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le client')),
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
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: Validators.nomRequis,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _prenomCtrl,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                  validator: Validators.nomRequis,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telephoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Contact (téléphone)'),
                  validator: Validators.nomRequis,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Date de prise des mesures'),
                  subtitle: Text(Formatters.dateLongue(_datePriseMesures)),
                  onTap: _choisirDate,
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'femme', label: Text('Femme')),
                    ButtonSegment(value: 'homme', label: Text('Homme')),
                  ],
                  selected: {_sexe},
                  onSelectionChanged: (selection) {
                    setState(() => _sexe = selection.first);
                  },
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
      ),
    );
  }
}
