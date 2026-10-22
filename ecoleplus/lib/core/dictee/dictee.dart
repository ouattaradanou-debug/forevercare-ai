import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

/// Dictée vocale (module 13) : reconnaissance native du téléphone. Aucun
/// enregistrement audio n'est conservé par l'application ; seul le texte
/// reconnu revient, et il reste modifiable avant d'être enregistré.
abstract interface class Dictee {
  /// Demande l'autorisation du micro (la première fois) ; faux si le micro
  /// ou la reconnaissance vocale ne sont pas disponibles.
  Future<bool> preparer();

  /// Écoute ; [surTexte] reçoit le texte reconnu au fur et à mesure,
  /// [surFin] est appelé à la fin (avec un message d'erreur simple, ou null).
  Future<void> ecouter({
    required void Function(String texte) surTexte,
    required void Function(String? erreur) surFin,
  });

  Future<void> arreter();
}

class DicteeNative implements Dictee {
  final _stt = SpeechToText();
  void Function(String?)? _fin;

  @override
  Future<bool> preparer() async {
    try {
      return await _stt.initialize(
        onError: (e) => _terminer(_message(e.errorMsg)),
        onStatus: (s) {
          if (s == SpeechToText.doneStatus) _terminer(null);
        },
      );
    } on Object {
      return false;
    }
  }

  void _terminer(String? erreur) {
    final f = _fin;
    _fin = null;
    f?.call(erreur);
  }

  /// Messages clairs à la place des codes techniques (13.3).
  static String _message(String code) => switch (code) {
    'error_no_match' || 'error_speech_timeout' =>
      'Rien n’a été compris. Parlez plus près du téléphone, dans un endroit '
          'plus calme, puis réessayez.',
    'error_network' || 'error_network_timeout' || 'error_server' =>
      'La reconnaissance vocale a besoin d’Internet sur ce téléphone '
          '(ou du pack de langue française hors ligne). Utilisez le clavier.',
    'error_permission' || 'error_insufficient_permissions' =>
      'Le micro n’est pas autorisé. Autorisez-le dans les réglages du '
          'téléphone, ou utilisez le clavier.',
    _ => 'La dictée n’a pas fonctionné. Réessayez ou utilisez le clavier.',
  };

  @override
  Future<void> ecouter({
    required void Function(String texte) surTexte,
    required void Function(String? erreur) surFin,
  }) async {
    _fin = surFin;
    final francais = (await _stt.locales())
        .where((l) => l.localeId.toLowerCase().startsWith('fr'))
        .map((l) => l.localeId)
        .toList();
    await _stt.listen(
      onResult: (r) {
        surTexte(r.recognizedWords);
        if (r.finalResult) _terminer(null);
      },
      listenOptions: SpeechListenOptions(
        localeId: francais.contains('fr_FR') ? 'fr_FR' : francais.firstOrNull,
        listenFor: const Duration(minutes: 1),
        pauseFor: const Duration(seconds: 4),
        cancelOnError: true,
      ),
    );
  }

  @override
  Future<void> arreter() => _stt.stop();
}
