import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/auth/questions_secretes.dart';
import '../../core/constants/roles.dart';
import '../../core/constants/type_cave.dart';

/// Configuration initiale de la cave (point 1 du cahier des charges) et
/// création du premier compte (Propriétaire ou Propriétaire/Gérant, point
/// 2.2 : jamais les deux séparément dans la même cave).
///
/// Un seul écran, une seule action principale ("Créer ma cave"), pas de
/// formulaire long : seulement les champs explicitement demandés par le
/// cahier des charges (nom, téléphone, localisation).
class CaveSetupScreen extends ConsumerStatefulWidget {
  const CaveSetupScreen({super.key});

  @override
  ConsumerState<CaveSetupScreen> createState() => _CaveSetupScreenState();
}

class _CaveSetupScreenState extends ConsumerState<CaveSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  TypeCave _typeCave = TypeCave.vin;
  RoleUtilisateur _role = RoleUtilisateur.proprietaireGerant;

  final _nomCaveCtrl = TextEditingController();
  final _telephoneCaveCtrl = TextEditingController();
  final _localisationCtrl = TextEditingController();

  final _prenomCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _telephoneUtilisateurCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _reponseSecreteCtrl = TextEditingController();

  String _questionSecrete = questionsSecretesDisponibles.first;

  bool _enCours = false;
  String? _erreur;

  @override
  void dispose() {
    _nomCaveCtrl.dispose();
    _telephoneCaveCtrl.dispose();
    _localisationCtrl.dispose();
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _telephoneUtilisateurCtrl.dispose();
    _pinCtrl.dispose();
    _reponseSecreteCtrl.dispose();
    super.dispose();
  }

  Future<void> _creerLaCave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _enCours = true;
      _erreur = null;
    });

    try {
      await ref.read(authServiceProvider).creerCaveEtProprietaire(
            nomCave: _nomCaveCtrl.text.trim(),
            typeCave: _typeCave,
            telephoneCave: _telephoneCaveCtrl.text.trim(),
            localisation: _localisationCtrl.text.trim(),
            nomUtilisateur: _nomCtrl.text.trim(),
            prenomUtilisateur: _prenomCtrl.text.trim(),
            telephoneUtilisateur: _telephoneUtilisateurCtrl.text.trim(),
            role: _role,
            pin: _pinCtrl.text.trim(),
            questionSecrete: _questionSecrete,
            reponseSecrete: _reponseSecreteCtrl.text.trim(),
          );
      ref.invalidate(profilActuelProvider);
    } catch (e) {
      setState(() => _erreur = 'Impossible de créer la cave : $e');
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurer ma cave')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Type de cave',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                RadioGroup<TypeCave>(
                  groupValue: _typeCave,
                  onChanged: (v) => setState(() => _typeCave = v!),
                  child: Column(
                    children: TypeCave.values
                        .map((type) => RadioListTile<TypeCave>(
                            title: Text(type.libelle), value: type))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nomCaveCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Nom de la cave'),
                  validator: _valideurObligatoire,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telephoneCaveCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Numéro de téléphone de la cave'),
                  keyboardType: TextInputType.phone,
                  validator: _valideurObligatoire,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _localisationCtrl,
                  decoration: const InputDecoration(labelText: 'Localisation'),
                  validator: _valideurObligatoire,
                ),
                const SizedBox(height: 24),
                Text('Votre profil',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                RadioGroup<RoleUtilisateur>(
                  groupValue: _role,
                  onChanged: (v) => setState(() => _role = v!),
                  child: const Column(
                    children: [
                      RadioListTile<RoleUtilisateur>(
                        title: Text(
                            'Propriétaire/Gérant (je gère seul(e) ma cave)'),
                        value: RoleUtilisateur.proprietaireGerant,
                      ),
                      RadioListTile<RoleUtilisateur>(
                        title: Text(
                            'Propriétaire (je désignerai un Gérant séparé)'),
                        value: RoleUtilisateur.proprietaire,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _prenomCtrl,
                  decoration: const InputDecoration(labelText: 'Votre prénom'),
                  validator: _valideurObligatoire,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nomCtrl,
                  decoration: const InputDecoration(labelText: 'Votre nom'),
                  validator: _valideurObligatoire,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telephoneUtilisateurCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Votre numéro de téléphone'),
                  keyboardType: TextInputType.phone,
                  validator: _valideurObligatoire,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pinCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Code PIN (6 chiffres)'),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  validator: (v) => (v == null || v.trim().length < 6)
                      ? 'Au moins 6 chiffres'
                      : null,
                ),
                const SizedBox(height: 24),
                Text('En cas de code PIN oublié',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _questionSecrete,
                  isExpanded: true,
                  decoration:
                      const InputDecoration(labelText: 'Question secrète'),
                  items: questionsSecretesDisponibles
                      .map((q) => DropdownMenuItem(
                            value: q,
                            child: Text(q,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _questionSecrete = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reponseSecreteCtrl,
                  decoration: const InputDecoration(labelText: 'Votre réponse'),
                  validator: _valideurObligatoire,
                ),
                if (_erreur != null) ...[
                  const SizedBox(height: 12),
                  Text(_erreur!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _enCours ? null : _creerLaCave,
                  child: _enCours
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Créer ma cave'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _valideurObligatoire(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null;
}
