import 'dart:async';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/core/drafts/draft_store.dart';
import 'package:ecoleplus/core/widgets/big_button.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/auth/data/auth_service.dart';
import 'package:ecoleplus/features/school/domain/school_year.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Première utilisation : un seul écran défilant, brouillon automatique.
class CreateSchoolPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<CreateSchoolPage> createState() => _CreateSchoolState();
}

class _CreateSchoolState extends ConsumerState<CreateSchoolPage> {
  static const _draftKey = 'creer_ecole';
  static const _fields = [
    'director_name',
    'email',
    'school_name',
    'commune',
    'province',
    'region',
    'phone',
    'year_label',
  ];
  late final Map<String, TextEditingController> _c = {
    for (final f in _fields) f: TextEditingController(),
  };
  final _password = TextEditingController();
  String _type = 'publique';
  bool _primary = true;
  bool _preschool = false;
  bool _busy = false;
  Timer? _timer;
  late final DraftStore _drafts = DraftStore(ref.read(databaseProvider));

  @override
  void initState() {
    super.initState();
    _c['year_label']!.text = anneeScolaireProposee(DateTime.now());
    unawaited(_restore());
  }

  Future<void> _restore() async {
    final d = await _drafts.load(_draftKey);
    if (!mounted || d.isEmpty) return;
    setState(() {
      for (final f in _fields) {
        if (d[f] is String) _c[f]!.text = d[f] as String;
      }
      _type = d['school_type'] as String? ?? _type;
      _primary = d['primary'] as bool? ?? _primary;
      _preschool = d['preschool'] as bool? ?? _preschool;
    });
  }

  void _saveDraft() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), () {
      unawaited(
        _drafts.save(_draftKey, {
          for (final f in _fields) f: _c[f]!.text,
          'school_type': _type,
          'primary': _primary,
          'preschool': _preschool,
        }),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _c.values) {
      c.dispose();
    }
    _password.dispose();
    super.dispose();
  }

  String? _v(String f) =>
      _c[f]!.text.trim().isEmpty ? null : _c[f]!.text.trim();

  Future<void> _submit() async {
    final missing = [
      if (_v('director_name') == null) 'votre nom',
      if (_v('school_name') == null) 'le nom de l’école',
      if (!anneeScolaireValide(_c['year_label']!.text))
        'l’année scolaire (ex. 2025-2026)',
      if (!_primary && !_preschool) 'au moins un niveau',
    ];
    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Il manque : ${missing.join(', ')}.')),
      );
      return;
    }
    setState(() => _busy = true);
    final ok = await avecMessage(context, () async {
      await ref
          .read(authServiceProvider)
          .createSchool(
            NewSchool(
              directorName: _v('director_name')!,
              email: _c['email']!.text,
              password: _password.text,
              schoolName: _v('school_name')!,
              yearLabel: _c['year_label']!.text.trim(),
              commune: _v('commune'),
              province: _v('province'),
              region: _v('region'),
              phone: _v('phone'),
              schoolType: _type,
              managesPrimary: _primary,
              managesPreschool: _preschool,
            ),
          );
      await _drafts.clear(_draftKey);
      return true;
    });
    if (mounted) setState(() => _busy = false);
    if (ok == null && mounted) {
      // Le brouillon reste : rien n'est perdu.
    }
  }

  Widget _field(String f, String label, {TextInputType? type, String? hint}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextField(
          key: Key(f),
          controller: _c[f],
          keyboardType: type,
          onChanged: (_) => _saveDraft(),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final hasAccount = ref.read(authApiProvider).currentUserId != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Créer mon école')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Cette étape a besoin d’Internet. Ce que vous tapez est gardé '
              'sur le téléphone : vous pouvez continuer plus tard.',
            ),
            const SizedBox(height: 16),
            const SectionTitle('Vous (directeur ou directrice)'),
            _field('director_name', 'Votre nom et prénom *'),
            if (!hasAccount) ...[
              _field(
                'email',
                'Votre adresse e-mail *',
                type: TextInputType.emailAddress,
                hint: 'Elle sert à récupérer votre mot de passe',
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  key: const Key('password'),
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Choisissez un mot de passe * (8 caractères)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
            const SectionTitle('Votre école'),
            _field('school_name', 'Nom de l’école *'),
            _field('commune', 'Commune'),
            _field('province', 'Province'),
            _field('region', 'Région'),
            _field('phone', 'Téléphone de l’école', type: TextInputType.phone),
            const Text('Type d’école'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'publique', label: Text('Publique')),
                ButtonSegment(value: 'privee', label: Text('Privée')),
              ],
              selected: {_type},
              onSelectionChanged: (s) {
                setState(() => _type = s.first);
                _saveDraft();
              },
            ),
            const SizedBox(height: 16),
            const Text('Niveaux gérés (au moins un)'),
            CheckboxListTile(
              title: const Text('Primaire (CP1 à CM2)'),
              value: _primary,
              onChanged: (v) {
                setState(() => _primary = v ?? false);
                _saveDraft();
              },
            ),
            CheckboxListTile(
              title: const Text('Maternelle'),
              value: _preschool,
              onChanged: (v) {
                setState(() => _preschool = v ?? false);
                _saveDraft();
              },
            ),
            const SectionTitle('Année scolaire en cours'),
            _field('year_label', 'Année scolaire *', hint: 'ex. 2025-2026'),
            const SizedBox(height: 8),
            BigButton(
              icon: Icons.check,
              label: _busy ? 'Création en cours…' : 'Créer mon école',
              onPressed: _busy ? null : _submit,
            ),
            const SizedBox(height: 8),
            const Text(
              '* champ obligatoire. Les autres informations (en-têtes '
              'administratifs, image) se complètent ensuite, même sans '
              'Internet.',
            ),
          ],
        ),
      ),
    );
  }
}
