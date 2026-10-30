import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:ecoleplus/features/bibliotheque/data/documents_en_ligne.dart';

import 'fake_server.dart';

/// Recherche dans le texte et espace utilisé, simulés : le texte « lu »
/// de chaque document est donné par le test (comme après l'indexation).
class FakeDocumentsEnLigne implements DocumentsEnLigne {
  new(this.server);
  final FakeServer server;
  bool enLigne = true;

  /// Texte lu par l'indexeur : identifiant du document → (page, texte).
  final Map<String, List<(int, String)>> textes = {};

  /// Documents que la personne connectée a le droit de lire (null : tous).
  Set<String>? lisibles;

  @override
  Future<List<Trouvaille>> rechercher(String schoolId, String requete) async {
    if (!enLigne) throw const UserMessage(messageRechercheHorsLigne);
    final q = requete.toLowerCase();
    return [
      for (final MapEntry(key: id, value: pages) in textes.entries)
        if (lisibles == null || lisibles!.contains(id))
          for (final (page, texte) in pages)
            if (texte.toLowerCase().contains(q))
              Trouvaille(documentId: id, page: page, extrait: '« $requete »'),
    ];
  }

  @override
  Future<void> effacer(String documentId, String? cheminFichier) async {
    if (!enLigne) throw const UserMessage(messageEffacementHorsLigne);
    final d = server.tables['documents']![documentId]!;
    if (d['trashed_at'] == null) {
      throw const UserMessage('Mettez d’abord le document à la corbeille.');
    }
    if (cheminFichier != null) server.files.remove('documents/$cheminFichier');
    server.seed('documents', {
      ...d,
      'deleted_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<Occupation> occupation(String schoolId) async {
    if (!enLigne) throw const UserMessage(messageRechercheHorsLigne);
    final docs = server.tables['documents']?.values ?? const [];
    final ecole = server.tables['schools']?[schoolId];
    return Occupation(
      utilise: docs.fold<int>(
        0,
        (s, d) => s + ((d['size_bytes'] as num?)?.toInt() ?? 0),
      ),
      quota: (ecole?['storage_quota_bytes'] as num?)?.toInt() ?? 5368709120,
      documents: docs.length,
    );
  }
}
