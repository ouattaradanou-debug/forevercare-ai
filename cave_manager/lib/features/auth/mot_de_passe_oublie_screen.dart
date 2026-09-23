import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_providers.dart';

enum _Etape { telephone, reponse, nouveauPin }

/// Récupération de code PIN par question secrète (voir
/// `supabase/migrations/0002_recuperation_pin.sql` et
/// `0005_verifier_reponse_secrete.sql` pour la logique serveur). Trois
/// étapes affichées l'une après l'autre sur le même écran, chacune avec
/// une seule action principale : "Continuer", puis "Vérifier", puis
/// "Réinitialiser mon code". Les champs du nouveau PIN ne s'affichent
/// qu'après confirmation que la réponse est correcte (demandé
/// explicitement — auparavant tout était affiché en même temps).
class MotDePasseOublieScreen extends ConsumerStatefulWidget {
  const MotDePasseOublieScreen({super.key});

  @override
  ConsumerState<MotDePasseOublieScreen> createState() =>
      _MotDePasseOublieScreenState();
}

class _MotDePasseOublieScreenState
    extends ConsumerState<MotDePasseOublieScreen> {
  final _formKeyTelephone = GlobalKey<FormState>();
  final _formKeyReponse = GlobalKey<FormState>();
  final _formKeyNouveauPin = GlobalKey<FormState>();

  final _telephoneCtrl = TextEditingController();
  final _reponseCtrl = TextEditingController();
  final _nouveauPinCtrl = TextEditingController();
  final _confirmationPinCtrl = TextEditingController();

  _Etape _etape = _Etape.telephone;
  String? _question;
  bool _enCours = false;
  String? _erreur;

  @override
  void dispose() {
    _telephoneCtrl.dispose();
    _reponseCtrl.dispose();
    _nouveauPinCtrl.dispose();
    _confirmationPinCtrl.dispose();
    super.dispose();
  }

  Future<void> _rechercherQuestion() async {
    if (!_formKeyTelephone.currentState!.validate()) return;

    setState(() {
      _enCours = true;
      _erreur = null;
    });

    try {
      final question = await ref
          .read(authServiceProvider)
          .obtenirQuestionSecrete(_telephoneCtrl.text.trim());

      if (question == null) {
        setState(() => _erreur = 'Aucun compte trouvé pour ce numéro.');
        return;
      }

      setState(() {
        _question = question;
        _etape = _Etape.reponse;
      });
    } catch (_) {
      setState(
          () => _erreur = 'Impossible de vérifier ce numéro pour le moment.');
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  Future<void> _verifierReponse() async {
    if (!_formKeyReponse.currentState!.validate()) return;

    setState(() {
      _enCours = true;
      _erreur = null;
    });

    try {
      final resultat = await ref.read(authServiceProvider).verifierReponseSecrete(
            telephone: _telephoneCtrl.text.trim(),
            reponse: _reponseCtrl.text.trim(),
          );

      switch (resultat) {
        case 'ok':
          setState(() => _etape = _Etape.nouveauPin);
        case 'bloque':
          setState(() => _erreur =
              'Trop de tentatives incorrectes. Réessayez dans quelques minutes.');
        default:
          setState(() => _erreur = 'Réponse incorrecte.');
      }
    } catch (_) {
      setState(
          () => _erreur = 'Impossible de vérifier la réponse pour le moment.');
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  Future<void> _reinitialiser() async {
    if (!_formKeyNouveauPin.currentState!.validate()) return;

    setState(() {
      _enCours = true;
      _erreur = null;
    });

    try {
      final resultat = await ref.read(authServiceProvider).reinitialiserPin(
            telephone: _telephoneCtrl.text.trim(),
            reponse: _reponseCtrl.text.trim(),
            nouveauPin: _nouveauPinCtrl.text.trim(),
          );

      switch (resultat) {
        case 'ok':
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Code PIN mis à jour. Vous pouvez vous connecter.')),
            );
            context.pop();
          }
        case 'bloque':
          setState(() => _erreur =
              'Trop de tentatives incorrectes. Réessayez dans quelques minutes.');
        default:
          setState(() => _erreur = 'Réponse incorrecte.');
      }
    } catch (_) {
      setState(() =>
          _erreur = 'Impossible de réinitialiser le code pour le moment.');
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Code PIN oublié')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: switch (_etape) {
            _Etape.telephone => _formulaireTelephone(context),
            _Etape.reponse => _formulaireReponse(context),
            _Etape.nouveauPin => _formulaireNouveauPin(context),
          },
        ),
      ),
    );
  }

  Widget _formulaireTelephone(BuildContext context) {
    return Form(
      key: _formKeyTelephone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Entrez le numéro de téléphone de votre compte.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _telephoneCtrl,
            decoration: const InputDecoration(labelText: 'Numéro de téléphone'),
            keyboardType: TextInputType.phone,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
          ),
          if (_erreur != null) ...[
            const SizedBox(height: 12),
            Text(_erreur!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _enCours ? null : _rechercherQuestion,
            child: _enCours
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  Widget _formulaireReponse(BuildContext context) {
    return Form(
      key: _formKeyReponse,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_question!, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextFormField(
            controller: _reponseCtrl,
            decoration: const InputDecoration(labelText: 'Votre réponse'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
          ),
          if (_erreur != null) ...[
            const SizedBox(height: 12),
            Text(_erreur!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _enCours ? null : _verifierReponse,
            child: _enCours
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Vérifier'),
          ),
        ],
      ),
    );
  }

  Widget _formulaireNouveauPin(BuildContext context) {
    return Form(
      key: _formKeyNouveauPin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Réponse correcte. Choisissez votre nouveau code PIN.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nouveauPinCtrl,
            decoration: const InputDecoration(
                labelText: 'Nouveau code PIN (6 chiffres)'),
            keyboardType: TextInputType.number,
            obscureText: true,
            validator: (v) => (v == null || v.trim().length < 6)
                ? 'Au moins 6 chiffres'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmationPinCtrl,
            decoration: const InputDecoration(
                labelText: 'Confirmez le nouveau code PIN'),
            keyboardType: TextInputType.number,
            obscureText: true,
            validator: (v) => (v != _nouveauPinCtrl.text)
                ? 'Les deux codes ne correspondent pas'
                : null,
          ),
          if (_erreur != null) ...[
            const SizedBox(height: 12),
            Text(_erreur!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _enCours ? null : _reinitialiser,
            child: _enCours
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Réinitialiser mon code'),
          ),
        ],
      ),
    );
  }
}
