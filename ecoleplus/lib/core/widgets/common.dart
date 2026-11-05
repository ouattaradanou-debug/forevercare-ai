import 'dart:async';

import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/app/theme.dart';
import 'package:ecoleplus/core/dictee/mic_button.dart';
import 'package:ecoleplus/core/sync/sync_engine.dart';
import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Écran standard : titre, bandeau de synchronisation toujours visible.
class EcoleScaffold extends StatelessWidget {
  const new({
    required this.title,
    required this.body,
    this.showSync = true,
    this.actions,
    super.key,
  });

  final String title;
  final Widget body;
  final bool showSync;

  /// Boutons de la barre de titre (cloche de l'accueil).
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    // Titre long (nom de l'école) : sur deux lignes plutôt que coupé.
    appBar: AppBar(
      actions: actions,
      toolbarHeight: title.length > 22 ? 76 : null,
      title: Text(
        title,
        key: const Key('titre-page'),
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    body: SafeArea(
      child: Column(
        children: [
          if (showSync) const SyncBanner(),
          Expanded(child: body),
        ],
      ),
    ),
  );
}

/// État de la synchronisation (R3), en 4 situations : synchronisé (vert),
/// en cours (bleu), en attente (ambre), problème (rouge).
({IconData icone, Color couleur, Color fond}) apparenceSynchro(
  SyncStatus status,
) {
  final ok =
      status.pending == 0 &&
      status.refused == 0 &&
      status.state.phase != SyncPhase.sessionExpired;
  return switch (status) {
    _ when status.state.phase == SyncPhase.running => (
      icone: Icons.sync,
      couleur: Charte.bleu,
      fond: Charte.bleuClair,
    ),
    _
        when status.refused > 0 ||
            status.state.phase == SyncPhase.sessionExpired =>
      (
        icone: Icons.sync_problem,
        couleur: Charte.rouge,
        fond: Charte.rougePale,
      ),
    _ when ok => (
      icone: Icons.cloud_done,
      couleur: Charte.vert,
      fond: Charte.vertPale,
    ),
    _ => (
      icone: status.state.phase == SyncPhase.offline
          ? Icons.cloud_off
          : Icons.cloud_upload,
      couleur: Charte.ambre,
      fond: Charte.ambrePale,
    ),
  };
}

/// « Tout est synchronisé » / « N éléments en attente » : bandeau discret
/// en haut de chaque écran ; touchez-le pour l'écran de synchronisation.
class SyncBanner extends ConsumerWidget {
  const new({this.compact = false, super.key});

  /// Pastille arrondie (accueil) au lieu d'un bandeau pleine largeur.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).value;
    if (status == null) return SizedBox(height: compact ? 34 : 0);
    final a = apparenceSynchro(status);
    final contenu = Row(
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Icon(a.icone, color: a.couleur, size: compact ? 18 : 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            compact ? status.court : status.label,
            key: compact ? const Key('synchro') : null,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: a.couleur,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 13.5 : 14,
            ),
          ),
        ),
      ],
    );
    if (compact) {
      return Material(
        color: a.fond,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => context.push('/synchronisation'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: contenu,
          ),
        ),
      );
    }
    return Material(
      color: a.fond,
      child: InkWell(
        onTap: () => context.push('/synchronisation'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: contenu,
        ),
      ),
    );
  }
}

/// Champ de texte enregistré automatiquement (pas de bouton « Enregistrer »).
class AutoSaveField extends StatefulWidget {
  const new({
    required this.label,
    required this.initial,
    required this.onSave,
    this.hint,
    this.helper,
    this.keyboardType,
    this.enabled = true,
    this.maxLines = 1,
    this.micro = true,
    this.dictee,
    this.verifier,
    super.key,
  });

  final String label;

  /// Vérification avant enregistrement (ex. identifiant déjà utilisé) :
  /// renvoie un message pour refuser la valeur, sinon null.
  final Future<String?> Function(String? value)? verifier;
  final String? initial;
  final String? hint;

  /// Rappel affiché sous le champ (ex. « pas d'informations médicales »).
  final String? helper;
  final int maxLines;

  /// Micro dans le champ (A13) : dicter au lieu de taper.
  final bool micro;

  /// Ce que l'on dicte ; par défaut un numéro pour un champ téléphone,
  /// sinon du texte.
  final TypeDictee? dictee;
  final TextInputType? keyboardType;
  final bool enabled;
  final Future<void> Function(String? value) onSave;

  @override
  State<AutoSaveField> createState() => _AutoSaveFieldState();
}

class _AutoSaveFieldState extends State<AutoSaveField> {
  late final _controller = TextEditingController(text: widget.initial ?? '');
  final _focus = FocusNode();
  Timer? _timer;
  bool _saved = false;
  String? _erreur;

  void _changed(String v) {
    _timer?.cancel();
    setState(() {
      _saved = false;
      _erreur = null;
    });
    _timer = Timer(const Duration(milliseconds: 700), () async {
      final value = v.trim().isEmpty ? null : v.trim();
      final refus = await widget.verifier?.call(value);
      if (refus != null) {
        if (mounted) setState(() => _erreur = refus);
        return;
      }
      await widget.onSave(value);
      if (mounted) setState(() => _saved = true);
    });
  }

  /// La valeur enregistrée a changé ailleurs (synchronisation, refus du
  /// serveur) : on l'affiche, sauf pendant que la personne écrit.
  @override
  void didUpdateWidget(AutoSaveField old) {
    super.didUpdateWidget(old);
    if (widget.initial != old.initial &&
        !_focus.hasFocus &&
        (_timer == null || !_timer!.isActive) &&
        _controller.text != (widget.initial ?? '')) {
      _controller.text = widget.initial ?? '';
      _saved = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final champ = TextField(
      controller: _controller,
      focusNode: _focus,
      enabled: widget.enabled,
      keyboardType: widget.maxLines > 1
          ? TextInputType.multiline
          : widget.keyboardType,
      maxLines: widget.maxLines,
      minLines: 1,
      onChanged: _changed,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helper,
        helperMaxLines: 3,
        errorText: _erreur,
        errorMaxLines: 3,
        border: const OutlineInputBorder(),
        suffixIcon: _suffixe(),
      ),
    );
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: champ);
  }

  Widget? _suffixe() {
    final coche = _saved
        ? const Icon(Icons.check, semanticLabel: 'Enregistré')
        : null;
    if (!widget.micro || !widget.enabled) return coche;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?coche,
        MicButton(
          compact: true,
          ajouter: widget.maxLines > 1,
          type:
              widget.dictee ??
              (widget.keyboardType == TextInputType.phone
                  ? TypeDictee.numero
                  : TypeDictee.texte),
          texteActuel: () => _controller.text,
          inserer: inserer,
        ),
      ],
    );
  }

  /// Texte inséré par un autre moyen (dictée) : enregistré comme une frappe.
  void inserer(String texte) {
    _controller.text = texte;
    _changed(texte);
  }
}

class SectionTitle extends StatelessWidget {
  const new(this.text, {super.key});
  final String text;

  /// Titre de section : marine, gras, petit trait orange devant.
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 10),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Charte.orange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

/// Message clair pour un écran vide, une erreur ou le mode hors ligne.
class InfoMessage extends StatelessWidget {
  const new(this.text, {this.icon = Icons.info_outline, super.key});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Charte.bleuClair,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 36, color: Charte.bleu),
        ),
        const SizedBox(height: 14),
        Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: Charte.texteSecondaire),
        ),
      ],
    ),
  );
}

Future<bool> confirmer(
  BuildContext context, {
  required String titre,
  required String message,
  required String bouton,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(titre),
      content: SingleChildScrollView(child: Text(message)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, true),
          child: Text(bouton),
        ),
      ],
    ),
  );
  return r ?? false;
}

/// Exécute une action et affiche son erreur en français simple.
Future<T?> avecMessage<T>(BuildContext context, Future<T> Function() f) async {
  try {
    return await f();
  } on UserMessage catch (e) {
    if (context.mounted) messageErreur(context, e.message);
  } on Object {
    if (context.mounted) {
      messageErreur(context, 'Une erreur est survenue. Réessayez.');
    }
  }
  return null;
}

/// Message de réussite (vert), même apparence dans tous les modules.
void messageSucces(BuildContext context, String texte) =>
    _message(context, texte, Icons.check_circle, Charte.vert);

/// Message d'erreur (rouge), même apparence dans tous les modules.
void messageErreur(BuildContext context, String texte) =>
    _message(context, texte, Icons.error, Charte.rouge);

void _message(BuildContext context, String texte, IconData icone, Color c) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: c,
      content: Row(
        children: [
          Icon(icone, color: Charte.blanc),
          const SizedBox(width: 10),
          Expanded(child: Text(texte)),
        ],
      ),
    ),
  );
}

/// Pastille de statut (Soldé, En attente, Refusé…) : mêmes couleurs dans
/// tous les modules.
class PastilleStatut extends StatelessWidget {
  const new(this.texte, this.statut, {this.icone = false, super.key});
  final String texte;
  final TonStatut statut;
  final bool icone;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: statut.fond,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icone) ...[
          Icon(statut.icone, size: 14, color: statut.couleur),
          const SizedBox(width: 4),
        ],
        Text(
          texte,
          style: TextStyle(
            color: statut.couleur,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}
