import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/lock/presentation/lock_providers.dart';
import 'package:ecoleplus/features/security/presentation/security_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mon compte : code de verrouillage, empreinte, question secrète.
class AccountPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(appLockProvider).value;
    final question = ref.watch(hasRecoveryQuestionProvider).value;
    return EcoleScaffold(
      title: 'Mon compte',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          BigButton(
            icon: Icons.pin_outlined,
            label: 'Changer mon code',
            onPressed: () => context.push('/code/creer'),
          ),
          const SizedBox(height: 12),
          FutureBuilder(
            future: ref.read(biometricGateProvider).disponible(),
            builder: (context, snap) => (snap.data ?? false)
                ? SwitchListTile(
                    title: const Text('Ouvrir avec mon empreinte'),
                    value: lock?.biometric ?? false,
                    onChanged: (v) =>
                        ref.read(lockServiceProvider).setBiometrie(active: v),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          BigButton(
            icon: Icons.help_outline,
            label: question == true
                ? 'Changer ma question secrète'
                : 'Choisir ma question secrète',
            onPressed: () => context.push('/compte/question'),
          ),
          const SizedBox(height: 8),
          const Text(
            'La question secrète permet de changer votre mot de passe si vous '
            'l’oubliez, sans attendre le directeur.',
          ),
        ],
      ),
    );
  }
}

const _suggestions = [
  'Quel est le nom de mon premier élève ?',
  'Quel plat ai-je mangé le jour de ma première rentrée comme enseignant ?',
  'Quel est le surnom que je donnais à mon vélo ?',
];

class RecoveryQuestionPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<RecoveryQuestionPage> createState() => _RecoveryState();
}

class _RecoveryState extends ConsumerState<RecoveryQuestionPage> {
  final _question = TextEditingController();
  final _reponse = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _question.dispose();
    _reponse.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (_question.text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Écrivez ou choisissez une question.')),
      );
      return;
    }
    if (_reponse.text.trim() != _confirmation.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les deux réponses sont différentes.')),
      );
      return;
    }
    final ok = await avecMessage(context, () async {
      await ref
          .read(authApiProvider)
          .setRecoveryQuestion(_question.text.trim(), _reponse.text);
      return true;
    });
    if ((ok ?? false) && mounted) {
      ref.invalidate(hasRecoveryQuestionProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question secrète enregistrée.')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) => EcoleScaffold(
    title: 'Question secrète',
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Choisissez une question dont vous seul connaissez la réponse. '
          'Évitez « nom de ma mère » ou « village natal » : tout le monde '
          'peut les deviner. Cette action a besoin d’Internet.',
        ),
        const SizedBox(height: 12),
        for (final s in _suggestions)
          ListTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: Text(s),
            onTap: () => setState(() => _question.text = s),
          ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('question'),
          controller: _question,
          decoration: const InputDecoration(
            labelText: 'Ma question (ou écrivez la vôtre)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('reponse'),
          controller: _reponse,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Ma réponse (4 caractères au moins)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('confirmation'),
          controller: _confirmation,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Ma réponse, une seconde fois',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        BigButton(
          icon: Icons.save,
          label: 'Enregistrer',
          onPressed: _enregistrer,
        ),
      ],
    ),
  );
}
