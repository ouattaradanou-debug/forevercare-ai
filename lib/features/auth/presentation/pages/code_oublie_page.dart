import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/identifiants_memorises.dart';
import '../../../../core/utils/telephone_utils.dart';
import '../providers/auth_providers.dart';
import '../widgets/entete_auth.dart';

/// Récupération du code PIN oublié, en deux étapes : le numéro de
/// téléphone (pour retrouver la question secrète configurée à
/// l'inscription, voir CreationComptePage), puis la réponse et un nouveau
/// code PIN. Accessible sans session (voir app_router.dart) — c'est
/// justement le cas d'un tailleur qui ne peut plus se connecter du tout.
///
/// Réservé aux comptes propriétaires : un apprenti qui oublie son code
/// doit demander au propriétaire de lui en créer un nouveau depuis "Mon
/// équipe" (l'apprenti n'a pas de question secrète, voir
/// AuthRepository.definirRecuperation, appelée uniquement à la création
/// du compte propriétaire).
class CodeOubliePage extends ConsumerStatefulWidget {
  const CodeOubliePage({super.key});

  @override
  ConsumerState<CodeOubliePage> createState() => _CodeOubliePageState();
}

class _CodeOubliePageState extends ConsumerState<CodeOubliePage> {
  final GlobalKey<FormState> _cleFormulaireTelephone = GlobalKey<FormState>();
  final GlobalKey<FormState> _cleFormulaireReponse = GlobalKey<FormState>();
  final TextEditingController _telephoneCtrl = TextEditingController();
  final TextEditingController _reponseCtrl = TextEditingController();
  final TextEditingController _nouveauPinCtrl = TextEditingController();
  final TextEditingController _nouveauPinConfirmationCtrl =
      TextEditingController();

  String? _question;
  bool _enCours = false;
  bool _nouveauPinVisible = false;
  bool _nouveauPinConfirmationVisible = false;
  String? _erreur;

  @override
  void dispose() {
    _telephoneCtrl.dispose();
    _reponseCtrl.dispose();
    _nouveauPinCtrl.dispose();
    _nouveauPinConfirmationCtrl.dispose();
    super.dispose();
  }

  Future<void> _rechercherQuestion() async {
    if (!_cleFormulaireTelephone.currentState!.validate()) return;

    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      final String question = await ref
          .read(authRepositoryProvider)
          .recupererQuestionRecuperation(_telephoneCtrl.text);
      if (mounted) setState(() => _question = question);
    } catch (e) {
      if (mounted) {
        setState(
          () => _erreur =
              "Impossible de trouver ce compte, ou aucune question n'a été "
              'configurée pour lui ($e).',
        );
      }
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  Future<void> _reinitialiser() async {
    if (!_cleFormulaireReponse.currentState!.validate()) return;
    if (_nouveauPinCtrl.text != _nouveauPinConfirmationCtrl.text) {
      setState(() => _erreur = 'Les deux codes PIN ne correspondent pas.');
      return;
    }

    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      await ref.read(authRepositoryProvider).reinitialiserCode(
            telephone: _telephoneCtrl.text,
            reponse: _reponseCtrl.text,
            nouveauPin: _nouveauPinCtrl.text,
          );
      await IdentifiantsMemorises.enregistrer(
        telephone: _telephoneCtrl.text,
        pin: _nouveauPinCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Code PIN réinitialisé. Connecte-toi avec ton nouveau code.',
            ),
          ),
        );
        context.go('/connexion');
      }
    } catch (e) {
      if (mounted) setState(() => _erreur = 'Réponse incorrecte ($e).');
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const EnteteAuth(
                titre: 'Code oublié',
                sousTitre: 'Réponds à ta question secrète',
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: _question == null
                    ? _formulaireTelephone()
                    : _formulaireReponse(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formulaireTelephone() {
    return Form(
      key: _cleFormulaireTelephone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _telephoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone du compte',
            ),
            validator: (v) => (v == null || !TelephoneUtils.estValide(v))
                ? 'Numéro de téléphone invalide'
                : null,
          ),
          if (_erreur != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              _erreur!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          ElevatedButton(
            onPressed: _enCours ? null : _rechercherQuestion,
            child: _enCours
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Text('Continuer'),
          ),
          const SizedBox(height: AppSpacing.m),
          TextButton(
            onPressed: _enCours ? null : () => context.go('/connexion'),
            child: const Text('Retour à la connexion'),
          ),
        ],
      ),
    );
  }

  Widget _formulaireReponse() {
    return Form(
      key: _cleFormulaireReponse,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _question!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.m),
          TextFormField(
            controller: _reponseCtrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Ta réponse'),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'La réponse est obligatoire'
                : null,
          ),
          const SizedBox(height: AppSpacing.m),
          TextFormField(
            controller: _nouveauPinCtrl,
            obscureText: !_nouveauPinVisible,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              labelText: 'Nouveau code PIN (6 chiffres)',
              suffixIcon: IconButton(
                icon: Icon(
                  _nouveauPinVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(
                  () => _nouveauPinVisible = !_nouveauPinVisible,
                ),
              ),
            ),
            validator: (v) => (v == null || v.length != 6)
                ? 'Le code PIN doit contenir 6 chiffres'
                : null,
          ),
          const SizedBox(height: AppSpacing.m),
          TextFormField(
            controller: _nouveauPinConfirmationCtrl,
            obscureText: !_nouveauPinConfirmationVisible,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              labelText: 'Confirmer le nouveau code PIN',
              suffixIcon: IconButton(
                icon: Icon(
                  _nouveauPinConfirmationVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(
                  () => _nouveauPinConfirmationVisible =
                      !_nouveauPinConfirmationVisible,
                ),
              ),
            ),
            validator: (v) => (v == null || v.length != 6)
                ? 'Confirme ton nouveau code PIN'
                : null,
          ),
          if (_erreur != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              _erreur!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          ElevatedButton(
            onPressed: _enCours ? null : _reinitialiser,
            child: _enCours
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Text('Réinitialiser mon code'),
          ),
        ],
      ),
    );
  }
}
