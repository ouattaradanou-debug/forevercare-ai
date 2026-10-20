import 'dart:async';

import 'package:ecoleplus/app/providers.dart';
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
    super.key,
  });

  final String title;
  final Widget body;
  final bool showSync;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
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

/// « Tout est synchronisé » / « N éléments en attente » (R3).
class SyncBanner extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).value;
    if (status == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final ok =
        status.pending == 0 &&
        status.refused == 0 &&
        status.state.phase != SyncPhase.sessionExpired;
    final (icon, color) = switch (status) {
      _ when status.state.phase == SyncPhase.running => (
        Icons.sync,
        scheme.primary,
      ),
      _ when status.refused > 0 => (Icons.error_outline, scheme.error),
      _ when ok => (Icons.cloud_done_outlined, scheme.primary),
      _ when status.state.phase == SyncPhase.offline => (
        Icons.cloud_off_outlined,
        scheme.tertiary,
      ),
      _ => (Icons.cloud_upload_outlined, scheme.tertiary),
    };
    return Material(
      color: color.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () => context.push('/synchronisation'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  status.label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
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
    this.keyboardType,
    this.enabled = true,
    super.key,
  });

  final String label;
  final String? initial;
  final String? hint;
  final TextInputType? keyboardType;
  final bool enabled;
  final Future<void> Function(String? value) onSave;

  @override
  State<AutoSaveField> createState() => _AutoSaveFieldState();
}

class _AutoSaveFieldState extends State<AutoSaveField> {
  late final _controller = TextEditingController(text: widget.initial ?? '');
  Timer? _timer;
  bool _saved = false;

  void _changed(String v) {
    _timer?.cancel();
    setState(() => _saved = false);
    _timer = Timer(const Duration(milliseconds: 700), () async {
      final value = v.trim().isEmpty ? null : v.trim();
      await widget.onSave(value);
      if (mounted) setState(() => _saved = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      onChanged: _changed,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        border: const OutlineInputBorder(),
        suffixIcon: _saved
            ? const Icon(Icons.check, semanticLabel: 'Enregistré')
            : null,
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const new(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 12),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
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
        Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
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
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  } on Object {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Une erreur est survenue. Réessayez.')),
      );
    }
  }
  return null;
}
