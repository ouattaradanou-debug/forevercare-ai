import 'dart:convert';

/// Une ligne du journal d'activité telle qu'affichée au directeur.
class EvenementJournal {
  const new({required this.phrase, required this.securite});

  final String phrase;

  /// Événement de sécurité (signalé sur l'accueil du directeur).
  final bool securite;
}

const _objets = {
  'schools': 'les informations de l’école',
  'school_years': 'une année scolaire',
  'admin_headers': 'les en-têtes administratifs',
  'memberships': 'un compte',
  'delegate_permissions': 'les droits d’un délégué',
};

const _colonnes = {
  'name': 'nom',
  'phone': 'téléphone',
  'email': 'e-mail',
  'commune': 'commune',
  'province': 'province',
  'region': 'région',
  'departement': 'département',
  'address': 'adresse',
  'director_name': 'nom du directeur',
  'school_type': 'type d’école',
  'manages_primary': 'niveau primaire',
  'current_school_year_id': 'année en cours',
  'archived_at': 'archivage',
  'label': 'libellé',
  'ministry': 'ministère',
  'regional_direction': 'direction régionale',
  'provincial_direction': 'direction provinciale',
  'ceb': 'CEB',
  'school_label': 'nom sur les documents',
  'emblem_path': 'image d’en-tête',
  'motto': 'devise',
  'country': 'pays',
  'active': 'compte actif',
  'display_name': 'nom',
  'role': 'profil',
};

/// Traduit une ligne du journal en phrase simple.
EvenementJournal decrireEvenement({
  required String action,
  required String? table,
  required String? detailsJson,
  required String acteur,
}) {
  final d = detailsJson == null
      ? const <String, dynamic>{}
      : jsonDecode(detailsJson) as Map<String, dynamic>;
  switch (action) {
    case 'connexion':
      final nouveau = d['nouveau'] == true;
      return EvenementJournal(
        phrase:
            '$acteur s’est connecté sur « ${d['telephone']} »'
            '${nouveau ? ' (nouveau téléphone)' : ''}',
        securite: nouveau,
      );
    case 'deconnexion_telephone':
      return EvenementJournal(
        phrase: '$acteur a déconnecté le téléphone « ${d['telephone']} »',
        securite: true,
      );
    case 'recuperation_mot_de_passe':
      return EvenementJournal(
        phrase:
            '${d['personne'] ?? acteur} a changé son mot de passe grâce à sa '
            'question secrète',
        securite: true,
      );
    case 'creation_compte':
      return EvenementJournal(
        phrase: '$acteur a créé un compte',
        securite: true,
      );
    case 'reinitialisation_mot_de_passe':
      return EvenementJournal(
        phrase: '$acteur a donné un nouveau mot de passe à une personne',
        securite: true,
      );
    case 'creation_ecole':
      return EvenementJournal(
        phrase: '$acteur a créé l’école',
        securite: false,
      );
  }
  if (table == 'school_modules') {
    final valeurs = d['valeurs'] as Map<String, dynamic>? ?? const {};
    final on = valeurs['enabled'] == true;
    return EvenementJournal(
      phrase:
          '$acteur a ${on ? 'activé' : 'désactivé'} le module '
          '« ${d['module']} »',
      securite: false,
    );
  }
  final verbe = switch (action) {
    'creation' => 'a créé',
    'suppression' => 'a supprimé',
    _ => 'a modifié',
  };
  final colonnes = [
    for (final c in (d['colonnes'] as List<dynamic>? ?? const []))
      if (_colonnes[c] != null) _colonnes[c]!,
  ];
  final objet = _objets[table] ?? 'des données';
  final precision = action == 'modification' && colonnes.isNotEmpty
      ? ' (${colonnes.join(', ')})'
      : '';
  return EvenementJournal(
    phrase: '$acteur $verbe $objet$precision',
    securite: false,
  );
}
