import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/telephone_utils.dart';
import '../../../../shared/widgets/selecteur_photo.dart';
import '../providers/auth_providers.dart';
import '../widgets/entete_auth.dart';

class CreationComptePage extends ConsumerStatefulWidget {
  const CreationComptePage({super.key});

  @override
  ConsumerState<CreationComptePage> createState() =>
      _CreationComptePageState();
}

class _CreationComptePageState extends ConsumerState<CreationComptePage> {
  final GlobalKey<FormState> _cleFormulaire = GlobalKey<FormState>();
  final TextEditingController _nomAtelierCtrl = TextEditingController();
  final TextEditingController _nomProprietaireCtrl = TextEditingController();
  final TextEditingController _telephoneCtrl = TextEditingController();
  final TextEditingController _pinCtrl = TextEditingController();
  final TextEditingController _pinConfirmationCtrl = TextEditingController();
  final TextEditingController _questionSecreteCtrl = TextEditingController();
  final TextEditingController _reponseSecreteCtrl = TextEditingController();

  XFile? _logoChoisi;
  bool _enCours = false;
  String? _erreur;

  @override
  void dispose() {
    _nomAtelierCtrl.dispose();
    _nomProprietaireCtrl.dispose();
    _telephoneCtrl.dispose();
    _pinCtrl.dispose();
    _pinConfirmationCtrl.dispose();
    _questionSecreteCtrl.dispose();
    _reponseSecreteCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirLogo() async {
    try {
      final XFile? photo = await choisirPhoto(context);
      if (photo != null) setState(() => _logoChoisi = photo);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Accès à la caméra ou à la galerie refusé. Vérifie les "
            "autorisations de l'application dans les paramètres du "
            "téléphone, ou continue sans logo pour l'instant.",
          ),
        ),
      );
    }
  }

  Future<void> _creerCompte() async {
    if (!_cleFormulaire.currentState!.validate()) return;
    if (_pinCtrl.text != _pinConfirmationCtrl.text) {
      setState(() => _erreur = 'Les deux codes PIN ne correspondent pas.');
      return;
    }

    setState(() {
      _enCours = true;
      _erreur = null;
    });

    // Si la création du compte Supabase Auth réussit mais qu'une étape
    // suivante échoue (atelier, ligne utilisateurs, logo...), on
    // déconnecte pour éviter de laisser une session authentifiée "fantôme"
    // sans aucune donnée applicative associée — un tel compte resterait
    // sinon connecté indéfiniment sans jamais pouvoir charger d'atelier.
    // Les repositories sont lus une seule fois ici, avant tout "await" :
    // le widget est alors certainement monté, et on évite d'avoir à
    // relire "ref" plus tard dans le catch, potentiellement après que le
    // widget a été démonté.
    bool authentificationReussie = false;
    final authRepo = ref.read(authRepositoryProvider);
    final atelierRepo = ref.read(atelierRepositoryProvider);
    final utilisateurRepo = ref.read(utilisateurRepositoryProvider);
    final gabaritRepo = ref.read(gabaritRepositoryProvider);

    try {
      debugPrint('[creation-compte] 1/6 appel authRepo.creerCompte...');
      final reponse = await authRepo.creerCompte(
        telephone: _telephoneCtrl.text,
        pin: _pinCtrl.text,
      );
      debugPrint(
        '[creation-compte] 1/6 OK — user=${reponse.user?.id}, '
        'session=${reponse.session != null}',
      );

      final String? id = reponse.user?.id;
      if (id == null || reponse.session == null) {
        throw const AuthException(
          "Impossible de créer le compte. Vérifie que la confirmation "
          "email est désactivée dans les paramètres Supabase (Authentication "
          "> Providers > Email > Confirm email).",
        );
      }
      authentificationReussie = true;

      debugPrint('[creation-compte] 2/6 appel atelierRepo.creerAtelier...');
      final atelier = await atelierRepo.creerAtelier(
        _nomAtelierCtrl.text.trim(),
      );
      debugPrint('[creation-compte] 2/6 OK — atelier.id=${atelier.id}');

      debugPrint(
        '[creation-compte] 3/6 appel utilisateurRepo.creerUtilisateurProprietaire...',
      );
      await utilisateurRepo.creerUtilisateurProprietaire(
        id: id,
        atelierId: atelier.id,
        nom: _nomProprietaireCtrl.text.trim(),
        telephone: _telephoneCtrl.text,
      );
      debugPrint('[creation-compte] 3/6 OK');

      if (_logoChoisi != null) {
        debugPrint('[creation-compte] 4/6 appel atelierRepo.televerserLogo...');
        await atelierRepo.televerserLogo(
          atelierId: atelier.id,
          fichierOriginal: File(_logoChoisi!.path),
        );
        debugPrint('[creation-compte] 4/6 OK');
      } else {
        debugPrint('[creation-compte] 4/6 ignoré (pas de logo choisi)');
      }

      // Sans cette étape, les gabarits (types de tenue + champs de mesure)
      // restent absents du cache local pour un compte tout juste créé —
      // seule une connexion ultérieure les synchronise (voir
      // RecuperationCompteService) — et la section "Mesures" du formulaire
      // client se retrouverait sans aucun type de tenue à proposer.
      debugPrint('[creation-compte] 5/6 appel gabaritRepo.synchroniserGabarits...');
      await gabaritRepo.synchroniserGabarits(atelier.id);
      debugPrint('[creation-compte] 5/6 OK');

      // Best-effort : sans ça, "Code oublié ?" ne fonctionnera pas pour ce
      // compte, mais ça ne doit pas empêcher de terminer l'inscription.
      try {
        debugPrint('[creation-compte] 6/6 appel authRepo.definirRecuperation...');
        await authRepo.definirRecuperation(
          question: _questionSecreteCtrl.text.trim(),
          reponse: _reponseSecreteCtrl.text.trim(),
        );
        debugPrint('[creation-compte] 6/6 OK');
      } catch (e) {
        debugPrint('[creation-compte] 6/6 ÉCHEC (non bloquant) : $e');
      }

      debugPrint('[creation-compte] navigation vers /');
      if (mounted) context.go('/');
    } on AuthException catch (e) {
      debugPrint('[creation-compte] ÉCHEC (AuthException) : ${e.message}');
      if (mounted) setState(() => _erreur = e.message);
    } catch (e, stack) {
      debugPrint('[creation-compte] ÉCHEC (exception) : $e');
      debugPrint('[creation-compte] stack : $stack');
      if (authentificationReussie) {
        debugPrint(
          '[creation-compte] déconnexion du compte fantôme suite à échec',
        );
        await authRepo.seDeconnecter();
      }
      if (mounted) {
        setState(
          () => _erreur =
              "La création du compte n'a pas pu être terminée : $e. "
              'Réessaie.',
        );
      }
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
                titre: 'Créer mon atelier',
                sousTitre: 'Quelques informations pour démarrer',
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Form(
                  key: _cleFormulaire,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nomAtelierCtrl,
                        decoration: const InputDecoration(
                          labelText: "Nom de l'atelier",
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Le nom de l'atelier est obligatoire"
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _choisirLogo,
                              child: CircleAvatar(
                                radius: 44,
                                backgroundColor: AppColors.ecru200,
                                backgroundImage: _logoChoisi != null
                                    ? FileImage(File(_logoChoisi!.path))
                                    : null,
                                child: _logoChoisi == null
                                    ? const Icon(
                                        Icons.add_a_photo_outlined,
                                        color: AppColors.anthracite500,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s),
                            TextButton(
                              onPressed: _choisirLogo,
                              child: Text(
                                _logoChoisi == null
                                    ? "Ajouter un logo (facultatif)"
                                    : 'Changer le logo',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      TextFormField(
                        controller: _nomProprietaireCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Votre nom',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Votre nom est obligatoire'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      TextFormField(
                        controller: _telephoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Numéro de téléphone',
                        ),
                        validator: (v) =>
                            (v == null || !TelephoneUtils.estValide(v))
                            ? 'Numéro de téléphone invalide'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      TextFormField(
                        controller: _pinCtrl,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Code PIN (6 chiffres)',
                        ),
                        validator: (v) => (v == null || v.length != 6)
                            ? 'Le code PIN doit contenir 6 chiffres'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      TextFormField(
                        controller: _pinConfirmationCtrl,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Confirmer le code PIN',
                        ),
                        validator: (v) => (v == null || v.length != 6)
                            ? 'Confirme ton code PIN'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      Text(
                        'En cas de code PIN oublié',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Si tu oublies ton code, cette question permettra '
                        'de le réinitialiser toi-même, sans aide extérieure.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      TextFormField(
                        controller: _questionSecreteCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Ta question secrète',
                          hintText: 'Ex. Le nom de mon premier client ?',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'La question secrète est obligatoire'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      TextFormField(
                        controller: _reponseSecreteCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Ta réponse',
                        ),
                        validator: (v) => (v == null || v.trim().length < 2)
                            ? 'La réponse est obligatoire'
                            : null,
                      ),
                      if (_erreur != null) ...[
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          _erreur!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.l),
                      ElevatedButton(
                        onPressed: _enCours ? null : _creerCompte,
                        child: _enCours
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('Créer mon compte'),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      TextButton(
                        onPressed: _enCours
                            ? null
                            : () => context.go('/connexion'),
                        child: const Text("J'ai déjà un compte"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
