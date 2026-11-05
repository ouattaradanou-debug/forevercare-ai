import 'dart:io';

import 'package:ecoleplus/app/app.dart';
import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/app/theme.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/options/domain/module_rules.dart';
import 'package:ecoleplus/features/pilotage/domain/accueil.dart';
import 'package:ecoleplus/features/pilotage/presentation/accueil_pages.dart';
import 'package:ecoleplus/features/pilotage/presentation/bord_pages.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/security/domain/journal.dart';
import 'package:ecoleplus/features/security/presentation/security_providers.dart';
import 'package:ecoleplus/features/sync/domain/sync_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

/// Une tuile de la grille de l'accueil (module ou accès rapide).
class TuileAccueil {
  const new(this.id, this.label, this.icone, this.route, this.couleur);
  final String id;
  final String label;
  final IconData icone;
  final String route;
  final CouleurModule couleur;
}

/// Accueil mobile (A28) : tout tient sur un seul écran vertical, sans
/// défilement. En-tête (logo et nom de l'école, notifications, profil),
/// bienvenue, synchronisation, grille de 3 colonnes (tableau de bord,
/// recherche, modules), déconnexion.
class HomePage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;
    if (session == null) return const Scaffold();
    final school = ref.watch(schoolProvider(session.schoolId)).value;
    final themes = ref.watch(themesProvider);
    final directeur = session.role == 'directeur';
    final enseignant = session.role == 'enseignant';
    final tuiles = [
      if (directeur || enseignant)
        TuileAccueil(
          'bord',
          enseignant ? 'Mon tableau de bord' : 'Tableau de bord',
          Icons.space_dashboard_rounded,
          '/tableau-de-bord',
          CouleurModule.bord,
        ),
      const TuileAccueil(
        'recherche',
        'Rechercher',
        Icons.search_rounded,
        '/recherche',
        CouleurModule.recherche,
      ),
      for (final t in themes)
        TuileAccueil(
          t.id,
          t.label,
          _iconeTheme(t),
          t.route,
          CouleurModule.duTheme(t.id),
        ),
    ];
    final droits = ref.watch(mesDroitsHomeProvider);
    return Scaffold(
      backgroundColor: Charte.fond,
      body: Column(
        children: [
          _EnTete(
            ecole: school?.name ?? appName,
            annee: null,
            logo: _cheminLogo(ref, school?.logoPath),
            initiales: _initiales(school?.name ?? appName),
            utilisateur: session.displayName,
            onDeconnexion: () => _logout(context, ref),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, c) {
                  final large = c.maxWidth >= 600;
                  final compact = c.maxHeight < 560;
                  final contenu = Padding(
                    padding: EdgeInsets.fromLTRB(
                      Charte.marge,
                      compact ? 8 : 12,
                      Charte.marge,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Bienvenue(
                          nom: session.displayName,
                          message: switch (session.role) {
                            'enseignant' =>
                              'Heureux de vous retrouver. Gérez votre classe '
                                  'en toute simplicité.',
                            'delegue' =>
                              droits.isEmpty
                                  ? 'Le directeur ne vous a encore accordé '
                                        'aucun droit.'
                                  : 'Vos droits : ${_libelles(droits)}.',
                            _ =>
                              'Heureux de vous retrouver. Gérez votre '
                                  'établissement en toute simplicité.',
                          },
                          compact: compact,
                        ),
                        SizedBox(height: compact ? 6 : 10),
                        const _BarreEtat(),
                        if (enseignant) ...[
                          SizedBox(height: compact ? 6 : 8),
                          const MaJournee(compacte: true),
                        ],
                        SizedBox(height: compact ? 8 : 12),
                        Expanded(
                          child: _Grille(
                            tuiles: tuiles,
                            colonnes: large ? (c.maxWidth >= 900 ? 5 : 4) : 3,
                          ),
                        ),
                        _BasDePage(onDeconnexion: () => _logout(context, ref)),
                      ],
                    ),
                  );
                  // Tablette et ordinateur : contenu centré, jamais étiré.
                  return large
                      ? Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 880),
                            child: contenu,
                          ),
                        )
                      : contenu;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconeTheme(ThemeAccueil t) => switch (t.id) {
    'eleves' => Icons.groups_rounded,
    'classe' => Icons.class_rounded,
    'pedagogie' => Icons.auto_stories_rounded,
    'notes' => Icons.grading_rounded,
    'administration' => Icons.folder_copy_rounded,
    'finances' =>
      t.label == 'Finances'
          ? Icons.account_balance_wallet_rounded
          : Icons.restaurant_rounded,
    'rapports' => Icons.insert_chart_rounded,
    'bibliotheque' => Icons.local_library_rounded,
    'ia' => Icons.auto_awesome_rounded,
    'ecole' => Icons.account_balance_rounded,
    'compte' => Icons.person_rounded,
    _ => t.icone,
  };

  static String? _cheminLogo(WidgetRef ref, String? logo) {
    final media = ref.watch(mediaDirProvider);
    if (logo == null || media == null) return null;
    final f = File(p.join(media.path, logo));
    return f.existsSync() ? f.path : null;
  }

  static String _initiales(String nom) {
    final mots = nom
        .split(RegExp(r'\s+'))
        .where((m) => m.isNotEmpty && m[0].toUpperCase() != m[0].toLowerCase())
        .where((m) => !{'de', 'du', 'des', 'la', 'le', "l'"}.contains(m))
        .toList();
    if (mots.isEmpty) return 'É';
    return mots.take(2).map((m) => m[0].toUpperCase()).join();
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final pending = await ref.read(localStoreProvider).pendingCount();
    if (!context.mounted) return;
    final ok = await confirmer(
      context,
      titre: 'Se déconnecter ?',
      message: pending == 0
          ? 'Les données de l’école seront retirées de ce téléphone. Elles '
                'restent sur le serveur.'
          : 'Attention : $pending élément(s) ne sont pas encore envoyés. '
                'Si vous vous déconnectez maintenant, ils seront perdus. '
                'Connectez-vous à Internet et attendez « Tout est '
                'synchronisé » avant de vous déconnecter.',
      bouton: pending == 0 ? 'Se déconnecter' : 'Se déconnecter quand même',
    );
    if (ok) await ref.read(authServiceProvider).logout();
  }
}

/// Droits du délégué connecté (vide pour les autres profils).
final mesDroitsHomeProvider = Provider<Set<String>>((ref) {
  final s = ref.watch(sessionProvider).value;
  if (s == null || s.role != 'delegue') return const {};
  return ref.watch(permissionsProvider(s.membershipId)).value ?? const {};
});

String _libelles(Set<String> droits) =>
    droits.map((d) => droitsDelegables[d] ?? d).join(', ');

// ------------------------------ En-tête ------------------------------

class _EnTete extends StatelessWidget {
  const new({
    required this.ecole,
    required this.annee,
    required this.logo,
    required this.initiales,
    required this.utilisateur,
    required this.onDeconnexion,
  });
  final String ecole;
  final String? annee;
  final String? logo;
  final String initiales;
  final String utilisateur;
  final VoidCallback onDeconnexion;

  @override
  Widget build(BuildContext context) => Material(
    color: Charte.marine,
    child: SafeArea(
      bottom: false,
      child: SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.only(left: 14, right: 4),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 38,
                  height: 38,
                  color: Charte.blanc,
                  alignment: Alignment.center,
                  child: logo == null
                      ? Text(
                          initiales,
                          style: const TextStyle(
                            color: Charte.marine,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        )
                      : Image.file(
                          File(logo!),
                          key: const Key('logo-ecole'),
                          fit: BoxFit.contain,
                          cacheWidth: 120,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ecole,
                  key: const Key('titre-page'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Charte.blanc,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ),
              const IconTheme(
                data: IconThemeData(color: Charte.blanc),
                child: ClocheNotifications(),
              ),
              PopupMenuButton<String>(
                key: const Key('profil'),
                tooltip: 'Mon profil',
                position: PopupMenuPosition.under,
                onSelected: (v) async {
                  if (v == 'deconnexion') {
                    onDeconnexion();
                  } else {
                    await context.push(v);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(
                      utilisateur,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Charte.marineFonce,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: '/compte',
                    child: ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text('Mon compte'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: '/synchronisation',
                    child: ListTile(
                      leading: Icon(Icons.sync),
                      title: Text('Synchronisation'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'deconnexion',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Charte.rouge),
                      title: Text('Me déconnecter'),
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: Charte.orange,
                    child: Text(
                      utilisateur.isEmpty ? '?' : utilisateur[0].toUpperCase(),
                      style: const TextStyle(
                        color: Charte.blanc,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ------------------------------ Bienvenue ------------------------------

class _Bienvenue extends StatelessWidget {
  const new({required this.nom, required this.message, required this.compact});
  final String nom;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(16, compact ? 10 : 14, 12, compact ? 10 : 14),
    decoration: BoxDecoration(
      color: Charte.blanc,
      borderRadius: BorderRadius.circular(Charte.rayon),
      border: Border.all(color: Charte.bordure),
      boxShadow: Charte.ombre,
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bonjour, $nom !',
                key: const Key('bonjour'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 17 : 19,
                  fontWeight: FontWeight.w700,
                  color: Charte.marineFonce,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Charte.texteSecondaire,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Illustration discrète : un livre ouvert et une coiffe.
        SizedBox(
          width: compact ? 44 : 52,
          height: compact ? 44 : 52,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Charte.bleuClair,
                  shape: BoxShape.circle,
                ),
              ),
              Icon(
                Icons.menu_book_rounded,
                color: Charte.bleu,
                size: compact ? 24 : 28,
              ),
              Positioned(
                top: compact ? 4 : 6,
                right: compact ? 2 : 4,
                child: Icon(
                  Icons.school_rounded,
                  color: Charte.orange,
                  size: compact ? 16 : 19,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// --------------------- Synchronisation et alertes ---------------------

/// Synchronisation (pastille) et, s'il y en a, l'alerte la plus importante
/// (une seule ligne ; les autres sont dans les notifications).
class _BarreEtat extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertes = ref.watch(alertesAccueilProvider);
    // Un conseil (question secrète) en ambre ; une alerte en rouge.
    final conseil =
        alertes.isNotEmpty &&
        alertes.length == 1 &&
        alertes.first.route == '/compte/question';
    final (fg, bg) = conseil
        ? (Charte.ambre, Charte.ambrePale)
        : (Charte.rouge, Charte.rougePale);
    return SizedBox(
      height: 34,
      child: Row(
        children: [
          if (alertes.isEmpty)
            const SyncBanner(compact: true)
          else
            const Flexible(flex: 6, child: SyncBanner(compact: true)),
          if (alertes.isNotEmpty) ...[
            const SizedBox(width: 8),
            Flexible(
              flex: 5,
              child: Material(
                color: bg,
                shape: const StadiumBorder(),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () => context.push(
                    alertes.length == 1
                        ? alertes.single.route
                        : '/notifications',
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Icon(
                          alertes.first.icone,
                          size: 17,
                          color: Charte.rouge,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            alertes.first.court,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: fg,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (alertes.length > 1)
                          Text(
                            ' +${alertes.length - 1}',
                            style: TextStyle(
                              color: fg,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ] else
            const Spacer(),
        ],
      ),
    );
  }
}

/// Alertes de l'accueil : données non envoyées depuis longtemps, événements
/// de sécurité non lus (directeur), question secrète à choisir.
final Provider<
  List<({String titre, String court, String route, IconData icone})>
>
alertesAccueilProvider = Provider((ref) {
  final session = ref.watch(sessionProvider).value;
  if (session == null) return const [];
  final pending = ref.watch(pendingInfoProvider).value;
  final composition = ref.watch(periodeCompositionProvider).value ?? false;
  final journal = ref.watch(journalProvider).value ?? const [];
  final question = ref.watch(hasRecoveryQuestionProvider).value;
  final sync = pending == null
      ? null
      : alerteSynchronisation(
          enAttente: pending.$1,
          plusAncienneAttente: pending.$2,
          derniereSynchro: session.lastSyncAt == null
              ? null
              : DateTime.parse(session.lastSyncAt!),
          maintenant: DateTime.now().toUtc(),
          periodeComposition: composition,
        );
  final vu = session.journalSeenAt;
  final securite = session.role == 'directeur'
      ? journal.where((r) {
          if (vu != null && r.occurredAt.compareTo(vu) <= 0) return false;
          if (r.actorId == session.userId && r.action == 'connexion') {
            return false;
          }
          return decrireEvenement(
            action: r.action,
            table: r.affectedTable,
            detailsJson: r.details,
            acteur: '',
          ).securite;
        }).length
      : 0;
  return [
    if (sync != null)
      (
        titre: sync,
        court: 'Données non envoyées',
        route: '/synchronisation',
        icone: Icons.cloud_off,
      ),
    if (securite > 0)
      (
        titre: securite == 1
            ? '1 événement de sécurité à voir'
            : '$securite événements de sécurité à voir',
        court: securite == 1 ? '1 alerte de sécurité' : '$securite alertes',
        route: '/securite/journal',
        icone: Icons.shield_outlined,
      ),
    if (question == false)
      (
        titre:
            'Choisissez une question secrète : elle vous permettra de '
            'retrouver l’accès si vous oubliez votre mot de passe.',
        court: 'Question secrète',
        route: '/compte/question',
        icone: Icons.help_outline,
      ),
  ];
});

// ------------------------------ Grille ------------------------------

/// Grille des modules : la hauteur des tuiles est calculée pour que tout
/// tienne dans l'espace disponible (jamais de défilement).
class _Grille extends StatelessWidget {
  const new({required this.tuiles, required this.colonnes});
  final List<TuileAccueil> tuiles;
  final int colonnes;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      const ecart = 10.0;
      final rangees = (tuiles.length / colonnes).ceil();
      // Jamais plus haut que l'espace disponible (la tuile s'adapte).
      final hauteur = ((c.maxHeight - ecart * (rangees - 1)) / rangees).clamp(
        0.0,
        150.0,
      );
      return Column(
        children: [
          for (var r = 0; r < rangees; r++) ...[
            if (r > 0) const SizedBox(height: ecart),
            SizedBox(
              height: hauteur,
              child: Row(
                children: [
                  for (var k = 0; k < colonnes; k++) ...[
                    if (k > 0) const SizedBox(width: ecart),
                    Expanded(
                      child: r * colonnes + k < tuiles.length
                          ? _Tuile(tuiles[r * colonnes + k], hauteur: hauteur)
                          : const SizedBox(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    },
  );
}

class _Tuile extends StatelessWidget {
  const new(this.t, {required this.hauteur});
  final TuileAccueil t;
  final double hauteur;

  @override
  Widget build(BuildContext context) {
    final petit = hauteur < 92;
    // Place de l'icône = hauteur − marges − deux lignes de texte.
    final taille = (hauteur - (petit ? 8 : 16) - (petit ? 4 : 8) - 31 - 16)
        .clamp(18.0, 34.0);
    return Container(
      key: Key('theme-${t.id}'),
      decoration: BoxDecoration(
        color: Charte.blanc,
        borderRadius: BorderRadius.circular(Charte.rayon),
        border: Border.all(color: Charte.bordure),
        boxShadow: Charte.ombre,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(Charte.rayon),
          onTap: () => context.push(t.route),
          child: SizedBox.expand(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 6,
                vertical: petit ? 4 : 8,
              ),
              // Sur un écran très petit, le contenu se réduit au lieu de
              // déborder.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 104,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: taille + 16,
                        height: taille + 16,
                        decoration: BoxDecoration(
                          color: t.couleur.fond,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          t.icone,
                          color: t.couleur.couleur,
                          size: taille,
                        ),
                      ),
                      SizedBox(height: petit ? 4 : 8),
                      Text(
                        t.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: petit ? 12.5 : 13.5,
                          fontWeight: FontWeight.w600,
                          color: Charte.marineFonce,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------ Bas de page ------------------------------

class _BasDePage extends StatelessWidget {
  const new({required this.onDeconnexion});
  final VoidCallback onDeconnexion;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 46,
    child: Center(
      child: TextButton.icon(
        style: TextButton.styleFrom(foregroundColor: Charte.texteSecondaire),
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Se déconnecter'),
        onPressed: onDeconnexion,
      ),
    ),
  );
}
