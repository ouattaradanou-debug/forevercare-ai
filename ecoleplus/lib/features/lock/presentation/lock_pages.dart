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

/// Choix de la façon d'ouvrir l'application (première connexion, ou depuis
/// « Mon compte ») : l'empreinte OU un code, jamais les deux.
class CreatePinPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<CreatePinPage> createState() => _CreatePinState();
}

class _CreatePinState extends ConsumerState<CreatePinPage> {
  /// null : capteur pas encore interrogé.
  bool? _capteur;
  bool _avecCode = false;
  String? _premier;
  String? _message;
  bool _occupe = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      ref.read(biometricGateProvider).disponible().then((v) {
        if (mounted) setState(() => _capteur = v);
      }),
    );
  }

  Future<void> _choisirEmpreinte() async {
    setState(() {
      _occupe = true;
      _message = null;
    });
    final r = await ref.read(biometricGateProvider).authentifier();
    if (!mounted) return;
    if (!r.ok) {
      setState(() {
        _occupe = false;
        _message = r.message == null
            ? null
            : '${r.message} Vous pouvez aussi choisir plutôt un code.';
      });
      return;
    }
    await ref.read(lockServiceProvider).definirEmpreinte();
    _termine();
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
    await ref.read(lockServiceProvider).definir(code);
    _termine();
  }

  void _termine() {
    ref.read(lockedProvider.notifier).unlock();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final capteur = _capteur;
    final enChoix = (capteur ?? false) && !_avecCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          enChoix ? 'Ouverture de l’application' : 'Code de verrouillage',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (capteur == null)
              const Center(child: CircularProgressIndicator())
            else if (enChoix) ...[
              Text(
                'Comment voulez-vous ouvrir EcolePlus ? Ce sera demandé à '
                'chaque ouverture : si le téléphone est prêté ou volé, les '
                'données de l’école restent protégées.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              BigButton(
                icon: Icons.fingerprint,
                label: 'Avec mon empreinte',
                onPressed: _occupe ? null : _choisirEmpreinte,
              ),
              const SizedBox(height: 8),
              const Text(
                'Si l’empreinte ne passe pas (doigt mouillé, capteur abîmé), '
                'le téléphone propose son code ou son schéma habituel.',
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                key: const Key('choisir-code'),
                icon: const Icon(Icons.pin_outlined),
                label: const Text('Avec un code de 4 à 6 chiffres'),
                onPressed: _occupe
                    ? null
                    : () => setState(() {
                        _avecCode = true;
                        _message = null;
                      }),
              ),
            ] else ...[
              Text(
                _premier == null
                    ? 'Choisissez un code de 4 à 6 chiffres. Il sera demandé '
                          'à chaque ouverture de l’application : si le '
                          'téléphone est prêté ou volé, les données de l’école '
                          'restent protégées.'
                    : 'Tapez le même code une seconde fois, puis ✓.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(
                _message!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (capteur != null && !enChoix) ...[
              const SizedBox(height: 16),
              PinPad(key: ValueKey(_premier == null), onSubmit: _saisi),
              if (capteur)
                TextButton(
                  onPressed: () => setState(() {
                    _avecCode = false;
                    _premier = null;
                    _message = null;
                  }),
                  child: const Text('Utiliser plutôt mon empreinte'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Écran verrouillé : le code, ou l'empreinte, selon le choix fait.
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

  Future<void> _empreinte({bool demandee = false}) async {
    final lock = await ref.read(lockServiceProvider).get();
    if (lock == null || !lock.empreinteSeule) return;
    final r = await ref.read(biometricGateProvider).authentifier();
    if (r.ok) {
      await ref.read(lockServiceProvider).reussiteBiometrie();
      ref.read(lockedProvider.notifier).unlock();
    } else if (mounted && (demandee || r.message != null)) {
      // Raison claire (trop d'essais, aucune empreinte enregistrée…) au
      // lieu d'un échec muet.
      setState(() => _message = r.message);
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
    final empreinte = lock?.empreinteSeule ?? false;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Icon(
              empreinte ? Icons.fingerprint : Icons.lock_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Bonjour ${session?.displayName ?? ''}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              empreinte
                  ? 'Posez votre doigt sur le capteur'
                  : 'Tapez votre code',
              textAlign: TextAlign.center,
            ),
            if (_message != null) ...[
              const SizedBox(height: 8),
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            if (empreinte)
              BigButton(
                icon: Icons.fingerprint,
                label: 'Ouvrir avec mon empreinte',
                onPressed: () => _empreinte(demandee: true),
              )
            else
              PinPad(onSubmit: _code, enabled: !_occupe),
            TextButton(
              onPressed: () => context.go('/verrouille/mot-de-passe'),
              child: Text(empreinte ? 'Empreinte refusée ?' : 'Code oublié ?'),
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
    appBar: AppBar(title: const Text('Ouvrir avec le mot de passe')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Tapez le mot de passe de votre compte, puis choisissez à nouveau '
            'votre code ou votre empreinte. Il faut une connexion Internet. '
            'Vos données restent sur le téléphone.',
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
