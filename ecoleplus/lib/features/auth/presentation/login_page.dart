import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/auth/data/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _login = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;
  bool _busy = false;

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final outcome = await avecMessage(
      context,
      () => ref.read(authServiceProvider).login(_login.text, _password.text),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (outcome is NoSchool) {
      final create = await confirmer(
        context,
        titre: 'Aucune école',
        message:
            'Votre compte n’est rattaché à aucune école. Si vous êtes '
            'directeur, vous pouvez créer votre école maintenant. Sinon, '
            'demandez à votre directeur de vous ajouter.',
        bouton: 'Créer mon école',
      );
      if (create && mounted) context.go('/creer-ecole');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Se connecter')),
    body: SafeArea(
      child: AutofillGroup(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              key: const Key('login'),
              controller: _login,
              autofillHints: const [AutofillHints.username],
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone, e-mail ou identifiant',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('password'),
              controller: _password,
              obscureText: _hidden,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: _hidden
                      ? 'Afficher le mot de passe'
                      : 'Cacher le mot de passe',
                  icon: Icon(_hidden ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _hidden = !_hidden),
                ),
              ),
            ),
            const SizedBox(height: 24),
            BigButton(
              icon: Icons.login,
              label: _busy ? 'Connexion…' : 'Se connecter',
              onPressed: _busy ? null : _submit,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.push('/mot-de-passe-oublie'),
              child: const Text('Mot de passe oublié ?'),
            ),
            const SizedBox(height: 12),
            const Text(
              'La première connexion sur ce téléphone a besoin d’Internet. '
              'Ensuite, l’application fonctionne aussi sans connexion.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
