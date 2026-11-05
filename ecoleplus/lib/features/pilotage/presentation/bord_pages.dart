import 'package:ecoleplus/app/providers.dart';
import 'package:ecoleplus/app/theme.dart';
import 'package:ecoleplus/core/db/app_database.dart';
import 'package:ecoleplus/core/widgets/common.dart';
import 'package:ecoleplus/features/bibliotheque/domain/document.dart';
import 'package:ecoleplus/features/cantine/domain/cantine.dart';
import 'package:ecoleplus/features/cantine/presentation/cantine_providers.dart';
import 'package:ecoleplus/features/classes/data/classes_repository.dart';
import 'package:ecoleplus/features/finances/domain/finances.dart';
import 'package:ecoleplus/features/finances/presentation/finances_providers.dart';
import 'package:ecoleplus/features/forms/presentation/forms_pages.dart';
import 'package:ecoleplus/features/grades/domain/calculs.dart';
import 'package:ecoleplus/features/home/presentation/home_page.dart';
import 'package:ecoleplus/features/pilotage/domain/absences.dart';
import 'package:ecoleplus/features/pilotage/domain/emploi_du_temps.dart';
import 'package:ecoleplus/features/pilotage/domain/notifications.dart';
import 'package:ecoleplus/features/pilotage/domain/rapports.dart';
import 'package:ecoleplus/features/pilotage/presentation/edt_pages.dart';
import 'package:ecoleplus/features/pilotage/presentation/pilotage_providers.dart';
import 'package:ecoleplus/features/school/presentation/school_providers.dart';
import 'package:ecoleplus/features/staff/presentation/staff_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Formulaires de l'année suivis au tableau de bord.
const formulairesSuivis = ['B1', 'B2', 'B3', 'B6', 'B7'];

/// Absences répétées : signalées à partir de ce nombre dans le mois.
const absencesRepetees = 3;

/// Les notifications de la personne connectée (calculées sur le
/// téléphone ; les modules désactivés n'en produisent aucune).
final Provider<List<NotificationEcole>> notificationsProvider = Provider((ref) {
  final s = ref.watch(sessionProvider).value;
  if (s == null) return const [];
  final ecole = ref.watch(schoolProvider(s.schoolId)).value;
  if (ecole == null) return const [];
  final yearId = ecole.currentSchoolYearId;
  if (yearId == null) return const [];
  final droits = ref.watch(mesDroitsProvider);
  final jour = ref.watch(aujourdhuiProvider);
  final out = <NotificationEcole>[
    // Alertes de l'accueil (synchronisation, sécurité, question secrète).
    for (final a in ref.watch(alertesAccueilProvider))
      NotificationEcole(
        id: 'alerte:${a.court}',
        titre: a.titre,
        route: a.route,
        icone: a.icone,
        importante: true,
      ),
  ];

  // Appel du jour : enseignant (ses classes) et directeur (toutes), les
  // jours de classe (lundi à vendredi, ou un jour prévu à l'emploi du temps).
  final appel = s.role == 'enseignant' || s.role == 'directeur';
  final classes = ref.watch(classesProvider(yearId)).value ?? const [];
  // Seulement le jour et les totaux du mois (rapide sur une grande école).
  final presences =
      ref.watch(presencesPeriodeProvider((s.schoolId, jour, jour))).value ??
      const <AttendanceRow>[];
  final totauxMois = ref
      .watch(
        totauxPresencesProvider((
          s.schoolId,
          '${jour.substring(0, 7)}-01',
          jour,
        )),
      )
      .value;
  final eff = ref.watch(effectifsProvider(yearId)).value ?? const {};
  final creneaux =
      ref.watch(creneauxEcoleProvider(s.schoolId)).value ?? const [];
  if (appel) {
    final j = jourDe(jour);
    for (final c in classes) {
      if ((eff[c.id]?.total ?? 0) == 0) continue;
      final classe =
          j <= 5 || creneaux.any((x) => x.classId == c.id && x.weekday == j);
      if (!classe) continue;
      if (presences.any((a) => a.classId == c.id && a.day == jour)) continue;
      out.add(
        NotificationEcole(
          id: 'appel:$jour:${c.id}',
          titre: 'Appel à faire : ${c.name}',
          detail: 'L’appel d’aujourd’hui n’est pas encore fait.',
          route: '/appel/${c.id}',
          icone: Icons.fact_check,
          importante: s.role == 'enseignant',
        ),
      );
    }
    final absents = presences
        .where((a) => a.day == jour && a.status == 'absent')
        .length;
    if (absents > 0) {
      out.add(
        NotificationEcole(
          id: 'absents:$jour:$absents',
          titre: absents == 1
              ? '1 élève absent aujourd’hui'
              : '$absents élèves absents aujourd’hui',
          route: '/absences',
          icone: Icons.event_busy,
        ),
      );
    }
    final mois = jour.substring(0, 7);
    final repetes = (totauxMois?.eleves.values ?? const <(int, int)>[])
        .where((x) => x.$1 >= absencesRepetees)
        .length;
    if (repetes > 0) {
      out.add(
        NotificationEcole(
          id: 'repetees:$mois:$repetes',
          titre: repetes == 1
              ? '1 élève absent $absencesRepetees fois ou plus ce mois-ci'
              : '$repetes élèves absents $absencesRepetees fois ou plus ce '
                    'mois-ci',
          route: '/absences',
          icone: Icons.warning_amber,
          importante: true,
        ),
      );
    }
  }

  // Paiements en retard (directeur, délégué « finances »).
  if (droits.contains('finances')) {
    final l = ref.watch(situationsHorsCantineProvider((s.schoolId, yearId)));
    final n = l?.where((x) => x.situation.enRetard > 0).length ?? 0;
    if (n > 0) {
      out.add(
        NotificationEcole(
          id: 'retards:$n',
          titre: n == 1
              ? '1 élève a un paiement en retard'
              : '$n élèves ont un paiement en retard',
          route: '/finances/impayes',
          icone: Icons.payments_outlined,
        ),
      );
    }
  }

  // Stock bas (cantine active seulement).
  if (ref.watch(cantineActiveProvider(s.schoolId)) &&
      (droits.contains('cantine') || droits.contains('finances'))) {
    final bas = [
      for (final e
          in ref.watch(stockProvider(s.schoolId)) ?? const <EtatProduit>[])
        if (e.alerte) e.produit.name,
    ];
    if (bas.isNotEmpty) {
      out.add(
        NotificationEcole(
          id: 'stock:${bas.join(',')}',
          titre: 'Stock bas : ${bas.join(', ')}',
          route: '/cantine/stock',
          icone: Icons.inventory,
          importante: true,
        ),
      );
    }
  }
  return out;
});

// --------------------------------- Cloche ---------------------------------

/// Cloche de l'accueil, avec le nombre de notifications non lues.
class ClocheNotifications extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(notificationsProvider);
    final lues = ref.watch(notificationsLuesProvider).value ?? const {};
    final n = l.where((x) => !lues.contains(x.id)).length;
    return IconButton(
      key: const Key('cloche'),
      tooltip: n == 0 ? 'Notifications' : '$n notification(s) non lue(s)',
      onPressed: () => context.push('/notifications'),
      icon: Badge(
        isLabelVisible: n > 0,
        label: Text('$n'),
        child: Icon(
          n > 0 ? Icons.notifications_active : Icons.notifications_none,
        ),
      ),
    );
  }
}

class NotificationsPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lues = ref.watch(notificationsLuesProvider).value ?? const {};
    final l = trierNotifications(ref.watch(notificationsProvider), lues);
    final nonLues = [
      for (final x in l)
        if (!lues.contains(x.id)) x.id,
    ];
    return EcoleScaffold(
      title: 'Notifications',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Les notifications sont calculées dans l’application, à partir '
            'des données de l’école. Rien n’arrive quand l’application est '
            'fermée.',
          ),
          const SizedBox(height: 8),
          if (nonLues.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.done_all),
                label: const Text('Tout marquer comme lu'),
                onPressed: () => ref
                    .read(notificationsLuesProvider.notifier)
                    .marquer(nonLues),
              ),
            ),
          if (l.isEmpty)
            const InfoMessage(
              'Aucune notification. Tout est en ordre.',
              icon: Icons.notifications_none,
            ),
          for (final x in l)
            Card(
              color: lues.contains(x.id)
                  ? null
                  : Theme.of(context).colorScheme.secondaryContainer,
              child: ListTile(
                key: Key('notification-${x.id}'),
                leading: Icon(x.icone),
                title: Text(
                  x.titre,
                  style: lues.contains(x.id)
                      ? null
                      : const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: x.detail == null ? null : Text(x.detail!),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await ref.read(notificationsLuesProvider.notifier).marquer([
                    x.id,
                  ]);
                  if (context.mounted) await context.push(x.route);
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ------------------------------ Tableau de bord ------------------------------

/// Une carte du tableau de bord : titre, chiffres, écran détaillé.
class _Carte extends StatelessWidget {
  const new({
    required this.titre,
    required this.icone,
    required this.lignes,
    this.route,
    this.cle,
    this.alerte = false,
  });
  final String titre;
  final IconData icone;
  final List<Widget> lignes;
  final String? route;
  final String? cle;
  final bool alerte;

  @override
  Widget build(BuildContext context) => Card(
    key: cle == null ? null : Key('bord-$cle'),
    color: alerte ? Theme.of(context).colorScheme.errorContainer : null,
    child: InkWell(
      onTap: route == null ? null : () => context.push(route!),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titre,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (route != null) const Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: 6),
            ...lignes,
          ],
        ),
      ),
    ),
  );
}

Widget _gros(BuildContext context, String texte, {Key? key}) => Text(
  texte,
  key: key,
  style: Theme.of(context).textTheme.headlineSmall
      ?.copyWith(fontWeight: FontWeight.bold),
);

/// Tableau de bord : directeur (toute l'école) ou enseignant (sa classe).
class TableauDeBordPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sessionProvider).value;
    final ctx = contexteEcole(ref);
    if (s == null || ctx == null) {
      return const EcoleScaffold(
        title: 'Tableau de bord',
        body: LinearProgressIndicator(),
      );
    }
    final (ecole, annee) = ctx;
    final enseignant = s.role == 'enseignant';
    final droits = ref.watch(mesDroitsProvider);
    final jour = ref.watch(aujourdhuiProvider);
    final classes = ref.watch(classesProvider(annee.id)).value ?? const [];
    final eff = ref.watch(effectifsProvider(annee.id)).value ?? const {};
    final total = classes.fold(
      const Effectif(),
      (x, c) => x + (eff[c.id] ?? const Effectif()),
    );
    final duJour =
        ref.watch(presencesPeriodeProvider((ecole.id, jour, jour))).value ??
        const <AttendanceRow>[];
    final appels = {for (final a in duJour) a.classId};
    final absents = duJour.where((a) => a.status == 'absent').length;
    final (du, au) = Periode.mois.bornes(jour);
    final mois =
        (ref.watch(totauxPresencesProvider((ecole.id, du, au))).value ??
                const TotauxPresences({}, {}))
            .parClasse([
              for (final c in classes) (c.id, c.name, eff[c.id]?.total ?? 0),
            ]);
    final presentsMois = mois.fold(0, (x, c) => x + c.presences + c.retards);
    final appelesMois = presentsMois + mois.fold(0, (x, c) => x + c.absences);
    final tauxMois = appelesMois == 0 ? null : presentsMois * 100 / appelesMois;
    final resultats = ecole.managesPrimary
        ? ref.watch(resultatsEcoleProvider((annee.id, null, null))).value
        : null;
    final notifs = trierNotifications(
      ref.watch(notificationsProvider),
      ref.watch(notificationsLuesProvider).value ?? const {},
    );
    final cantine = ref.watch(cantineActiveProvider(ecole.id));
    final creneaux =
        ref.watch(creneauxEcoleProvider(ecole.id)).value ?? const [];
    final matieres =
        ref.watch(nomsMatieresProvider(ecole.id)).value ?? const {};
    final cartes = <Widget>[
      // Effectifs.
      _Carte(
        cle: 'effectifs',
        titre: enseignant ? 'Ma classe' : 'Effectifs',
        icone: Icons.groups,
        route: '/classes',
        lignes: [
          _gros(context, '${total.total} élèves', key: const Key('bord-total')),
          Text(
            '${total.filles} filles • ${total.garcons} garçons'
            '${total.autres > 0 ? ' • ${total.autres} non précisé(s)' : ''}',
            key: const Key('bord-fg'),
          ),
          Text('${classes.length} classe(s)'),
          if (!enseignant && classes.length > 1) ...[
            const SizedBox(height: 4),
            for (final c in classes)
              Text(
                '${c.name} : ${eff[c.id]?.total ?? 0} '
                '(F ${eff[c.id]?.filles ?? 0}, G ${eff[c.id]?.garcons ?? 0})',
              ),
          ],
        ],
      ),
      if (!enseignant && droits.contains('registres'))
        _Carte(
          cle: 'enseignants',
          titre: 'Enseignants',
          icone: Icons.badge,
          route: '/enseignants',
          lignes: [
            _gros(
              context,
              '${ref.watch(teachersProvider(ecole.id)).value?.length ?? 0}',
            ),
            Text(
              '${classes.where((c) => c.mainTeacherId == null).length} '
              'classe(s) sans enseignant titulaire',
            ),
          ],
        ),
      if (enseignant)
        _Carte(
          cle: 'journee',
          titre: 'Aujourd’hui',
          icone: Icons.today,
          route: '/emploi-du-temps',
          lignes: [
            Text(jourTexte(jour)),
            for (final c in classes)
              for (final x in creneaux.where(
                (x) => x.classId == c.id && x.weekday == jourDe(jour),
              ))
                Text('${plage(x)}  ${intitule(x, matieres)}'),
            if (!creneaux.any((x) => x.weekday == jourDe(jour)))
              const Text('Pas de cours prévu à l’emploi du temps.'),
          ],
        ),
      // Absences.
      _Carte(
        cle: 'absences',
        titre: 'Absences',
        icone: Icons.event_busy,
        route: '/absences',
        alerte: classes.length > appels.length && jourDe(jour) <= 5,
        lignes: [
          _gros(
            context,
            '$absents absent(s) aujourd’hui',
            key: const Key('bord-absents'),
          ),
          Text(
            'Appel fait : ${appels.length} classe(s) sur ${classes.length}',
            key: const Key('bord-appels'),
          ),
          Text('Présence ce mois-ci : ${pourcent(tauxMois)}'),
          if (enseignant)
            for (final c in classes)
              if (!appels.contains(c.id))
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: FilledButton.icon(
                    icon: const Icon(Icons.fact_check),
                    label: Text('Faire l’appel — ${c.name}'),
                    onPressed: () => context.push('/appel/${c.id}'),
                  ),
                ),
        ],
      ),
      // Résultats.
      if (ecole.managesPrimary)
        _Carte(
          cle: 'resultats',
          titre: 'Résultats',
          icone: Icons.grading,
          route: enseignant ? '/notes' : '/rapports',
          lignes: [
            if (resultats == null)
              const LinearProgressIndicator()
            else if (resultats.isEmpty)
              const Text('Pas encore de notes ce trimestre.')
            else
              for (final r in resultats) Text(_ligneResultat(r)),
          ],
        ),
      // Finances.
      if (droits.contains('finances')) _CarteFinances(ecole.id, annee.id),
      // Formulaires.
      if (!enseignant && droits.contains('registres'))
        _CarteFormulaires(annee.id, primaire: ecole.managesPrimary),
      // Stockage.
      if (!enseignant) _CarteStockage(ecole),
      // Cantine (module actif seulement).
      if (cantine &&
          (droits.contains('cantine') || droits.contains('finances')))
        _CarteCantine(ecole.id, jour),
      // Alertes.
      _Carte(
        cle: 'alertes',
        titre: 'Alertes',
        icone: Icons.notifications_outlined,
        route: '/notifications',
        lignes: [
          if (notifs.isEmpty) const Text('Aucune alerte. Tout est en ordre.'),
          for (final n in notifs.take(5)) Text('• ${n.titre}'),
          if (notifs.length > 5) Text('… et ${notifs.length - 5} autre(s)'),
        ],
      ),
    ];
    return EcoleScaffold(
      title: enseignant ? 'Mon tableau de bord' : 'Tableau de bord',
      body: LayoutBuilder(
        builder: (context, c) {
          final colonnes = c.maxWidth >= 900 ? 3 : (c.maxWidth >= 600 ? 2 : 1);
          if (colonnes == 1) {
            return ListView(
              padding: const EdgeInsets.all(12),
              children: cartes,
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              children: [
                for (final x in cartes)
                  SizedBox(width: (c.maxWidth - 24) / colonnes, child: x),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CarteFinances extends ConsumerWidget {
  const new(this.schoolId, this.yearId);
  final String schoolId;
  final String yearId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(situationsHorsCantineProvider((schoolId, yearId)));
    final s = l == null
        ? null
        : Synthese.depuis([for (final x in l) x.situation]);
    final retard = l?.where((x) => x.situation.enRetard > 0).length ?? 0;
    return _Carte(
      cle: 'finances',
      titre: 'Finances (hors cantine)',
      icone: Icons.payments_outlined,
      route: '/finances',
      lignes: s == null
          ? [const LinearProgressIndicator()]
          : [
              _gros(context, '${fcfa(s.encaisse)} FCFA encaissés'),
              Text('Reste à payer : ${fcfa(s.restant)} FCFA'),
              Text('Recouvrement : ${texteTaux(s.taux)}'),
              Text(
                '$retard élève(s) en retard de paiement • ${s.nbImpayes} '
                'avec un reste à payer',
              ),
            ],
    );
  }
}

class _CarteFormulaires extends ConsumerWidget {
  const new(this.yearId, {required this.primaire});
  final String yearId;
  final bool primaire;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codes = [
      for (final c in formulairesSuivis)
        if (c != 'B2' || primaire) c,
    ];
    final etatsF = {
      for (final c in codes)
        c: ref.watch(formulaireProvider((yearId, c))).value,
    };
    final finis = etatsF.values
        .where(
          (f) =>
              f?.status == 'complet' ||
              f?.status == 'imprime' ||
              f?.status == 'signe_archive',
        )
        .length;
    return _Carte(
      cle: 'formulaires',
      titre: 'Mes formulaires de l’année',
      icone: Icons.checklist,
      route: '/formulaires',
      lignes: [
        _gros(context, '$finis sur ${codes.length} complets'),
        for (final MapEntry(key: c, value: f) in etatsF.entries)
          Text('$c : ${etats[f?.status ?? 'a_completer']}'),
      ],
    );
  }
}

class _CarteStockage extends ConsumerWidget {
  const new(this.ecole);
  final SchoolRow ecole;

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder(
    future: ref.read(bibliothequeRepositoryProvider).espaceCatalogue(ecole.id),
    builder: (context, snap) {
      final utilise = snap.data;
      final quota = ecole.storageQuotaBytes;
      final p = utilise == null || quota == 0 ? null : utilise * 100 / quota;
      return _Carte(
        cle: 'stockage',
        titre: 'Espace de stockage',
        icone: Icons.cloud_outlined,
        route: '/bibliotheque',
        alerte: (p ?? 0) >= 90,
        lignes: [
          _gros(context, '${pourcent(p)} utilisé'),
          if (utilise != null)
            Text('${tailleTexte(utilise)} sur ${tailleTexte(quota)}'),
          if (utilise != null) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(value: ((p ?? 0) / 100).clamp(0, 1)),
          ],
        ],
      );
    },
  );
}

class _CarteCantine extends ConsumerWidget {
  const new(this.schoolId, this.jour);
  final String schoolId;
  final String jour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repas = (ref.watch(pointagesProvider(schoolId)).value ?? const [])
        .where((p) => p.day == jour)
        .fold(0, (s, p) => s + p.mealsCount);
    final bas = [
      for (final e
          in ref.watch(stockProvider(schoolId)) ?? const <EtatProduit>[])
        if (e.alerte) e.produit.name,
    ];
    return _Carte(
      cle: 'cantine',
      titre: 'Cantine scolaire',
      icone: Icons.restaurant,
      route: '/cantine',
      alerte: bas.isNotEmpty,
      lignes: [
        _gros(context, '$repas repas aujourd’hui'),
        Text(
          bas.isEmpty ? 'Stock : rien de bas' : 'Stock bas : ${bas.join(', ')}',
        ),
      ],
    );
  }
}

String _ligneResultat(ResultatsClasse r) {
  final m = centiemesTexte(r.classement.statistiques.moyenneClasse);
  return '${r.classe} : moyenne $m • réussite ${pourcent(r.taux)}';
}

/// « Ma journée » (accueil de l'enseignant) : cours du jour d'après
/// l'emploi du temps, appel à faire ou fait.
class MaJournee extends ConsumerWidget {
  const new({this.compacte = false, super.key});

  /// Une seule bande (accueil sans défilement) : prochain cours et appel.
  final bool compacte;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctx = contexteEcole(ref);
    if (ctx == null) return const SizedBox.shrink();
    final (ecole, annee) = ctx;
    final jour = ref.watch(aujourdhuiProvider);
    final classes = ref.watch(classesProvider(annee.id)).value ?? const [];
    final creneaux =
        ref.watch(creneauxEcoleProvider(ecole.id)).value ?? const [];
    final matieres =
        ref.watch(nomsMatieresProvider(ecole.id)).value ?? const {};
    final presences =
        ref.watch(presencesPeriodeProvider((ecole.id, jour, jour))).value ??
        const <AttendanceRow>[];
    final duJour = [
      for (final x in creneaux)
        if (x.weekday == jourDe(jour) && classes.any((c) => c.id == x.classId))
          x,
    ];
    if (compacte) {
      final aFaire = [
        for (final c in classes)
          if (!presences.any((a) => a.classId == c.id && a.day == jour)) c,
      ];
      final fait = [
        for (final c in classes)
          if (presences.any((a) => a.classId == c.id && a.day == jour)) c,
      ];
      return Container(
        key: const Key('ma-journee'),
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        decoration: BoxDecoration(
          color: Charte.blanc,
          borderRadius: BorderRadius.circular(Charte.rayon),
          border: Border.all(color: Charte.bordure),
        ),
        child: Row(
          children: [
            const Icon(Icons.today_rounded, color: Charte.turquoise),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ma journée',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    duJour.isEmpty
                        ? 'Pas de cours prévu à l’emploi du temps.'
                        : duJour
                              .map(
                                (x) =>
                                    '${heureCourte(x.startsAt)} '
                                    '${intitule(x, matieres)}',
                              )
                              .join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  for (final c in fait.take(1))
                    Text(
                      'Appel fait (${c.name}) : '
                      '${_absents(presences, c.id, jour)} absent(s).',
                      key: Key('appel-fait-${c.id}'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Charte.vert,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            // Un seul bouton : la classe, ou le choix des classes.
            for (final c in aFaire.take(1))
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: FilledButton(
                  key: Key(
                    aFaire.length > 1 ? 'faire-appel' : 'faire-appel-${c.id}',
                  ),
                  style: StylesBoutons.accent.copyWith(
                    minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 12),
                    ),
                    textStyle: const WidgetStatePropertyAll(
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  child: const Text('Faire l’appel'),
                  onPressed: () => context.push(
                    aFaire.length > 1 ? '/appel' : '/appel/${c.id}',
                  ),
                ),
              ),
          ],
        ),
      );
    }
    return Card(
      key: const Key('ma-journee'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ma journée', style: Theme.of(context).textTheme.titleLarge),
            Text(jourTexte(jour)),
            const SizedBox(height: 8),
            if (duJour.isEmpty)
              const Text('Pas de cours prévu à l’emploi du temps.')
            else
              for (final x in duJour)
                Text('${plage(x)}  ${intitule(x, matieres)}'),
            const SizedBox(height: 8),
            for (final c in classes)
              if (presences.any((a) => a.classId == c.id && a.day == jour))
                Text(
                  'Appel fait (${c.name}) : '
                  '${_absents(presences, c.id, jour)} absent(s).',
                  key: Key('appel-fait-${c.id}'),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: FilledButton.icon(
                    key: Key('faire-appel-${c.id}'),
                    icon: const Icon(Icons.fact_check),
                    label: Text('Faire l’appel — ${c.name}'),
                    onPressed: () => context.push('/appel/${c.id}'),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

int _absents(List<AttendanceRow> l, String classId, String jour) => l
    .where((a) => a.classId == classId && a.day == jour && a.status == 'absent')
    .length;
