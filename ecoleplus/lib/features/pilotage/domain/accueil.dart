import 'package:flutter/material.dart';

/// Une entrée d'un thème de l'accueil (écran ouvert par la route).
class EntreeAccueil {
  const new(this.label, this.route, this.icone, {this.sousTitre});
  final String label;
  final String route;
  final IconData icone;
  final String? sousTitre;
}

/// Un gros bouton de l'accueil : un thème et ses entrées. Un thème d'une
/// seule entrée ouvre directement son écran.
class ThemeAccueil {
  const new(this.id, this.label, this.icone, this.entrees);
  final String id;
  final String label;
  final IconData icone;
  final List<EntreeAccueil> entrees;

  /// Écran ouvert par le gros bouton.
  String get route => entrees.length == 1 ? entrees.single.route : '/theme/$id';
}

/// Ce que la personne peut voir, pour construire l'accueil.
class ProfilAccueil {
  const new({
    required this.role,
    required this.droits,
    this.primaire = true,
    this.maternelle = false,
    this.cantine = false,
  });

  /// directeur, enseignant, delegue.
  final String role;
  final Set<String> droits;
  final bool primaire;

  /// Modules optionnels actifs (R11 : un module désactivé n'apparaît pas).
  final bool maternelle;
  final bool cantine;

  bool get directeur => role == 'directeur';
  bool get enseignant => role == 'enseignant';
}

/// Les thèmes de l'accueil (8 gros boutons au plus), dans l'ordre choisi :
/// directeur et délégués « par thèmes », enseignant « Ma classe d'abord ».
/// Les thèmes vides (pas de droit) ne sont pas affichés.
List<ThemeAccueil> themesAccueil(ProfilAccueil p) {
  final d = p.droits;
  final notes = p.primaire ? 'Notes et classement' : 'Évaluations (maternelle)';
  final themes = p.enseignant
      ? [
          const ThemeAccueil('classe', 'Ma classe', Icons.class_, [
            EntreeAccueil('Mes élèves', '/eleves', Icons.school),
            EntreeAccueil('Faire l’appel', '/appel', Icons.fact_check),
            EntreeAccueil(
              'Emploi du temps',
              '/emploi-du-temps',
              Icons.calendar_view_week,
            ),
            EntreeAccueil('Absences', '/absences', Icons.event_busy),
            EntreeAccueil('Ma classe (fiche)', '/classes', Icons.class_),
          ]),
          ThemeAccueil(
            'notes',
            p.primaire ? 'Notes et bulletins' : notes,
            Icons.grading,
            [EntreeAccueil(notes, '/notes', Icons.grading)],
          ),
          const ThemeAccueil(
            'ia',
            'Assistant IA et mes fiches',
            Icons.auto_awesome,
            [EntreeAccueil('Assistant IA', '/assistant', Icons.auto_awesome)],
          ),
          const ThemeAccueil(
            'bibliotheque',
            'Bibliothèque',
            Icons.local_library_outlined,
            [
              EntreeAccueil(
                'Bibliothèque',
                '/bibliotheque',
                Icons.local_library_outlined,
              ),
            ],
          ),
          const ThemeAccueil('compte', 'Mon compte', Icons.person, [
            EntreeAccueil('Mon compte', '/compte', Icons.person),
          ]),
        ]
      : [
          ThemeAccueil('eleves', 'Élèves et classes', Icons.school, [
            if (d.contains('eleves') || d.contains('registres')) ...[
              const EntreeAccueil('Élèves', '/eleves', Icons.school),
              const EntreeAccueil('Classes', '/classes', Icons.class_),
              const EntreeAccueil('Absences', '/absences', Icons.event_busy),
            ],
            if (p.directeur)
              const EntreeAccueil(
                'Faire l’appel',
                '/appel',
                Icons.fact_check,
                sousTitre: 'Corriger l’appel d’une classe',
              ),
            if (d.contains('cartes'))
              const EntreeAccueil('Cartes scolaires', '/cartes', Icons.badge),
            if (d.contains('registres'))
              const EntreeAccueil(
                'Enseignants',
                '/enseignants',
                Icons.co_present,
              ),
          ]),
          ThemeAccueil('pedagogie', 'Pédagogie', Icons.grading, [
            if (d.contains('registres') || d.contains('formulaires')) ...[
              EntreeAccueil(notes, '/notes', Icons.grading),
              const EntreeAccueil(
                'Bulletins',
                '/notes',
                Icons.description_outlined,
                sousTitre: 'Par classe, dans les notes',
              ),
            ],
            const EntreeAccueil(
              'Emploi du temps',
              '/emploi-du-temps',
              Icons.calendar_view_week,
            ),
            if (p.maternelle && p.directeur)
              const EntreeAccueil(
                'Maternelle',
                '/maternelle/reglages',
                Icons.child_care,
                sousTitre: 'Domaines et niveaux',
              ),
          ]),
          ThemeAccueil(
            'administration',
            'Administration',
            Icons.folder_copy_outlined,
            [
              if (d.contains('registres') ||
                  d.contains('formulaires') ||
                  d.contains('cartes'))
                const EntreeAccueil(
                  'Formulaires officiels',
                  '/documents',
                  Icons.folder_copy_outlined,
                ),
              if (d.contains('registres'))
                const EntreeAccueil(
                  'Registres',
                  '/formulaires',
                  Icons.checklist,
                  sousTitre: 'Où en est chaque formulaire de l’année',
                ),
              if (d.contains('archives'))
                const EntreeAccueil(
                  'Archives',
                  '/archives',
                  Icons.inventory_2_outlined,
                ),
            ],
          ),
          ThemeAccueil(
            'finances',
            d.contains('finances') ? 'Finances' : 'Cantine scolaire',
            d.contains('finances') ? Icons.payments_outlined : Icons.restaurant,
            [
              if (d.contains('finances')) ...[
                const EntreeAccueil(
                  'Encaisser',
                  '/finances/encaisser',
                  Icons.point_of_sale,
                ),
                const EntreeAccueil('Reçus', '/finances/recus', Icons.receipt),
                const EntreeAccueil(
                  'Caisse',
                  '/finances/caisse',
                  Icons.account_balance_wallet,
                ),
                const EntreeAccueil(
                  'Toutes les finances',
                  '/finances',
                  Icons.payments_outlined,
                  sousTitre: 'Grille, situations, impayés, dépenses, rapports',
                ),
              ],
              if (p.cantine &&
                  (d.contains('cantine') || d.contains('finances')))
                const EntreeAccueil(
                  'Cantine scolaire',
                  '/cantine',
                  Icons.restaurant,
                ),
            ],
          ),
          if (p.directeur)
            const ThemeAccueil('rapports', 'Rapports', Icons.summarize, [
              EntreeAccueil('Rapports', '/rapports', Icons.summarize),
            ]),
          ThemeAccueil(
            'bibliotheque',
            'Bibliothèque et IA',
            Icons.local_library_outlined,
            [
              const EntreeAccueil(
                'Bibliothèque',
                '/bibliotheque',
                Icons.local_library_outlined,
              ),
              if (p.directeur)
                const EntreeAccueil(
                  'Assistant IA',
                  '/assistant',
                  Icons.auto_awesome,
                ),
            ],
          ),
          if (p.directeur)
            const ThemeAccueil('ecole', 'Mon école', Icons.account_balance, [
              EntreeAccueil('Mon école', '/ecole', Icons.account_balance),
            ])
          else
            const ThemeAccueil('compte', 'Mon compte', Icons.person, [
              EntreeAccueil('Mon compte', '/compte', Icons.person),
            ]),
        ];
  return [
    for (final t in themes)
      if (t.entrees.isNotEmpty) t,
  ];
}
