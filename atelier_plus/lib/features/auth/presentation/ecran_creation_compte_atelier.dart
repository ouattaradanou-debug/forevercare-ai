import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/selecteur_source_image.dart';
import '../providers/auth_providers.dart';

class EcranCreationCompteAtelier extends ConsumerStatefulWidget {
  const EcranCreationCompteAtelier({super.key});

  @override
  ConsumerState<EcranCreationCompteAtelier> createState() =>
      _EcranCreationCompteAtelierState();
}

class _EcranCreationCompteAtelierState
    extends ConsumerState<EcranCreationCompteAtelier> {
  final _formKey = GlobalKey<FormState>();
  final _nomAtelierCtrl = TextEditingController();
  final _nomProprietaireCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _confirmationPinCtrl = TextEditingController();

  XFile? _logo;
  bool _chargement = false;
  String? _erreur;

  @override
  void dispose() {
    _nomAtelierCtrl.dispose();
    _nomProprietaireCtrl.dispose();
    _telephoneCtrl.dispose();
    _pinCtrl.dispose();
    _confirmationPinCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirLogo() async {
    final resultat = await choisirSourceEtImage(context);
    if (resultat != null) setState(() => _logo = resultat.$1);
  }

  Future<void> _creerCompte() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _chargement = true;
      _erreur = null;
    });

    // Capturé avant l'await : la redirection automatique du routeur (sur
    // apparition de la session, dès `signUp`) peut disposer cet écran
    // pendant l'attente, rendant `ref` inutilisable ensuite — le
    // conteneur, lui, survit à la disparition du widget.
    final conteneur = ProviderScope.containerOf(context, listen: false);

    try {
      await ref.read(authRepositoryProvider).creerCompteAtelier(
            nomAtelier: _nomAtelierCtrl.text.trim(),
            nomProprietaire: _nomProprietaireCtrl.text.trim(),
            telephone: _telephoneCtrl.text,
            pin: _pinCtrl.text,
            logo: _logo,
          );
      // Le routeur peut avoir redirigé vers l'accueil avant que le cache
      // local (atelier/utilisateur/rôle) ne soit écrit. Sans cette
      // invalidation, l'écran d'accueil resterait figé sur son premier
      // calcul (utilisateur introuvable) sans jamais se corriger.
      conteneur.invalidate(utilisateurCourantProvider);
      if (mounted) context.go(AppRoutes.accueil);
    } catch (e) {
      if (mounted) setState(() => _erreur = e.toString());
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer mon atelier')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _choisirLogo,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: _logo != null ? FileImage(File(_logo!.path)) : null,
                      child: _logo == null ? const Icon(Icons.add_a_photo, size: 32) : null,
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: _choisirLogo,
                    child: const Text('Logo de l\'atelier (optionnel)'),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nomAtelierCtrl,
                  decoration: const InputDecoration(labelText: 'Nom de l\'atelier'),
                  validator: Validators.nomRequis,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nomProprietaireCtrl,
                  decoration: const InputDecoration(labelText: 'Votre nom'),
                  validator: Validators.nomRequis,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telephoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Numéro de téléphone'),
                  validator: Validators.telephone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pinCtrl,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  decoration: const InputDecoration(labelText: 'Code PIN (6 chiffres)'),
                  validator: Validators.pin,
                ),
                TextFormField(
                  controller: _confirmationPinCtrl,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  decoration: const InputDecoration(labelText: 'Confirmer le code PIN'),
                  validator: (valeur) =>
                      Validators.confirmationPin(_pinCtrl.text, valeur),
                ),
                if (_erreur != null) ...[
                  const SizedBox(height: 8),
                  Text(_erreur!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _chargement ? null : _creerCompte,
                  child: _chargement
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Créer mon compte'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
