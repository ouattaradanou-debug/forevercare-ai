import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../data/models/article.dart';
import '../../../data/models/categorie_vente.dart';
import '../../../data/sync/ecriture_synchronisee.dart';
import '../../abonnement/data/abonnement_guard.dart';

/// Catalogue d'articles suivis en stock (prêt-à-porter, tissu, article de
/// couture) : création, réapprovisionnement et décrémentation automatique
/// lors d'une vente (voir `VentesRepository.enregistrerVente`).
///
/// N'est appelé QUE depuis des écrans déjà réservés au propriétaire — même
/// garantie RLS que `VentesRepository` (voir supabase/schema.sql).
class ArticlesRepository {
  ArticlesRepository({required SupabaseClient client, required AppDatabase baseLocale})
      : _client = client,
        _baseLocale = baseLocale;

  final SupabaseClient _client;
  final AppDatabase _baseLocale;
  static const _uuid = Uuid();

  Article _depuisLigne(ArticleEntry ligne) => Article(
        id: ligne.id,
        atelierId: ligne.atelierId,
        categorie: CategorieVente.depuisJson(ligne.categorie),
        nom: ligne.nom,
        prixUnitaireDefaut: ligne.prixUnitaireDefaut,
        quantiteStock: ligne.quantiteStock,
        seuilAlerte: ligne.seuilAlerte,
        createdAt: ligne.createdAt,
        updatedAt: ligne.updatedAt,
        unite: ligne.unite,
      );

  Future<Article> ajouterArticle({
    required String atelierId,
    required CategorieVente categorie,
    required String nom,
    required double prixUnitaireDefaut,
    required double quantiteInitiale,
    required double seuilAlerte,
    String? unite,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, atelierId);
    final maintenant = DateTime.now().toUtc();
    final article = Article(
      id: _uuid.v4(),
      atelierId: atelierId,
      categorie: categorie,
      nom: nom,
      prixUnitaireDefaut: prixUnitaireDefaut,
      quantiteStock: quantiteInitiale,
      seuilAlerte: seuilAlerte,
      createdAt: maintenant,
      updatedAt: maintenant,
      unite: unite,
    );

    await _mettreEnCache(article);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'articles',
      recordId: article.id,
      operation: 'insert',
      payload: article.versJson(),
    );
    return article;
  }

  /// Corrige nom/prix par défaut/seuil d'alerte/unité, sans toucher au
  /// stock (voir [reapprovisionner] et la décrémentation automatique à la
  /// vente).
  Future<Article> modifierArticle({
    required Article article,
    required String nom,
    required double prixUnitaireDefaut,
    required double seuilAlerte,
    String? unite,
  }) async {
    await verifierEcritureAutorisee(_baseLocale, article.atelierId);
    final miseAJour = Article(
      id: article.id,
      atelierId: article.atelierId,
      categorie: article.categorie,
      nom: nom,
      prixUnitaireDefaut: prixUnitaireDefaut,
      quantiteStock: article.quantiteStock,
      seuilAlerte: seuilAlerte,
      createdAt: article.createdAt,
      updatedAt: DateTime.now().toUtc(),
      unite: unite ?? article.unite,
    );

    await _mettreEnCache(miseAJour);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'articles',
      recordId: miseAJour.id,
      operation: 'update',
      payload: miseAJour.versJson(),
    );
    return miseAJour;
  }

  /// Remplace directement la quantité en stock par [nouvelleQuantite] —
  /// contrairement à [reapprovisionner] (qui ajoute) ou [decrementerStock]
  /// (qui retire), pour corriger une erreur de saisie (mauvaise quantité de
  /// départ, mauvais nombre reçu lors d'une livraison, comptage physique
  /// différent...). Jamais négatif.
  Future<Article> corrigerStock({
    required Article article,
    required double nouvelleQuantite,
  }) {
    return _ajusterStock(article, nouvelleQuantite < 0 ? 0 : nouvelleQuantite);
  }

  /// Ajoute [quantiteAjoutee] au stock (nouvelle livraison reçue).
  Future<Article> reapprovisionner({
    required Article article,
    required double quantiteAjoutee,
  }) {
    return _ajusterStock(article, article.quantiteStock + quantiteAjoutee);
  }

  /// Retire [quantiteVendue] du stock suite à une vente — jamais négatif
  /// (une vente plus grande que le stock restant, confirmée malgré
  /// l'avertissement, ramène simplement le stock à zéro).
  Future<Article> decrementerStock({
    required Article article,
    required double quantiteVendue,
  }) {
    final nouveauStock = article.quantiteStock - quantiteVendue;
    return _ajusterStock(article, nouveauStock < 0 ? 0 : nouveauStock);
  }

  Future<Article> _ajusterStock(Article article, double nouvelleQuantite) async {
    await verifierEcritureAutorisee(_baseLocale, article.atelierId);
    final miseAJour = Article(
      id: article.id,
      atelierId: article.atelierId,
      categorie: article.categorie,
      nom: article.nom,
      prixUnitaireDefaut: article.prixUnitaireDefaut,
      quantiteStock: nouvelleQuantite,
      seuilAlerte: article.seuilAlerte,
      createdAt: article.createdAt,
      updatedAt: DateTime.now().toUtc(),
      unite: article.unite,
    );

    await _mettreEnCache(miseAJour);
    await ecrireEtSynchroniser(
      client: _client,
      baseLocale: _baseLocale,
      table: 'articles',
      recordId: miseAJour.id,
      operation: 'update',
      payload: miseAJour.versJson(),
    );
    return miseAJour;
  }

  /// Article du catalogue par id, lu depuis le cache local — utilisé par
  /// `VentesRepository.modifierVente` pour ajuster le stock d'un article
  /// quand la quantité d'une vente déjà enregistrée est corrigée.
  Future<Article?> articleParId(String id) async {
    final ligne = await _baseLocale.articleParId(id);
    return ligne == null ? null : _depuisLigne(ligne);
  }

  /// Catalogue de l'atelier, trié par nom — pour l'écran "Gestion du
  /// stock" et le choix d'article dans le formulaire de vente.
  Stream<List<Article>> observerArticles(String atelierId) {
    return _baseLocale
        .observerArticlesDeLAtelier(atelierId)
        .map((lignes) => lignes.map(_depuisLigne).toList());
  }

  /// Rapatriement initial best-effort depuis Supabase (autres appareils, ou
  /// articles ajoutés avant l'installation de cet appareil).
  Future<void> chargerDepuisServeur(String atelierId) async {
    try {
      final lignes = await _client.from('articles').select().eq('atelier_id', atelierId);
      for (final ligne in lignes) {
        await _mettreEnCache(Article.depuisJson(ligne));
      }
    } catch (_) {
      // Hors-ligne : le cache existant reste utilisable.
    }
  }

  Future<void> _mettreEnCache(Article article) {
    return _baseLocale.enregistrerArticle(
      id: article.id,
      atelierId: article.atelierId,
      categorie: article.categorie.valeurJson,
      nom: article.nom,
      prixUnitaireDefaut: article.prixUnitaireDefaut,
      quantiteStock: article.quantiteStock,
      seuilAlerte: article.seuilAlerte,
      createdAt: article.createdAt,
      updatedAt: article.updatedAt,
      unite: article.unite,
    );
  }
}
