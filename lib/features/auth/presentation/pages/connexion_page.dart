import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/telephone_utils.dart';
import '../providers/auth_providers.dart';
import '../widgets/entete_auth.dart';

class ConnexionPage extends ConsumerStatefulWidget {
  const ConnexionPage({super.key});

  @override
  ConsumerState<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends ConsumerState<ConnexionPage> {
  final GlobalKey<FormState> _cleFormulaire = GlobalKey<FormState>();
  final TextEditingController _telephoneCtrl = TextEditingController();
  final TextEditingController _pinCtrl = TextEditingController();

  bool _enCours = false;
  String? _erreur;

  @override
  void dispose() {
    _telephoneCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    if (!_cleFormulaire.currentState!.validate()) return;

    setState(() {
      _enCours = true;
      _erreur = null;
    });

    try {
      final reponse = await ref
          .read(authRepositoryProvider)
          .seConnecter(telephone: _telephoneCtrl.text, pin: _pinCtrl.text);

      final String? id = reponse.user?.id;
      if (id == null) {
        throw const AuthException('Connexion impossible.');
      }

      await ref
          .read(recuperationCompteServiceProvider)
          .recupererDonneesCompte(id);

      if (mounted) context.go('/');
    } on AuthException catch (e) {
      setState(
        () => _erreur = 'Numéro ou code PIN incorrect (${e.message}).',
      );
    } catch (e) {
      setState(() => _erreur = 'Une erreur est survenue : $e');
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
                titre: 'Bon retour',
                sousTitre: 'Connecte-toi à ton atelier',
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Form(
                  key: _cleFormulaire,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _telephoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Numéro de téléphone',
                        ),
                        validator: (valeur) {
                          if (valeur == null || !TelephoneUtils.estValide(valeur)) {
                            return 'Numéro de téléphone invalide';
                          }
                          return null;
                        },
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
                        validator: (valeur) {
                          if (valeur == null || valeur.length != 6) {
                            return 'Le code PIN doit contenir 6 chiffres';
                          }
                          return null;
                        },
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
                        onPressed: _enCours ? null : _seConnecter,
                        child: _enCours
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('Se connecter'),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      TextButton(
                        onPressed: _enCours
                            ? null
                            : () => context.go('/creation-compte'),
                        child: const Text('Créer un compte atelier'),
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
