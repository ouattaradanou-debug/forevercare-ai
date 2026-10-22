import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/lock/data/lock_service.dart';
import 'package:ecoleplus/features/lock/presentation/lock_providers.dart';
import 'package:ecoleplus/features/security/presentation/security_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mon compte : ouverture (code ou empreinte), numéro de connexion,
/// question secrète.
class AccountPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(appLockProvider).value;
    final question = ref.watch(hasRecoveryQuestionProvider).value;
    final session = ref.watch(sessionProvider).value;
    return EcoleScaffold(
      title: 'Mon compte',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          BigButton(
            icon: (lock?.empreinteSeule ?? false)
                ? Icons.fingerprint
                : Icons.pin_outlined,
            label: 'Changer ma façon d’ouvrir l’application',
            onPressed: () => context.push('/code/creer'),
          ),
          const SizedBox(height: 4),
          Text(
            (lock?.empreinteSeule ?? false)
                ? 'Aujourd’hui : avec votre empreinte.'
                : 'Aujourd’hui : avec votre code.',
          ),
          if (!(session?.login.endsWith('@tel.ecoleplus.invalid') ?? true)) ...[
            const SizedBox(height: 12),
            BigButton(
              icon: Icons.phone_android,
              label: 'Mon numéro pour me connecter',
              onPressed: () => context.push('/compte/numero'),
            ),
          ],
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

/// Numéro de téléphone pour se connecter, en plus de l'e-mail (A11).
class LoginPhonePage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<LoginPhonePage> createState() => _LoginPhoneState();
}

class _LoginPhoneState extends ConsumerState<LoginPhonePage> {
  final _numero = TextEditingController();
  bool _charge = false;
  String? _actuel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final actuel = await avecMessage(
        context,
        () => ref.read(authServiceProvider).loginPhone(),
      );
      if (!mounted) return;
      setState(() {
        _charge = true;
        _actuel = actuel;
        if (actuel != null) _numero.text = actuel.substring(3);
      });
    });
  }

  @override
  void dispose() {
    _numero.dispose();
    super.dispose();
  }

  Future<void> _enregistrer(String saisie) async {
    final ok = await avecMessage(context, () async {
      await ref.read(authServiceProvider).setLoginPhone(saisie);
      return true;
    });
    if ((ok ?? false) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saisie.trim().isEmpty
                ? 'Numéro retiré : connectez-vous avec votre e-mail.'
                : 'Numéro enregistré : vous pouvez vous connecter avec.',
          ),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) => EcoleScaffold(
    title: 'Mon numéro',
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Avec ce numéro, vous pourrez vous connecter sans taper votre '
          'e-mail, avec le même mot de passe. L’e-mail reste valable et sert '
          'à récupérer le mot de passe. Cette action a besoin d’Internet.',
        ),
        const SizedBox(height: 16),
        if (!_charge)
          const Center(child: CircularProgressIndicator())
        else ...[
          TextField(
            key: const Key('numero'),
            controller: _numero,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Mon numéro (8 chiffres)',
              hintText: '70 12 34 56',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          BigButton(
            icon: Icons.save,
            label: 'Enregistrer',
            onPressed: () => _enregistrer(_numero.text),
          ),
          if (_actuel != null)
            TextButton(
              onPressed: () => _enregistrer(''),
              child: const Text('Ne plus me connecter avec un numéro'),
            ),
        ],
      ],
    ),
  );
}
