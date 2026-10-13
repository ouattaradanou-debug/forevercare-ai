import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/validators.dart';
import '../data/identifiants_connexion_memorises.dart';
import '../providers/auth_providers.dart';

/// Récupération du compte propriétaire en cas de code PIN oublié, via la
/// question secrète définie à la création du compte (voir
/// AuthRepository.creerCompteAtelier / reinitialiserPinAvecReponseSecrete).
/// Fonctionne sans session active — c'est tout l'intérêt, le tailleur a
/// justement perdu l'accès à son compte.
class EcranPinOublie extends ConsumerStatefulWidget {
  const EcranPinOublie({super.key});

  @override
  ConsumerState<EcranPinOublie> createState() => _EcranPinOublieState();
}

class _EcranPinOublieState extends ConsumerState<EcranPinOublie> {
  final _formKeyTelephone = GlobalKey<FormState>();
  final _formKeyReponse = GlobalKey<FormState>();
  final _telephoneCtrl = TextEditingController();
  final _reponseCtrl = TextEditingController();
  final _nouveauPinCtrl = TextEditingController();
  final _confirmationPinCtrl = TextEditingController();

  bool _chargement = false;
  String? _erreur;

  // Une fois la question récupérée, l'étape 2 (réponse + nouveau PIN)
  // s'affiche à la place de la demande de numéro de téléphone.
  String? _question;

  @override
  void dispose() {
    _telephoneCtrl.dispose();
    _reponseCtrl.dispose();
    _nouveauPinCtrl.dispose();
    _confirmationPinCtrl.dispose();
    super.dispose();
  }

  Future<void> _recupererQuestion() async {
    if (!_formKeyTelephone.currentState!.validate()) return;
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    try {
      final question =
          await ref.read(authRepositoryProvider).questionSecretePour(_telephoneCtrl.text);
      if (mounted) setState(() => _question = question);
    } catch (e) {
      if (mounted) setState(() => _erreur = e.toString());
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  Future<void> _reinitialiserPin() async {
    if (!_formKeyReponse.currentState!.validate()) return;
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    try {
      await ref.read(authRepositoryProvider).reinitialiserPinAvecReponseSecrete(
            telephone: _telephoneCtrl.text,
            reponse: _reponseCtrl.text,
            nouveauPin: _nouveauPinCtrl.text,
          );
      // Met à jour le préremplissage de l'écran de connexion avec le
      // nouveau PIN — sinon il resterait pré-rempli avec l'ancien, désormais
      // invalide, mémorisé lors d'une connexion précédente sur cet appareil.
      unawaited(
        IdentifiantsConnexionMemorises.enregistrer(
          telephone: _telephoneCtrl.text,
          pin: _nouveauPinCtrl.text,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code PIN réinitialisé. Connectez-vous avec le nouveau code.'),
          ),
        );
        context.go(AppRoutes.connexion);
      }
    } catch (e) {
      if (mounted) setState(() => _erreur = e.toString());
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Code PIN oublié')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _question == null ? _etapeTelephone() : _etapeReponse(),
          ),
        ),
      ),
    );
  }

  Widget _etapeTelephone() {
    return Form(
      key: _formKeyTelephone,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Entrez le numéro de téléphone de votre compte pour retrouver votre '
            'question secrète.',
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _telephoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone',
              prefixIcon: Icon(Icons.phone),
            ),
            validator: Validators.telephone,
          ),
          if (_erreur != null) ...[
            const SizedBox(height: 8),
            Text(_erreur!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _chargement ? null : _recupererQuestion,
            child: _chargement
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  Widget _etapeReponse() {
    return Form(
      key: _formKeyReponse,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_question!, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextFormField(
            controller: _reponseCtrl,
            decoration: const InputDecoration(labelText: 'Votre réponse'),
            validator: Validators.nomRequis,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nouveauPinCtrl,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: const InputDecoration(labelText: 'Nouveau code PIN (6 chiffres)'),
            validator: Validators.pin,
          ),
          TextFormField(
            controller: _confirmationPinCtrl,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: const InputDecoration(labelText: 'Confirmer le nouveau code PIN'),
            validator: (valeur) => Validators.confirmationPin(_nouveauPinCtrl.text, valeur),
          ),
          if (_erreur != null) ...[
            const SizedBox(height: 8),
            Text(_erreur!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _chargement ? null : _reinitialiserPin,
            child: _chargement
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Réinitialiser le code PIN'),
          ),
        ],
      ),
    );
  }
}
