import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../data/models/article.dart';
import '../../../data/models/categorie_vente.dart';
import '../../../data/models/vente.dart';
import '../../../data/sync/ecriture_synchronisee.dart';
import '../../abonnement/data/abonnement_guard.dart';
import 'articles_repository.dart';

/// Gestion des ventes directes (prêt-à-porter, tissu, article de couture),
/// distinctes des commandes de couture sur mesure (voir `FinancesRepository`).
///
/// N'est appelé QUE depuis des écrans déjà réservés au propriétaire : donnée
/// financière, jamais accessible à un apprenti (même garantie RLS que
/// commandes/paiements/dépenses — voir supabase/schema.sql).
class VentesRepository {
  VentesRepository({
    required SupabaseClient client,
    required AppDatabase baseLocale,
    required ArticlesRepository articlesRepository,
  })  : _client = client,
        _baseLocale = baseLocale,
        _articlesRepository = articlesRepository;

  final SupabaseClient _client;
  final AppDatabase _baseLocale;
  final ArticlesRepository _articlesRepository;
  static const _uuid = Uuid();

  Vente _depuisLigne(VenteEntry ligne) => Vente(
        id: ligne.id,
        atelierId: ligne.atelierId,
        categorie: CategorieVente.depuisJson(ligne.categorie),
        designation: ligne.designation,
        quantite: ligne.quantite,
        prixUnitaire: ligne.prixUnitaire,
        montantTotal: ligne.montantTotal,
        date: ligne.date,
        createdAt: ligne.createdAt,
        articleId: ligne.articleId,
      );

  /// Enregistre la vente puis, si [article] est fourni (choisi dans le
  /// catalogue plutôt que saisi librement), décrémente automatiquement son
  /// stock de [quantite] — jamais négatif (voir
  /// `ArticlesRepository.decrementerStock`).
  Future<Vente> enregistrerVente({
    required String atelierId,
    required CategorieVente categorie,
    required String designation,
    required double quantite,
    required double prixUnitaire,
    required DateTime date,
    Article? article,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final vente = Vente(
      id: _uuid.v4(),
      atelierId: atelierId,
      categorie: categorie,
      designation: designation,
      quantite: quantite,
      prixUnitaire: prixUnitaire,
      montantTotal: quantite * prixUnitaire,
      date: date,
      createdAt: DateTime.now().toUtc(),
      articleId: article?.id,
    );

    await _mettreEnCache(vente);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'ventes',
      recordId: vente.id,
      operation: 'insert',
      payload: vente.versJson(),
    );

    if (article != null) {
      await _articlesRepository.decrementerStock(article: article, quantiteVendue: quantite);
    }
    return vente;
  }

  /// Corrige une vente déjà enregistrée (erreur de saisie : désignation,
  /// quantité, prix ou date). Si la vente est liée à un article du
  /// catalogue et que la quantité change, ajuste le stock de la différence
  /// (une quantité revue à la hausse retire la différence du stock, une
  /// quantité revue à la baisse la lui rend) — jamais négatif, comme à
  /// l'enregistrement initial.
  Future<Vente> modifierVente({
    required Vente vente,
    required String designation,
    required double quantite,
    required double prixUnitaire,
    required DateTime date,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, vente.atelierId);
    // Même précaution que ArticlesRepository.modifierArticle : purge
    // d'abord toute tâche de synchronisation périmée pour cette vente,
    // pour qu'un essai précédent resté bloqué hors-ligne ne vienne pas
    // écraser cette correction plus tard.
    await _baseLocale.retirerTachesPourEnregistrement('ventes', vente.id);
    final miseAJour = Vente(
      id: vente.id,
      atelierId: vente.atelierId,
      categorie: vente.categorie,
      designation: designation,
      quantite: quantite,
      prixUnitaire: prixUnitaire,
      montantTotal: quantite * prixUnitaire,
      date: date,
      createdAt: vente.createdAt,
      articleId: vente.articleId,
    );

    await _mettreEnCache(miseAJour);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'ventes',
      recordId: miseAJour.id,
      operation: 'update',
      payload: miseAJour.versJson(),
    );

    final articleId = vente.articleId;
    final difference = quantite - vente.quantite;
    if (articleId != null && difference != 0) {
      final article = await _articlesRepository.articleParId(articleId);
      if (article != null) {
        if (difference > 0) {
          await _articlesRepository.decrementerStock(
            article: article,
            quantiteVendue: difference,
          );
        } else {
          await _articlesRepository.reapprovisionner(
            article: article,
            quantiteAjoutee: -difference,
          );
        }
      }
    }
    return miseAJour;
  }

  /// Historique des ventes de l'atelier, du plus récent au plus ancien —
  /// pour l'écran "Historique des ventes" (filtrable ensuite par période et
  /// par catégorie côté écran).
  Stream<List<Vente>> observerVentes(String atelierId) {
    return _baseLocale
        .observerVentesDeLAtelier(atelierId)
        .map((lignes) => lignes.map(_depuisLigne).toList());
  }

  /// Rapatriement initial best-effort depuis Supabase (autres appareils, ou
  /// ventes ajoutées avant l'installation de cet appareil).
  Future<void> chargerDepuisServeur(String atelierId) async {
    try {
      final lignes = await _client.from('ventes').select().eq('atelier_id', atelierId);
      for (final ligne in lignes) {
        await _mettreEnCache(Vente.depuisJson(ligne));
      }
    } catch (_) {
      // Hors-ligne : le cache existant reste utilisable.
    }
  }

  Future<void> _mettreEnCache(Vente vente) {
    return _baseLocale.enregistrerVente(
      id: vente.id,
      atelierId: vente.atelierId,
      categorie: vente.categorie.valeurJson,
      designation: vente.designation,
      quantite: vente.quantite,
      prixUnitaire: vente.prixUnitaire,
      montantTotal: vente.montantTotal,
      date: vente.date,
      createdAt: vente.createdAt,
      articleId: vente.articleId,
    );
  }
}
