import 'dart:async';
import 'dart:io';

import 'package:ecoleplus/features/auth/data/auth_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Une section d'une fiche proposée par l'IA.
class SectionIa {
  const new(this.titre, this.contenu);
  factory fromJson(Map<String, dynamic> j) =>
      SectionIa('${j['titre'] ?? ''}', '${j['contenu'] ?? ''}');
  final String titre;
  final String contenu;
  Map<String, dynamic> toJson() => {'titre': titre, 'contenu': contenu};
}

/// Fiche : titre et sections (préparation, exercices, remédiation).
class FicheIa {
  const new(this.titre, this.sections);
  factory fromJson(Map<String, dynamic> j) => FicheIa('${j['titre'] ?? ''}', [
    for (final s in (j['sections'] as List<dynamic>? ?? const []))
      SectionIa.fromJson(Map<String, dynamic>.from(s as Map)),
  ]);
  final String titre;
  final List<SectionIa> sections;
  Map<String, dynamic> toJson() => {
    'titre': titre,
    'sections': [for (final s in sections) s.toJson()],
    'sources': const <int>[],
    'hors_documents': false,
  };

  /// Texte brut (partage, PDF).
  String get texte => [
    titre,
    for (final s in sections) '\n${s.titre}\n${s.contenu}',
  ].join('\n');
}

/// Document de la bibliothèque utilisé par l'IA.
class SourceIa {
  const new({required this.documentId, required this.titre, this.page});
  factory fromJson(Map<String, dynamic> j) => SourceIa(
    documentId: '${j['document_id']}',
    titre: '${j['titre'] ?? ''}',
    page: (j['page'] as num?)?.toInt(),
  );
  final String documentId;
  final String titre;
  final int? page;
  Map<String, dynamic> toJson() => {
    'document_id': documentId,
    'titre': titre,
    'page': page,
  };
  String get libelle => page == null ? titre : '$titre (p. $page)';
}

/// Demandes restantes ce mois-ci.
class Restant {
  const new({required this.enseignant, required this.ecole, this.limite = 30});
  factory fromJson(Map<String, dynamic>? j) => Restant(
    enseignant: (j?['enseignant'] as num?)?.toInt() ?? 0,
    ecole: (j?['ecole'] as num?)?.toInt() ?? 0,
    limite: (j?['limite'] as num?)?.toInt() ?? 30,
  );
  final int enseignant;
  final int ecole;
  final int limite;

  /// Ce que la personne peut encore demander (la plus petite des deux).
  int get disponible => enseignant < ecole ? enseignant : ecole;
}

class ReponseIa {
  const new({
    required this.fiche,
    required this.sources,
    required this.restant,
    this.extraitsRetires = 0,
    this.modele = '',
  });
  final FicheIa fiche;
  final List<SourceIa> sources;
  final Restant restant;
  final int extraitsRetires;
  final String modele;
  bool get horsDocuments => sources.isEmpty;
}

/// Document que l'on peut cocher pour l'IA.
class DocumentIa {
  const new(this.id, this.titre, {this.indexe = true});
  final String id;
  final String titre;
  final bool indexe;
}

/// Usage du mois d'une personne (suivi du directeur).
class UsageIa {
  const new({
    required this.membershipId,
    required this.nom,
    required this.demandes,
    required this.limite,
    required this.coutMicroUsd,
  });
  final String membershipId;
  final String nom;
  final int demandes;
  final int limite;
  final int coutMicroUsd;
}

/// Usage de l'école (totaux du mois).
class UsageEcole {
  const new(
    this.lignes, {
    required this.demandes,
    required this.limite,
    required this.coutMicroUsd,
    required this.budgetMicroUsd,
  });
  final List<UsageIa> lignes;
  final int demandes;
  final int limite;
  final int coutMicroUsd;
  final int budgetMicroUsd;
}

/// Pas d'Internet : la demande est gardée sur le téléphone.
class HorsLigneIa implements Exception {
  const new();
}

/// Message clair pour une limite atteinte (ne pas réessayer).
class LimiteIa extends UserMessage {
  const new(super.message);
}

/// Accès à l'assistant : uniquement par la fonction du serveur
/// « assistant-ia » (la clé du fournisseur n'est jamais sur le téléphone).
abstract class AssistantApi {
  Future<ReponseIa> demander(Map<String, Object?> demande);
  Future<Restant> restant(String schoolId);
  Future<List<DocumentIa>> documents(String schoolId);
  Future<UsageEcole> usageEcole(String schoolId);
}

class SupabaseAssistantApi implements AssistantApi {
  new(this.client);
  final SupabaseClient client;

  Future<T> _appel<T>(Future<T> Function() f) async {
    try {
      return await f().timeout(const Duration(seconds: 90));
    } on FunctionException catch (e) {
      final d = e.details;
      final msg = d is Map && d['erreur'] != null
          ? '${d['erreur']}'
          : 'L’assistant n’a pas pu répondre. Réessayez.';
      if (e.status == 429) throw LimiteIa(msg);
      throw UserMessage(msg);
    } on PostgrestException catch (e) {
      throw UserMessage(e.message);
    } on SocketException {
      throw const HorsLigneIa();
    } on TimeoutException {
      throw const HorsLigneIa();
    } on AuthException {
      throw const UserMessage('Veuillez vous reconnecter.');
    }
  }

  Map<String, dynamic> _json(Object? data) =>
      Map<String, dynamic>.from(data! as Map);

  @override
  Future<ReponseIa> demander(Map<String, Object?> demande) => _appel(() async {
    final r = await client.functions.invoke('assistant-ia', body: demande);
    final j = _json(r.data);
    return ReponseIa(
      fiche: FicheIa.fromJson(Map<String, dynamic>.from(j['fiche'] as Map)),
      sources: [
        for (final s in (j['sources'] as List<dynamic>? ?? const []))
          SourceIa.fromJson(Map<String, dynamic>.from(s as Map)),
      ],
      restant: Restant.fromJson(
        j['restant'] == null
            ? null
            : Map<String, dynamic>.from(j['restant'] as Map),
      ),
      extraitsRetires: (j['extraits_retires'] as num?)?.toInt() ?? 0,
      modele: '${j['modele'] ?? ''}',
    );
  });

  @override
  Future<Restant> restant(String schoolId) => _appel(() async {
    final r = await client.functions.invoke(
      'assistant-ia',
      body: {'school_id': schoolId, 'kind': 'usage'},
    );
    final j = _json(r.data);
    return Restant.fromJson(
      j['restant'] == null
          ? null
          : Map<String, dynamic>.from(j['restant'] as Map),
    );
  });

  @override
  Future<List<DocumentIa>> documents(String schoolId) => _appel(() async {
    final rows = await client.rpc<List<dynamic>>(
      'ia_documents',
      params: {'p_school': schoolId},
    );
    return [
      for (final r in rows)
        DocumentIa(
          '${(r as Map)['document_id']}',
          '${r['titre']}',
          indexe: r['indexe'] == true,
        ),
    ];
  });

  @override
  Future<UsageEcole> usageEcole(String schoolId) => _appel(() async {
    final rows = await client.rpc<List<dynamic>>(
      'ia_usage',
      params: {'p_school': schoolId},
    );
    final l = [for (final r in rows) Map<String, dynamic>.from(r as Map)];
    int n(Map<String, dynamic> m, String k) => (m[k] as num?)?.toInt() ?? 0;
    return UsageEcole(
      [
        for (final m in l)
          UsageIa(
            membershipId: '${m['membership_id']}',
            nom: '${m['nom']}',
            demandes: n(m, 'demandes'),
            limite: n(m, 'limite'),
            coutMicroUsd: n(m, 'cout_microusd'),
          ),
      ],
      demandes: l.isEmpty ? 0 : n(l.first, 'ecole_demandes'),
      limite: l.isEmpty ? 300 : n(l.first, 'ecole_limite'),
      coutMicroUsd: l.isEmpty ? 0 : n(l.first, 'ecole_cout_microusd'),
      budgetMicroUsd: l.isEmpty ? 5000000 : n(l.first, 'ecole_budget_microusd'),
    );
  });
}
