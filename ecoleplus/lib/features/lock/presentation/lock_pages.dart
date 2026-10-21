import 'dart:async';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/lock/data/lock_service.dart';
import 'package:ecoleplus/features/lock/domain/pin.dart';
import 'package:ecoleplus/features/lock/presentation/lock_providers.dart';
import 'package:ecoleplus/features/lock/presentation/pin_pad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Choix du code (première connexion, ou changement depuis « Mon compte »).
class CreatePinPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<CreatePinPage> createState() => _CreatePinState();
}

class _CreatePinState extends ConsumerState<CreatePinPage> {
  String? _premier;
  String? _message;
  bool _biometrie = false;
  bool _biometrieDisponible = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      ref.read(biometricGateProvider).disponible().then((v) {
        if (mounted) setState(() => _biometrieDisponible = v);
      }),
    );
  }

  Future<void> _saisi(String code) async {
    if (_premier == null) {
      final erreur = validerPin(code);
      setState(() {
        _message = erreur;
        if (erreur == null) _premier = code;
      });
      return;
    }
    if (code != _premier) {
      setState(() {
        _premier = null;
        _message = 'Les deux codes sont différents. Recommencez.';
      });
      return;
    }
    await ref.read(lockServiceProvider).definir(code, biometrie: _biometrie);
    ref.read(lockedProvider.notifier).unlock();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Code de verrouillage')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            _premier == null
                ? 'Choisissez un code de 4 à 6 chiffres. Il sera demandé à '
                      'chaque ouverture de l’application : si le téléphone est '
                      'prêté ou volé, les données de l’école restent protégées.'
                : 'Tapez le même code une seconde fois.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(
              _message!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          PinPad(key: ValueKey(_premier == null), onSubmit: _saisi),
          if (_biometrieDisponible)
            SwitchListTile(
              title: const Text('Ouvrir aussi avec mon empreinte'),
              value: _biometrie,
              onChanged: (v) => setState(() => _biometrie = v),
            ),
        ],
      ),
    ),
  );
}

/// Écran verrouillé : code ou empreinte.
class LockPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<LockPage> createState() => _LockPageState();
}

class _LockPageState extends ConsumerState<LockPage> {
  String? _message;
  bool _occupe = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _empreinte());
  }

  Future<void> _empreinte() async {
    final lock = await ref.read(lockServiceProvider).get();
    if (lock == null || !lock.biometric) return;
    if (await ref.read(biometricGateProvider).authentifier()) {
      await ref.read(lockServiceProvider).reussiteBiometrie();
      ref.read(lockedProvider.notifier).unlock();
    }
  }

  Future<void> _code(String code) async {
    setState(() => _occupe = true);
    final r = await ref.read(lockServiceProvider).verifier(code);
    if (!mounted) return;
    setState(() => _occupe = false);
    switch (r.resultat) {
      case ResultatCode.ok:
        ref.read(lockedProvider.notifier).unlock();
      case ResultatCode.faux:
        setState(() => _message = 'Code incorrect.');
      case ResultatCode.attendre:
        setState(
          () =>
              _message = 'Trop d’erreurs. Réessayez dans ${_duree(r.attente)}.',
        );
      case ResultatCode.motDePasseRequis:
        context.go('/verrouille/mot-de-passe');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value;
    final lock = ref.watch(appLockProvider).value;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Bonjour ${session?.displayName ?? ''}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Text('Tapez votre code', textAlign: TextAlign.center),
            if (_message != null) ...[
              const SizedBox(height: 8),
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            PinPad(onSubmit: _code, enabled: !_occupe),
            if (lock?.biometric ?? false)
              TextButton.icon(
                icon: const Icon(Icons.fingerprint),
                label: const Text('Utiliser mon empreinte'),
                onPressed: _empreinte,
              ),
            TextButton(
              onPressed: () => context.go('/verrouille/mot-de-passe'),
              child: const Text('Code oublié ?'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Code oublié (ou trop d'erreurs) : reconnexion avec le mot de passe.
/// Les données du téléphone, y compris celles non envoyées, sont conservées.
class PasswordUnlockPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<PasswordUnlockPage> createState() => _PasswordUnlockState();
}

class _PasswordUnlockState extends ConsumerState<PasswordUnlockPage> {
  final _password = TextEditingController();
  bool _occupe = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    setState(() => _occupe = true);
    final ok = await avecMessage(context, () async {
      await ref.read(authServiceProvider).reconnectSameUser(_password.text);
      await ref.read(lockServiceProvider).effacer();
      return true;
    });
    if (!mounted) return;
    setState(() => _occupe = false);
    if (ok ?? false) context.go('/code/creer');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Code oublié')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Tapez le mot de passe de votre compte pour choisir un nouveau '
            'code. Il faut une connexion Internet. Vos données restent sur '
            'le téléphone.',
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('password'),
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mot de passe',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          BigButton(
            icon: Icons.lock_open,
            label: 'Valider',
            onPressed: _occupe ? null : _valider,
          ),
          TextButton(
            onPressed: () => context.go('/verrouille'),
            child: const Text('Retour'),
          ),
        ],
      ),
    ),
  );
}

String _duree(Duration d) =>
    d.inMinutes > 0 ? '${d.inMinutes + 1} min' : '${d.inSeconds} s';
