import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/validators.dart';
import '../../../data/sync/synchronisation_initiale.dart';
import '../data/identifiants_connexion_memorises.dart';
import '../providers/auth_providers.dart';

class EcranConnexion extends ConsumerStatefulWidget {
  const EcranConnexion({super.key});

  @override
  ConsumerState<EcranConnexion> createState() => _EcranConnexionState();
}

class _EcranConnexionState extends ConsumerState<EcranConnexion> {
  final _formKey = GlobalKey<FormState>();
  final _telephoneCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _chargement = false;
  String? _erreur;
  bool _pinVisible = false;

  @override
  void initState() {
    super.initState();
    // Pré-remplit avec le numéro/PIN de la dernière connexion réussie sur
    // cet appareil (voir IdentifiantsConnexionMemorises) : le tailleur n'a
    // ainsi plus besoin de les retaper après une déconnexion explicite.
    Future.microtask(() async {
      final identifiants = await IdentifiantsConnexionMemorises.charger();
      if (identifiants != null && mounted) {
        setState(() {
          _telephoneCtrl.text = identifiants.$1;
          _pinCtrl.text = identifiants.$2;
        });
      }
    });
  }

  @override
  void dispose() {
    _telephoneCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _connecter() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _chargement = true;
      _erreur = null;
    });

    // Capturé avant l'await : la redirection automatique du routeur (sur
    // apparition de la session) peut disposer cet écran pendant l'attente,
    // rendant `ref` inutilisable ensuite — le conteneur, lui, survit.
    final conteneur = ProviderScope.containerOf(context, listen: false);

    try {
      final utilisateur = await ref.read(authRepositoryProvider).connecter(
            telephone: _telephoneCtrl.text,
            pin: _pinCtrl.text,
          );
      unawaited(
        IdentifiantsConnexionMemorises.enregistrer(
          telephone: _telephoneCtrl.text,
          pin: _pinCtrl.text,
        ),
      );
      // Même risque de course que sur l'écran de création de compte : la
      // redirection automatique du routeur peut précéder l'écriture du
      // cache local par recupererDonneesApresConnexion().
      conteneur.invalidate(utilisateurCourantProvider);
      if (mounted) context.go(AppRoutes.accueil);
      // Volontairement non attendu avant la redirection : la connexion sur
      // un nouvel appareil (perte de téléphone, changement d'appareil) doit
      // rouvrir l'application tout de suite, pas rester bloquée le temps de
      // tout retélécharger. Les écrans concernés lisent déjà le cache local
      // en flux (`watch`) et affichent donc les données au fur et à mesure
      // qu'elles arrivent, sans action supplémentaire de l'utilisateur.
      unawaited(synchroniserIntegralementApresConnexion(conteneur, utilisateur.atelierId));
    } catch (e) {
      if (mounted) setState(() => _erreur = e.toString());
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.content_cut, size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Atelier +',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Image.asset('assets/images/logo_seda_tech.png', height: 36),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _telephoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de téléphone',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: Validators.telephone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pinCtrl,
                    keyboardType: TextInputType.number,
                    obscureText: !_pinVisible,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Code PIN (6 chiffres)',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_pinVisible ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _pinVisible = !_pinVisible),
                      ),
                    ),
                    validator: Validators.pin,
                  ),
                  if (_erreur != null) ...[
                    const SizedBox(height: 8),
                    Text(_erreur!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _chargement ? null : _connecter,
                    child: _chargement
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Se connecter'),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed:
                        _chargement ? null : () => context.push(AppRoutes.pinOublie),
                    child: const Text('Code PIN oublié ?'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _chargement
                        ? null
                        : () => context.push(AppRoutes.creationCompte),
                    child: const Text('Créer un compte atelier'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
