import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/questions_secretes.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/preference_theme.dart';
import '../../../core/utils/validators.dart';
import '../providers/auth_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);

/// Réglages de l'atelier : abonnement, thème, équipe et champs de mesure
/// (ces deux dernières commandes réservées au propriétaire).
class EcranParametres extends ConsumerWidget {
  const EcranParametres({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final estProprietaire = ref.watch(estProprietaireProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined, color: _bleuSeda),
              title: const Text('Thème', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(_libelleTheme(themeMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _choisirTheme(context, ref, themeMode),
            ),
            if (estProprietaire) ...[
              // L'abonnement est celui de l'atelier, pas de l'apprenti : le
              // propriétaire seul le gère, et sa couverture s'applique déjà
              // automatiquement à tout l'atelier (voir
              // verifierEcritureAutorisee, qui lit l'abonnement de
              // l'atelier, pas celui de l'utilisateur connecté).
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.card_membership_outlined, color: _bleuSeda),
                title: const Text(
                  'Renouveler mon abonnement',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.abonnement),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.diversity_3_outlined, color: _bleuSeda),
                title: const Text('Mon équipe', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.apprentis),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.straighten_outlined, color: _bleuSeda),
                title: const Text(
                  'Champs de mesure',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.champsDeMesure),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.draw_outlined, color: _bleuSeda),
                title: const Text('Ma signature', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Utilisée sur les factures PDF'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.signatureAtelier),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help_outline, color: _bleuSeda),
                title: const Text(
                  'Question de récupération',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Utilisée en cas de code PIN oublié'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _modifierQuestionSecrete(context, ref),
              ),
            ],
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  String _libelleTheme(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
        return 'Système';
    }
  }

  Future<void> _choisirTheme(BuildContext context, WidgetRef ref, ThemeMode actuel) async {
    final choisi = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in ThemeMode.values)
              RadioListTile<ThemeMode>(
                value: mode,
                groupValue: actuel,
                activeColor: _bleuSeda,
                title: Text(_libelleTheme(mode)),
                onChanged: (valeur) => Navigator.of(context).pop(valeur),
              ),
          ],
        ),
      ),
    );
    if (choisi != null) {
      await ref.read(themeModeProvider.notifier).definir(choisi);
    }
  }

  /// Définit (ou remplace) la question secrète du propriétaire — voir
  /// AuthRepository.definirQuestionSecrete / EcranCreationCompteAtelier
  /// pour le même formulaire à la création du compte.
  Future<void> _modifierQuestionSecrete(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final reponseCtrl = TextEditingController();
    final questionPersonnaliseeCtrl = TextEditingController();
    var questionChoisie = questionsSecretesPredefinies.first;
    var enregistrement = false;

    final enregistre = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Question de récupération', style: TextStyle(color: _bleuSeda)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Utilisée pour récupérer votre compte en cas de code PIN oublié. '
                    'Remplace toute question déjà définie.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: questionChoisie,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Question secrète'),
                    items: [
                      for (final question in questionsSecretesPredefinies)
                        DropdownMenuItem(
                          value: question,
                          child: Text(question, softWrap: true),
                        ),
                    ],
                    onChanged: (valeur) {
                      if (valeur != null) setState(() => questionChoisie = valeur);
                    },
                  ),
                  if (questionChoisie == questionsSecretesPredefinies.last) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: questionPersonnaliseeCtrl,
                      decoration: const InputDecoration(labelText: 'Votre question'),
                      validator: Validators.nomRequis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: reponseCtrl,
                    decoration: const InputDecoration(labelText: 'Votre réponse'),
                    validator: Validators.nomRequis,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: enregistrement ? null : () => Navigator.pop(dialogContext, false),
              style: TextButton.styleFrom(foregroundColor: _bleuSeda),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: enregistrement
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => enregistrement = true);
                      final estPersonnalisee =
                          questionChoisie == questionsSecretesPredefinies.last;
                      try {
                        await ref.read(authRepositoryProvider).definirQuestionSecrete(
                              question: estPersonnalisee
                                  ? questionPersonnaliseeCtrl.text.trim()
                                  : questionChoisie,
                              reponse: reponseCtrl.text.trim(),
                            );
                        if (dialogContext.mounted) Navigator.pop(dialogContext, true);
                      } catch (e) {
                        setState(() => enregistrement = false);
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text('Échec de l\'enregistrement : $e')),
                          );
                        }
                      }
                    },
              style: FilledButton.styleFrom(backgroundColor: _bleuSeda),
              child: enregistrement
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );

    if (enregistre == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question de récupération enregistrée.')),
      );
    }
  }
}
