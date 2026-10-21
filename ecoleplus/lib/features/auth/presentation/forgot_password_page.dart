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
  final _reponse = TextEditingController();
  final _password = TextEditingController();
  bool _codeSent = false;
  String? _question;
  bool _busy = false;

  @override
  void dispose() {
    _login.dispose();
    _code.dispose();
    _reponse.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() f) async {
    setState(() => _busy = true);
    await avecMessage(context, f);
    if (mounted) setState(() => _busy = false);
  }

  Widget _champ(
    String key,
    TextEditingController c,
    String label, {
    bool cache = false,
    TextInputType? type,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      key: Key(key),
      controller: c,
      obscureText: cache,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mot de passe oublié')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Deux possibilités : répondre à votre question secrète, ou '
            '(si vous vous connectez avec une adresse e-mail) recevoir un '
            'code par e-mail. Sinon, votre directeur peut vous donner un '
            'nouveau mot de passe. Il faut une connexion Internet.',
          ),
          const SizedBox(height: 16),
          _champ('login', _login, 'Numéro de téléphone, e-mail ou identifiant'),
          if (_question == null && !_codeSent) ...[
            BigButton(
              icon: Icons.help_outline,
              label: 'Répondre à ma question secrète',
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                      final q = await ref
                          .read(authServiceProvider)
                          .recoveryQuestion(_login.text);
                      setState(() => _question = q);
                    }),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.mark_email_unread_outlined),
              label: const Text('Recevoir un code par e-mail'),
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                      await ref
                          .read(authServiceProvider)
                          .sendRecoveryCode(_login.text);
                      setState(() => _codeSent = true);
                    }),
            ),
          ],
          if (_question != null) ...[
            Text(_question!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _champ('reponse', _reponse, 'Votre réponse', cache: true),
            _champ(
              'new-password',
              _password,
              'Nouveau mot de passe (8 caractères au moins)',
              cache: true,
            ),
            BigButton(
              icon: Icons.lock_reset,
              label: 'Changer mon mot de passe',
              onPressed: _busy
                  ? null
                  : () => _run(
                      () => ref
                          .read(authServiceProvider)
                          .recoverWithAnswer(
                            _login.text,
                            _reponse.text,
                            _password.text,
                          ),
                    ),
            ),
          ],
          if (_codeSent) ...[
            const Text('Saisissez le code reçu par e-mail :'),
            const SizedBox(height: 8),
            _champ(
              'code',
              _code,
              'Code à 6 chiffres',
              type: TextInputType.number,
            ),
            _champ(
              'new-password',
              _password,
              'Nouveau mot de passe (8 caractères au moins)',
              cache: true,
            ),
            BigButton(
              icon: Icons.lock_reset,
              label: 'Changer mon mot de passe',
              onPressed: _busy
                  ? null
                  : () => _run(
                      () => ref
                          .read(authServiceProvider)
                          .confirmRecovery(
                            _login.text,
                            _code.text,
                            _password.text,
                          ),
                    ),
            ),
          ],
        ],
      ),
    ),
  );
}
