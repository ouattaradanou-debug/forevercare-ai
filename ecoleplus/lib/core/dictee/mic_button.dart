import 'dart:async';

import 'package:ecoleplus/core/dictee/dictee.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dicteeProvider = Provider<Dictee>((ref) => DicteeNative());

/// Vrai une fois l'explication du micro montrée (une fois par lancement).
bool _expliquee = false;

/// Bouton micro d'un champ de texte : le texte dicté s'affiche, reste
/// modifiable, puis s'ajoute au champ. Le clavier reste toujours disponible.
class MicButton extends ConsumerWidget {
  const new({required this.texteActuel, required this.inserer, super.key});

  final String Function() texteActuel;
  final void Function(String texte) inserer;

  Future<void> _dicter(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!_expliquee) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Dicter au lieu d’écrire'),
          content: const Text(
            'Le téléphone va demander l’autorisation d’utiliser le micro. '
            'Il sert seulement à écrire ce que vous dites : rien n’est '
            'enregistré, et vous pourrez corriger le texte avant de le '
            'garder.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Non merci'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Continuer'),
            ),
          ],
        ),
      );
      if (!(ok ?? false)) return;
      _expliquee = true;
    }
    final dictee = ref.read(dicteeProvider);
    if (!await dictee.preparer()) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Le micro n’est pas disponible sur ce téléphone. Utilisez le '
            'clavier.',
          ),
        ),
      );
      return;
    }
    if (!context.mounted) return;
    final texte = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (c) => _FeuilleDictee(dictee: dictee),
    );
    if (texte == null || texte.trim().isEmpty) return;
    final avant = texteActuel().trimRight();
    inserer(avant.isEmpty ? texte.trim() : '$avant ${texte.trim()}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton.filledTonal(
    tooltip: 'Dicter',
    iconSize: 28,
    icon: const Icon(Icons.mic),
    onPressed: () => _dicter(context, ref),
  );
}

class _FeuilleDictee extends StatefulWidget {
  const new({required this.dictee});
  final Dictee dictee;

  @override
  State<_FeuilleDictee> createState() => _FeuilleDicteeState();
}

class _FeuilleDicteeState extends State<_FeuilleDictee> {
  final _texte = TextEditingController();
  bool _ecoute = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    unawaited(
      widget.dictee.ecouter(
        surTexte: (t) {
          if (mounted) setState(() => _texte.text = t);
        },
        surFin: (e) {
          if (mounted) {
            setState(() {
              _ecoute = false;
              _erreur = e;
            });
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    unawaited(widget.dictee.arreter());
    _texte.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 16,
      right: 16,
      top: 16,
      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              _ecoute ? Icons.mic : Icons.mic_none,
              color: _ecoute ? Theme.of(context).colorScheme.error : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _ecoute
                    ? 'Parlez… (le texte s’affiche ci-dessous)'
                    : 'Vérifiez et corrigez le texte si besoin.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        if (_erreur != null) ...[
          const SizedBox(height: 8),
          Text(
            _erreur!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          key: const Key('texte-dicte'),
          controller: _texte,
          maxLines: 5,
          minLines: 2,
          decoration: const InputDecoration(
            labelText: 'Texte reconnu',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => Navigator.pop(context, _texte.text),
          child: const Text('Ajouter au texte'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_ecoute)
              TextButton(
                onPressed: () => unawaited(widget.dictee.arreter()),
                child: const Text('J’ai fini de parler'),
              )
            else
              const SizedBox.shrink(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ],
    ),
  );
}
