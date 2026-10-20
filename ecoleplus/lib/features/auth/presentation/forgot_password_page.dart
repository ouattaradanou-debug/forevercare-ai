import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotState();
}

class _ForgotState extends ConsumerState<ForgotPasswordPage> {
  final _login = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;

  @override
  void dispose() {
    _login.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _busy = true);
    final ok = await avecMessage(context, () async {
      await ref.read(authServiceProvider).sendRecoveryCode(_login.text);
      return true;
    });
    if (mounted) {
      setState(() {
        _busy = false;
        _codeSent = ok ?? false;
      });
    }
  }

  Future<void> _confirm() async {
    setState(() => _busy = true);
    await avecMessage(
      context,
      () => ref
          .read(authServiceProvider)
          .confirmRecovery(_login.text, _code.text, _password.text),
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mot de passe oublié')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Si vous vous connectez avec une adresse e-mail, nous vous '
            'envoyons un code. Avec un numéro de téléphone ou un '
            'identifiant, c’est votre directeur qui vous donne un nouveau '
            'mot de passe.',
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('login'),
            controller: _login,
            enabled: !_codeSent,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone, e-mail ou identifiant',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (!_codeSent)
            BigButton(
              icon: Icons.mark_email_unread_outlined,
              label: 'Recevoir un code',
              onPressed: _busy ? null : _send,
            )
          else ...[
            const Text('Saisissez le code reçu par e-mail :'),
            const SizedBox(height: 8),
            TextField(
              key: const Key('code'),
              controller: _code,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Code à 6 chiffres',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('new-password'),
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nouveau mot de passe (8 caractères au moins)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            BigButton(
              icon: Icons.lock_reset,
              label: 'Changer mon mot de passe',
              onPressed: _busy ? null : _confirm,
            ),
          ],
        ],
      ),
    ),
  );
}
