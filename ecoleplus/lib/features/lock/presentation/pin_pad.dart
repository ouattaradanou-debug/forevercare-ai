import 'package:flutter/material.dart';

/// Clavier à gros chiffres pour saisir le code (4 à 6 chiffres).
class PinPad extends StatefulWidget {
  const new({required this.onSubmit, this.enabled = true, super.key});

  final ValueChanged<String> onSubmit;
  final bool enabled;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _code = '';

  void _tap(String d) {
    if (!widget.enabled || _code.length >= 6) return;
    setState(() => _code += d);
  }

  void _submit() {
    if (_code.length < 4) return;
    final c = _code;
    setState(() => _code = '');
    widget.onSubmit(c);
  }

  Widget _key(String label, {VoidCallback? onTap, Key? key}) => Padding(
    padding: const EdgeInsets.all(6),
    child: SizedBox(
      width: 80,
      height: 64,
      child: FilledButton.tonal(
        key: key,
        onPressed: widget.enabled ? onTap : null,
        style: FilledButton.styleFrom(padding: EdgeInsets.zero),
        child: Text(label, style: const TextStyle(fontSize: 26)),
      ),
    ),
  );

  /// Touche de validation : pleine couleur, coche bien visible.
  Widget _valider() => Padding(
    padding: const EdgeInsets.all(6),
    child: SizedBox(
      width: 80,
      height: 64,
      child: FilledButton(
        key: const Key('pin-ok'),
        onPressed: widget.enabled && _code.length >= 4 ? _submit : null,
        style: FilledButton.styleFrom(padding: EdgeInsets.zero),
        child: const Icon(Icons.check, size: 34, semanticLabel: 'Valider'),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Semantics(
        label: '${_code.length} chiffres saisis',
        child: Text(
          _code.isEmpty ? '—' : '●' * _code.length,
          style: const TextStyle(fontSize: 32, letterSpacing: 8),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        _code.length < 4
            ? 'Tapez 4 à 6 chiffres'
            : 'Appuyez sur ✓ pour valider',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 12),
      for (final row in const [
        ['1', '2', '3'],
        ['4', '5', '6'],
        ['7', '8', '9'],
      ])
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final d in row)
              _key(d, key: Key('pin-$d'), onTap: () => _tap(d)),
          ],
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _key(
            '⌫',
            key: const Key('pin-effacer'),
            onTap: () => setState(
              () => _code = _code.isEmpty
                  ? ''
                  : _code.substring(0, _code.length - 1),
            ),
          ),
          _key('0', key: const Key('pin-0'), onTap: () => _tap('0')),
          _valider(),
        ],
      ),
    ],
  );
}
