import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_providers.dart';

/// Connexion : téléphone + code secret. Une seule action principale
/// ("Se connecter"). Le lien vers "Configurer ma cave" n'est affiché que
/// pour le tout premier usage de l'appareil (voir router.dart).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telephoneCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  bool _enCours = false;
  String? _erreur;

  @override
  void dispose() {
    _telephoneCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _enCours = true;
      _erreur = null;
    });

    try {
      await ref.read(authServiceProvider).seConnecter(
            telephone: _telephoneCtrl.text.trim(),
            pin: _pinCtrl.text.trim(),
          );
      ref.invalidate(profilActuelProvider);
    } catch (_) {
      setState(() => _erreur = 'Numéro ou code secret incorrect.');
    } finally {
      if (mounted) setState(() => _enCours = false);
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
                  Icon(Icons.local_bar, size: 72, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Ma Cave',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _telephoneCtrl,
                    decoration: const InputDecoration(labelText: 'Numéro de téléphone'),
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pinCtrl,
                    decoration: const InputDecoration(labelText: 'Code secret'),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
                  ),
                  if (_erreur != null) ...[
                    const SizedBox(height: 12),
                    Text(_erreur!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _enCours ? null : _seConnecter,
                    child: _enCours
                        ? const SizedBox(
                            height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Se connecter'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/configuration-cave'),
                    child: const Text('Première utilisation ? Configurer ma cave'),
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
