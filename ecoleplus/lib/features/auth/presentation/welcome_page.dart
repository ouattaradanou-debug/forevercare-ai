import 'package:ecoleplus/app/app.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.school,
              size: 96,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Bienvenue dans $appName',
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'La gestion de votre école, même sans Internet.',
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            BigButton(
              icon: Icons.login,
              label: 'Se connecter',
              onPressed: () => context.push('/connexion'),
            ),
            const SizedBox(height: 16),
            BigButton(
              icon: Icons.add_business,
              label: 'Créer mon école',
              onPressed: () => context.push('/creer-ecole'),
            ),
            const SizedBox(height: 24),
            Text(
              'Enseignant ou secrétaire ? Votre directeur vous donne votre '
              'identifiant et votre mot de passe.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
