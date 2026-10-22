import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/dictee/mic_button.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/auth/domain/identifiant.dart';
import 'package:ecoleplus/features/members/presentation/password_tools.dart';
import 'package:ecoleplus/features/options/domain/module_rules.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddMemberPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<AddMemberPage> createState() => _AddMemberState();
}

class _AddMemberState extends ConsumerState<AddMemberPage> {
  final _name = TextEditingController();
  final _login = TextEditingController();
  late final _password = TextEditingController(text: motDePasseProvisoire());
  String _role = 'enseignant';
  final Set<String> _droits = {};
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit(String schoolId) async {
    setState(() => _busy = true);
    final identifiant = await avecMessage(
      context,
      () => ref
          .read(membersServiceProvider)
          .create(
            schoolId: schoolId,
            displayName: _name.text,
            role: _role,
            login: _login.text,
            password: _password.text,
            permissions: _role == 'delegue' ? _droits.toList() : const [],
          ),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (identifiant == null) return;
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Compte créé'),
        content: Text(
          'Remettez ces informations à ${_name.text.trim()} :\n\n'
          'Identifiant : ${identifiantAffichable(identifiant)}\n'
          'Mot de passe provisoire : ${_password.text}\n\n'
          'Notez-les maintenant : le mot de passe ne sera plus affiché.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('J’ai noté'),
          ),
        ],
      ),
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value!;
    final cantine = ref
        .watch(modulesProvider(session.schoolId))
        .value
        ?.any((m) => m.$1.key == 'cantine' && m.$2);
    final apercu = identifiantVersEmail(_login.text);
    return EcoleScaffold(
      title: 'Ajouter une personne',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Cette action a besoin d’Internet.'),
          const SizedBox(height: 16),
          TexteDictable(
            key: const Key('name'),
            controller: _name,
            label: 'Nom et prénom',
            border: true,
          ),
          const SizedBox(height: 16),
          const Text('Profil'),
          RadioGroup<String>(
            groupValue: _role,
            onChanged: (v) => setState(() => _role = v!),
            child: const Column(
              children: [
                RadioListTile(value: 'enseignant', title: Text('Enseignant')),
                RadioListTile(
                  value: 'delegue',
                  title: Text('Délégué (secrétaire, économe…)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('login'),
            controller: _login,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Identifiant de connexion',
              hintText: 'Numéro de téléphone (conseillé), e-mail ou nom',
              helperText: _login.text.isEmpty
                  ? null
                  : apercu == null
                  ? 'Identifiant non valide'
                  : 'Se connectera avec : ${identifiantAffichable(apercu)}',
              border: const OutlineInputBorder(),
              suffixIcon: MicButton(
                compact: true,
                type: TypeDictee.numero,
                texteActuel: () => _login.text,
                inserer: (t) => setState(() => _login.text = t),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('password'),
            controller: _password,
            decoration: const InputDecoration(
              labelText: 'Mot de passe provisoire',
              border: OutlineInputBorder(),
            ),
          ),
          if (_role == 'delegue') ...[
            const SectionTitle('Droits accordés'),
            for (final k in droitsVisibles(cantineActive: cantine ?? false))
              CheckboxListTile(
                title: Text(droitsDelegables[k]!),
                value: _droits.contains(k),
                onChanged: (v) => setState(
                  () => (v ?? false) ? _droits.add(k) : _droits.remove(k),
                ),
              ),
          ],
          const SizedBox(height: 16),
          BigButton(
            icon: Icons.person_add,
            label: _busy ? 'Création…' : 'Créer le compte',
            onPressed: _busy ? null : () => _submit(session.schoolId),
          ),
        ],
      ),
    );
  }
}
