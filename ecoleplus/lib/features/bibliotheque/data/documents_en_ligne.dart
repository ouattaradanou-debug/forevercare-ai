import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Passage trouvé dans le texte intégral d'un document.
class Trouvaille {
  const new({required this.documentId, required this.extrait, this.page});
  final String documentId;
  final int? page;

  /// Extrait, mots trouvés entre « ».
  final String extrait;
}

/// Espace utilisé par l'école.
class Occupation {
  const new({required this.utilise, required this.quota, this.documents = 0});
  final int utilise;
  final int quota;
  final int documents;

  int get pourcent => quota == 0 ? 0 : (utilise * 100 / quota).round();
}

/// Ce qui demande Internet : recherche dans le texte intégral (index du
/// serveur, mêmes droits que les documents) et espace exact utilisé.
abstract interface class DocumentsEnLigne {
  Future<List<Trouvaille>> rechercher(String schoolId, String requete);
  Future<Occupation> occupation(String schoolId);

  /// Efface définitivement un document de la corbeille : son fichier puis
  /// sa fiche (Internet nécessaire).
  Future<void> effacer(String documentId, String? cheminFichier);
}

const messageEffacementHorsLigne =
    'Effacer définitivement : connexion à Internet nécessaire.';

const messageRechercheHorsLigne =
    'Recherche dans le texte : connexion à Internet nécessaire. La recherche '
    'par titre et par fiche marche sans Internet.';

class SupabaseDocumentsEnLigne implements DocumentsEnLigne {
  new(this.client);
  final SupabaseClient client;

  @override
  Future<List<Trouvaille>> rechercher(String schoolId, String requete) async {
    try {
      final r = await client.rpc<dynamic>(
        'documents_search',
        params: {'p_school': schoolId, 'p_query': requete, 'p_limit': 50},
      );
      return [
        for (final l in (r as List<dynamic>).cast<Map<String, dynamic>>())
          Trouvaille(
            documentId: l['document_id'] as String,
            page: l['page'] as int?,
            extrait: l['extrait'] as String,
          ),
      ];
    } on PostgrestException catch (e) {
      throw UserMessage(e.message);
    } on Object {
      throw const UserMessage(messageRechercheHorsLigne);
    }
  }

  @override
  Future<void> effacer(String documentId, String? cheminFichier) async {
    try {
      if (cheminFichier != null) {
        await client.storage.from('documents').remove([cheminFichier]);
      }
      await client.rpc<dynamic>(
        'document_effacer',
        params: {'p_doc': documentId},
      );
    } on PostgrestException catch (e) {
      throw UserMessage(e.message);
    } on StorageException catch (e) {
      throw UserMessage('Effacement du fichier refusé : ${e.message}');
    } on Object {
      throw const UserMessage(messageEffacementHorsLigne);
    }
  }

  @override
  Future<Occupation> occupation(String schoolId) async {
    final r = await client.rpc<dynamic>(
      'documents_usage',
      params: {'p_school': schoolId},
    );
    final l = (r as List<dynamic>).cast<Map<String, dynamic>>().first;
    return Occupation(
      utilise: (l['used_bytes'] as num).toInt(),
      quota: (l['quota_bytes'] as num).toInt(),
      documents: l['documents'] as int,
    );
  }
}
