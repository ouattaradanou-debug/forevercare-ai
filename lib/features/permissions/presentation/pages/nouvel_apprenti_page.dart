import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/telephone_utils.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class NouvelApprentiPage extends ConsumerStatefulWidget {
  const NouvelApprentiPage({super.key});

  @override
  ConsumerState<NouvelApprentiPage> createState() =>
      _NouvelApprentiPageState();
}

class _NouvelApprentiPageState extends ConsumerState<NouvelApprentiPage> {
  final GlobalKey<FormState> _cleFormulaire = GlobalKey<FormState>();
  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _telephoneCtrl = TextEditingController();
  final TextEditingController _pinCtrl = TextEditingController();

  bool _enCours = false;
  String? _erreur;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telephoneCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _creer() async {
    if (!_cleFormulaire.currentState!.validate()) return;

    setState(() {
      _enCours = true;
      _erreur = null;
    });

    try {
      await ref
          .read(utilisateurRepositoryProvider)
          .creerApprenti(
            nom: _nomCtrl.text.trim(),
            telephone: _telephoneCtrl.text,
            pin: _pinCtrl.text,
          );

      final atelier = ref.read(atelierCourantProvider).valueOrNull;
      if (atelier != null) {
        await ref
            .read(utilisateurRepositoryProvider)
            .recupererEquipeAtelier(atelier.id);
      }

      if (mounted) context.pop();
    } catch (e) {
      setState(() => _erreur = 'Impossible de créer ce compte : $e');
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel apprenti')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Form(
          key: _cleFormulaire,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "L'apprenti se connectera avec ce numéro et ce code PIN. "
                "Aucune permission n'est activée par défaut : tu les "
                "choisiras à l'étape suivante.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.l),
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(labelText: "Nom de l'apprenti"),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nom obligatoire' : null,
              ),
              const SizedBox(height: AppSpacing.m),
              TextFormField(
                controller: _telephoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                ),
                validator: (v) => (v == null || !TelephoneUtils.estValide(v))
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
                validator: (v) =>
                    (v == null || v.length != 6) ? 'Code PIN à 6 chiffres' : null,
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
                onPressed: _enCours ? null : _creer,
                child: _enCours
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Text("Créer le compte de l'apprenti"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
