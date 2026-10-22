import 'dart:async';

import 'package:ecoleplus/core/dictee/mic_button.dart';
import 'package:ecoleplus/core/dictee/nombres_dictes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Date tapée en chiffres « jj/mm/aaaa » (A14) : clavier numérique, barres
/// placées automatiquement (22102011 → 22/10/2011), date impossible refusée
/// avec un message. Un petit bouton ouvre le calendrier, un autre la dictée.
/// Enregistrée « 2011-10-22 » (comme le serveur).
class AutoSaveDateField extends StatefulWidget {
  const new({
    required this.label,
    required this.initial,
    required this.onSave,
    this.helper,
    this.first,
    this.last,
    super.key,
  });

  final String label;
  final String? initial;
  final String? helper;
  final DateTime? first;
  final DateTime? last;
  final Future<void> Function(String? isoDate) onSave;

  static final _affichage = DateFormat('dd/MM/yyyy');

  static String? afficher(String? iso) {
    final d = iso == null ? null : DateTime.tryParse(iso);
    return d == null ? null : _affichage.format(d);
  }

  static String iso(DateTime d) {
    String deux(int n) => n.toString().padLeft(2, '0');
    return '${d.year.toString().padLeft(4, '0')}-${deux(d.month)}-'
        '${deux(d.day)}';
  }

  /// « 22/10/2011 » → « 2011-10-22 » ; null si la date n'existe pas.
  static String? isoDepuis(String jjmmaaaa) {
    final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(jjmmaaaa);
    if (m == null) return null;
    final j = int.parse(m[1]!);
    final mo = int.parse(m[2]!);
    final a = int.parse(m[3]!);
    final d = DateTime.utc(a, mo, j);
    if (d.day != j || d.month != mo || a < 1900 || a > 2100) return null;
    return iso(d);
  }

  @override
  State<AutoSaveDateField> createState() => _AutoSaveDateFieldState();
}

class _AutoSaveDateFieldState extends State<AutoSaveDateField> {
  late final _controller = TextEditingController(
    text: AutoSaveDateField.afficher(widget.initial) ?? '',
  );
  final _focus = FocusNode();
  String? _erreur;
  bool _saved = false;

  @override
  void didUpdateWidget(AutoSaveDateField old) {
    super.didUpdateWidget(old);
    final affichee = AutoSaveDateField.afficher(widget.initial) ?? '';
    if (widget.initial != old.initial &&
        !_focus.hasFocus &&
        _controller.text != affichee) {
      _controller.text = affichee;
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _valider(String texte) async {
    setState(() {
      _erreur = null;
      _saved = false;
    });
    if (texte.isEmpty) {
      await widget.onSave(null);
      return;
    }
    if (texte.length < 10) return; // saisie en cours
    final iso = AutoSaveDateField.isoDepuis(texte);
    if (iso == null) {
      setState(
        () => _erreur =
            'Date impossible : vérifiez le jour, le mois et '
            'l’année (jj/mm/aaaa).',
      );
      return;
    }
    await widget.onSave(iso);
    if (mounted) setState(() => _saved = true);
  }

  Future<void> _calendrier() async {
    final actuelle = widget.initial == null
        ? null
        : DateTime.tryParse(widget.initial!);
    final d = await showDatePicker(
      context: context,
      locale: const Locale('fr'),
      initialDate: actuelle ?? DateTime.now(),
      firstDate: widget.first ?? DateTime(1940),
      lastDate: widget.last ?? DateTime(DateTime.now().year + 5),
      helpText: widget.label,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (d == null) return;
    _controller.text = AutoSaveDateField._affichage.format(d);
    await _valider(_controller.text);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: _controller,
      focusNode: _focus,
      keyboardType: TextInputType.number,
      inputFormatters: [FormatDate()],
      onChanged: _valider,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: 'jj/mm/aaaa',
        helperText: widget.helper,
        helperMaxLines: 3,
        errorText: _erreur,
        errorMaxLines: 3,
        border: const OutlineInputBorder(),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_saved) const Icon(Icons.check, semanticLabel: 'Enregistré'),
            MicButton(
              compact: true,
              type: TypeDictee.date,
              texteActuel: () => _controller.text,
              inserer: (t) {
                _controller.text = dateDictee(t) ?? t;
                unawaited(_valider(_controller.text));
              },
            ),
            IconButton(
              tooltip: 'Calendrier',
              icon: const Icon(Icons.calendar_today_outlined),
              onPressed: _calendrier,
            ),
          ],
        ),
      ),
    ),
  );
}

/// Ne garde que les chiffres et place les barres : « 22102011 » →
/// « 22/10/2011 ».
class FormatDate extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var chiffres = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (chiffres.length > 8) chiffres = chiffres.substring(0, 8);
    final b = StringBuffer();
    for (var i = 0; i < chiffres.length; i++) {
      if (i == 2 || i == 4) b.write('/');
      b.write(chiffres[i]);
    }
    final texte = b.toString();
    return TextEditingValue(
      text: texte,
      selection: TextSelection.collapsed(offset: texte.length),
    );
  }
}

/// Choix parmi quelques valeurs (sexe, T/S…) : boutons visibles, pas de menu.
class ChoiceField extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String? value;

  /// valeur → libellé
  final Map<String, String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            for (final e in options.entries)
              ChoiceChip(
                label: Text(e.value),
                selected: value == e.key,
                onSelected: (on) => onChanged(on ? e.key : null),
              ),
          ],
        ),
      ],
    ),
  );
}

/// Rappel des champs libres du personnel et des élèves (17.8).
const rappelSante = 'N’indiquez pas d’informations médicales.';
