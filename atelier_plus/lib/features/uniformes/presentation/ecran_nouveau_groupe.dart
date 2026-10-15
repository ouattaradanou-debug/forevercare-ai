import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/analyseur_date_vocale.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/gestion_erreurs.dart';
import '../../../core/widgets/en_tete_section.dart';
import '../../../data/models/commande_groupe.dart';
import '../../../data/models/groupe_uniforme.dart';
import '../../../data/models/photo_client.dart';
import '../../../shared/widgets/grille_photos.dart';
import '../../../shared/widgets/selecteur_source_image.dart';
import '../../auth/providers/auth_providers.dart';
import '../../clients/providers/photos_providers.dart';
import '../../finances/providers/finances_groupe_providers.dart';
import '../../rendezvous/providers/rendez_vous_groupe_providers.dart';
import '../providers/uniformes_providers.dart';

const _bleuSeda = Color(0xFF1B4FA0);
const _orangeSeda = Color(0xFFF5821F);

/// Création d'un groupe d'uniformes en un seul écran : informations du
/// groupe/répondant, puis photos de tissu et de modèle (hommes/femmes).
/// Même principe que EcranNouveauClient : le groupe est créé dès la
/// première action qui en a besoin (ajout d'une photo, ou bouton final),
/// à partir des informations déjà saisies — et les photos passent par le
/// même GrillePhotosSection partagé avec "Nouveau client", donc toute
/// évolution future de la gestion des photos côté client s'applique
/// automatiquement ici aussi.
class EcranNouveauGroupe extends ConsumerStatefulWidget {
  const EcranNouveauGroupe({super.key});

  @override
  ConsumerState<EcranNouveauGroupe> createState() => _EcranNouveauGroupeState();
}

class _EcranNouveauGroupeState extends ConsumerState<EcranNouveauGroupe> {
  final _nomCtrl = TextEditingController();
  final _repondantNomCtrl = TextEditingController();
  final _repondantTelCtrl = TextEditingController();
  final _montantTotalCtrl = TextEditingController();
  final _avanceCtrl = TextEditingController();
  final Map<String, bool> _photoEnCours = {};
  final _dicteeVocale = stt.SpeechToText();
  final _lectureVocale = FlutterTts();

  GroupeUniforme? _groupe;
  CommandeGroupe? _commandeCreee;
  bool _enregistrementGroupeEnCours = false;
  bool _enregistrementFinalEnCours = false;
  bool _dicteeDisponible = false;
  String? _champEnDictee;
  String _texteRendezVousEnCours = '';
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _lectureVocale.setLanguage('fr-FR');
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _repondantNomCtrl.dispose();
    _repondantTelCtrl.dispose();
    _montantTotalCtrl.dispose();
    _avanceCtrl.dispose();
    _dicteeVocale.stop();
    _lectureVocale.stop();
    super.dispose();
  }

  /// Démarre/arrête la dictée vocale pour [champ] — même principe que
  /// EcranNouveauClient._basculerDictee : un seul champ à la fois peut être
  /// en cours de dictée.
  Future<void> _basculerDictee(
    String champ,
    TextEditingController controleur, {
    bool chiffresSeulement = false,
  }) async {
    if (_champEnDictee == champ) {
      await _dicteeVocale.stop();
      if (mounted) setState(() => _champEnDictee = null);
      return;
    }

    if (_champEnDictee != null) {
      await _dicteeVocale.stop();
    }

    if (!await _initialiserDicteeSiBesoin()) return;

    setState(() => _champEnDictee = champ);
    await _dicteeVocale.listen(
      localeId: 'fr_FR',
      onResult: (resultat) {
        var texte = resultat.recognizedWords;
        if (chiffresSeulement) {
          texte = texte.replaceAll(RegExp(r'[^0-9]'), '');
        }
        controleur.text = texte;
        controleur.selection = TextSelection.collapsed(offset: controleur.text.length);
        // Nécessaire pour les champs Finances : "Reste à payer" lit
        // directement les contrôleurs dans build() — voir
        // EcranNouveauClient._basculerDictee pour la même remarque.
        if (mounted) setState(() {});
      },
    );
  }

  /// Initialise le moteur de dictée si besoin, avec le même callback de fin
  /// d'écoute partagé que EcranNouveauClient._initialiserDicteeSiBesoin :
  /// une dictée Montant/Avance déclenche l'enregistrement des finances, une
  /// dictée "rendez-vous" déclenche l'analyse de la date/heure dictée.
  Future<bool> _initialiserDicteeSiBesoin() async {
    if (_dicteeDisponible) return true;

    _dicteeDisponible = await _dicteeVocale.initialize(
      onStatus: (statut) {
        if ((statut == 'done' || statut == 'notListening') && mounted) {
          final champTermine = _champEnDictee;
          setState(() => _champEnDictee = null);
          if (champTermine == 'rendezvous') _traiterDicteeRendezVousGroupe();
          if (champTermine == 'montant' || champTermine == 'avance') _enregistrerFinancesGroupe();
        }
      },
      onError: (_) {
        if (mounted) setState(() => _champEnDictee = null);
      },
    );

    if (!_dicteeDisponible && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dictée vocale indisponible sur cet appareil.')),
      );
    }
    return _dicteeDisponible;
  }

  /// Dicter directement la date et l'heure du rendez-vous du groupe — même
  /// principe que EcranNouveauClient._dicterRendezVous.
  Future<void> _dicterRendezVous() async {
    if (_champEnDictee == 'rendezvous') {
      await _dicteeVocale.stop();
      return; // Le traitement est déclenché par le callback onStatus ci-dessus.
    }
    if (_champEnDictee != null) await _dicteeVocale.stop();

    if (!await _initialiserDicteeSiBesoin()) return;

    _texteRendezVousEnCours = '';
    setState(() => _champEnDictee = 'rendezvous');
    await _dicteeVocale.listen(
      localeId: 'fr_FR',
      onResult: (resultat) => _texteRendezVousEnCours = resultat.recognizedWords,
    );
  }

  Future<void> _traiterDicteeRendezVousGroupe() async {
    final texte = _texteRendezVousEnCours.trim();
    if (texte.isEmpty || !mounted) return;

    final resultat = AnalyseurDateVocale.analyser(texte);
    if (resultat == null) {
      const message = 'Je n\'ai pas compris la date. Essayez par exemple : dans 4 jours à '
          '15 heures, ou le 20 mars à 10 heures.';
      unawaited(_lectureVocale.speak(message));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Date non comprise (vous avez dit : "$texte"). $message')),
      );
      return;
    }

    final heureTxt = '${resultat.dateHeure.hour.toString().padLeft(2, '0')}h'
        '${resultat.dateHeure.minute.toString().padLeft(2, '0')}';
    final minute = resultat.dateHeure.minute;
    final phraseParlee = 'Rendez-vous le ${Formatters.dateLongue(resultat.dateHeure)} à '
        '${resultat.dateHeure.hour} heures${minute > 0 ? ' $minute' : ''}'
        '${resultat.heureDeduite ? '. Heure non précisée : neuf heures par défaut.' : '.'} '
        'Dites confirmer, ou appuyez de nouveau sur le micro pour recommencer.';
    unawaited(_lectureVocale.speak(phraseParlee));

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le rendez-vous ?'),
        content: Text(
          'Rendez-vous le ${Formatters.dateLongue(resultat.dateHeure)} à $heureTxt'
          '${resultat.heureDeduite ? ' (heure non précisée, 9h00 par défaut)' : ''}.\n\n'
          'Vous avez dit : "$texte"',
        ),
        actions: [
          TextButton(
            onPressed: () {
              _lectureVocale.stop();
              Navigator.of(context).pop(false);
            },
            child: const Text('Recommencer'),
          ),
          TextButton(
            onPressed: () {
              _lectureVocale.stop();
              Navigator.of(context).pop(true);
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    await _enregistrerRendezVousGroupe(resultat.dateHeure);
  }

  /// Calendrier puis horloge, enchaînés directement — même principe que
  /// EcranNouveauClient._ajouterRendezVous.
  Future<void> _ajouterRendezVousManuel() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final heure = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (heure == null || !mounted) return;

    final dateHeure = DateTime(date.year, date.month, date.day, heure.hour, heure.minute);
    await _enregistrerRendezVousGroupe(dateHeure);
  }

  /// Crée le groupe si besoin puis enregistre directement le rendez-vous —
  /// sur la table dédiée rendez_vous_groupe (voir RendezVousGroupeRepository),
  /// jamais sur `rendez_vous` (clients).
  Future<void> _enregistrerRendezVousGroupe(DateTime dateHeure) async {
    final groupe = await _assurerGroupeCree();
    if (groupe == null || !mounted) return;

    try {
      final utilisateur = await utilisateurCourantRequis(ref);
      await ref.read(rendezVousGroupeRepositoryProvider).creerRendezVous(
            atelierId: utilisateur.atelierId,
            groupeId: groupe.id,
            dateHeure: dateHeure,
            type: AppConstants.rdvEssayage,
            nomGroupePourRappel: groupe.nom,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rendez-vous enregistré.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'enregistrement du rendez-vous : $e')),
        );
      }
    }
  }

  /// Crée le groupe si ce n'est pas déjà fait, à partir des informations
  /// actuellement saisies. Retourne `null` (et affiche une erreur) si le
  /// nom n'est pas encore rempli — voir EcranNouveauClient._assurerClientCree.
  Future<GroupeUniforme?> _assurerGroupeCree() async {
    if (_groupe != null) return _groupe;

    final nom = _nomCtrl.text.trim();
    if (nom.isEmpty) {
      setState(() => _erreur = 'Renseignez le nom du groupe avant de continuer.');
      return null;
    }

    setState(() {
      _enregistrementGroupeEnCours = true;
      _erreur = null;
    });
    try {
      final utilisateur = await utilisateurCourantRequis(ref);
      final repondantNom = _repondantNomCtrl.text.trim();
      final repondantTel = _repondantTelCtrl.text.trim();
      final groupe = await ref.read(groupesUniformesRepositoryProvider).creerGroupe(
            atelierId: utilisateur.atelierId,
            nom: nom,
            repondantNom: repondantNom.isEmpty ? null : repondantNom,
            repondantTelephone: repondantTel.isEmpty ? null : repondantTel,
          );
      if (mounted) setState(() => _groupe = groupe);
      return groupe;
    } catch (e) {
      if (mounted) setState(() => _erreur = e.toString());
      return null;
    } finally {
      if (mounted) setState(() => _enregistrementGroupeEnCours = false);
    }
  }

  String _cleEnCours(TypePhoto type, String sexe) => '${type.name}_$sexe';

  Future<void> _ajouterPhoto(TypePhoto type, String sexe) async {
    final groupe = await _assurerGroupeCree();
    if (groupe == null || !mounted) return;

    final resultat = await choisirSourceEtImage(context);
    if (resultat == null || !mounted) return;
    final (fichier, sourceImage) = resultat;

    final utilisateur = await ref.read(utilisateurCourantProvider.future);
    if (utilisateur == null || !mounted) return;

    final cle = _cleEnCours(type, sexe);
    setState(() => _photoEnCours[cle] = true);
    try {
      await ref.read(photosRepositoryProvider).ajouterPhoto(
            atelierId: utilisateur.atelierId,
            groupeId: groupe.id,
            sexe: sexe,
            type: type,
            source: sourceImage == ImageSource.camera ? SourcePhoto.camera : SourcePhoto.galerie,
            fichier: fichier,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'envoi : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _photoEnCours[cle] = false);
    }
  }

  /// Termine la création : crée le groupe si besoin, synchronise une
  /// dernière fois le nom/répondant si modifiés après coup (ex. après
  /// l'avoir créé en ajoutant une photo avant de remplir le répondant),
  /// puis ouvre le détail du groupe.
  Future<void> _terminer() async {
    final groupe = await _assurerGroupeCree();
    if (groupe == null || !mounted) return;

    final nom = _nomCtrl.text.trim();
    final repondantNom = _repondantNomCtrl.text.trim();
    final repondantTel = _repondantTelCtrl.text.trim();
    final repondantNomActuel = repondantNom.isEmpty ? null : repondantNom;
    final repondantTelActuel = repondantTel.isEmpty ? null : repondantTel;

    if (nom != groupe.nom ||
        repondantNomActuel != groupe.repondantNom ||
        repondantTelActuel != groupe.repondantTelephone) {
      setState(() => _enregistrementFinalEnCours = true);
      await executerAvecErreurAffichee(
        context,
        () => ref.read(groupesUniformesRepositoryProvider).modifierGroupe(
              groupe: groupe,
              nom: nom,
              repondantNom: repondantNomActuel,
              repondantTelephone: repondantTelActuel,
            ),
      );
      if (mounted) setState(() => _enregistrementFinalEnCours = false);
    }
    if (!mounted) return;
    // Filet de sécurité : si le tailleur a saisi Montant/Avance puis
    // appuyé directement sur le bouton final sans valider le clavier
    // (onEditingComplete n'a alors jamais déclenché
    // _enregistrerFinancesGroupe), on s'assure ici que ces valeurs sont
    // bien enregistrées avant de quitter l'écran.
    await _enregistrerFinancesGroupe();
    if (!mounted) return;
    context.pushReplacement(AppRoutes.detailGroupeUniforme(groupe.id));
  }

  /// Crée le groupe si besoin (même principe que _ajouterPhoto) puis
  /// enregistre/corrige la commande du groupe à partir des champs Montant/
  /// Avance — même principe que EcranNouveauClient._enregistrerFinances :
  /// un groupe a une seule commande globale (voir FinancesGroupeRepository),
  /// donc les appels suivants corrigent cette même commande plutôt que
  /// d'en créer une nouvelle.
  Future<void> _enregistrerFinancesGroupe() async {
    final groupe = await _assurerGroupeCree();
    if (groupe == null || !mounted) return;

    final montantTotal = double.tryParse(_montantTotalCtrl.text.replaceAll(',', '.')) ?? 0;
    final avance = double.tryParse(_avanceCtrl.text.replaceAll(',', '.')) ?? 0;
    if (montantTotal <= 0 && avance <= 0) return;

    try {
      final utilisateur = await utilisateurCourantRequis(ref);
      final repo = ref.read(financesGroupeRepositoryProvider);
      final commande = _commandeCreee == null
          ? await repo.creerNouvelleCommande(
              atelierId: utilisateur.atelierId,
              groupeId: groupe.id,
              montantTotal: montantTotal,
              avance: avance,
            )
          : await repo.modifierCommande(
              atelierId: utilisateur.atelierId,
              commande: _commandeCreee!,
              montantTotal: montantTotal,
              avance: avance,
            );
      if (mounted) {
        setState(() => _commandeCreee = commande);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Finances enregistrées.')),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _erreur = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final photosGroupe = _groupe == null
        ? const <PhotoClient>[]
        : ref.watch(photosDuGroupeProvider(_groupe!.id)).valueOrNull ?? const [];
    List<PhotoClient> filtrerPhotos(TypePhoto type, String sexe) =>
        photosGroupe.where((p) => p.type == type && p.sexe == sexe).toList();

    final estProprietaire = ref.watch(estProprietaireProvider);
    final enCours = _enregistrementGroupeEnCours || _enregistrementFinalEnCours;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F1),
      appBar: AppBar(
        title: const Text('Nouveau groupe'),
        backgroundColor: _bleuSeda,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EnTeteSection(
                    icone: Icons.groups_outlined,
                    couleurFond: const Color(0xFFE3E1F5),
                    couleurIcone: const Color(0xFF3B3470),
                    titre: 'Informations du groupe',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nomCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Nom du groupe',
                      hintText: 'Ex. : Promotion 2026, Équipe commerciale...',
                      prefixIcon: IconButton(
                        icon: Icon(_champEnDictee == 'nom' ? Icons.mic : Icons.mic_none),
                        color: _champEnDictee == 'nom' ? Colors.red : _bleuSeda,
                        tooltip: 'Dicter le nom du groupe',
                        onPressed: () => _basculerDictee('nom', _nomCtrl),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _repondantNomCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nom du répondant (optionnel)',
                      prefixIcon: IconButton(
                        icon: Icon(_champEnDictee == 'repondantNom' ? Icons.mic : Icons.mic_none),
                        color: _champEnDictee == 'repondantNom' ? Colors.red : _bleuSeda,
                        tooltip: 'Dicter le nom du répondant',
                        onPressed: () => _basculerDictee('repondantNom', _repondantNomCtrl),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _repondantTelCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Téléphone du répondant (optionnel)',
                      prefixIcon: IconButton(
                        icon: Icon(_champEnDictee == 'repondantTel' ? Icons.mic : Icons.mic_none),
                        color: _champEnDictee == 'repondantTel' ? Colors.red : _bleuSeda,
                        tooltip: 'Dicter le téléphone du répondant',
                        onPressed: () => _basculerDictee(
                          'repondantTel',
                          _repondantTelCtrl,
                          chiffresSeulement: true,
                        ),
                      ),
                    ),
                  ),
                  if (_erreur != null) ...[
                    const SizedBox(height: 12),
                    Text(_erreur!, style: const TextStyle(color: Color(0xFFB3261E))),
                  ],
                  const SizedBox(height: 28),
                  EnTeteSection(
                    icone: Icons.texture_outlined,
                    couleurFond: const Color(0xFFF0E6C8),
                    couleurIcone: const Color(0xFFA47B1B),
                    titre: 'Photos du tissu',
                  ),
                  const SizedBox(height: 12),
                  LigneSexesPhotos(
                    photosHomme: filtrerPhotos(TypePhoto.tissu, 'Homme'),
                    photosFemme: filtrerPhotos(TypePhoto.tissu, 'Femme'),
                    enCoursHomme: _photoEnCours[_cleEnCours(TypePhoto.tissu, 'Homme')] ?? false,
                    enCoursFemme: _photoEnCours[_cleEnCours(TypePhoto.tissu, 'Femme')] ?? false,
                    onAjouterHomme: () => _ajouterPhoto(TypePhoto.tissu, 'Homme'),
                    onAjouterFemme: () => _ajouterPhoto(TypePhoto.tissu, 'Femme'),
                  ),
                  const SizedBox(height: 28),
                  EnTeteSection(
                    icone: Icons.checkroom_outlined,
                    couleurFond: const Color(0xFFDCEADF),
                    couleurIcone: const Color(0xFF2E7D32),
                    titre: 'Photos du ou des modèles',
                  ),
                  const SizedBox(height: 12),
                  LigneSexesPhotos(
                    photosHomme: filtrerPhotos(TypePhoto.modele, 'Homme'),
                    photosFemme: filtrerPhotos(TypePhoto.modele, 'Femme'),
                    enCoursHomme: _photoEnCours[_cleEnCours(TypePhoto.modele, 'Homme')] ?? false,
                    enCoursFemme: _photoEnCours[_cleEnCours(TypePhoto.modele, 'Femme')] ?? false,
                    onAjouterHomme: () => _ajouterPhoto(TypePhoto.modele, 'Homme'),
                    onAjouterFemme: () => _ajouterPhoto(TypePhoto.modele, 'Femme'),
                  ),
                  // Donnée financière : jamais montrée à un apprenti, même
                  // règle que dans le détail du groupe.
                  if (estProprietaire) ...[
                    const SizedBox(height: 28),
                    EnTeteSection(
                      icone: Icons.payments_outlined,
                      couleurFond: const Color(0xFFDCEADF),
                      couleurIcone: const Color(0xFF2E7D32),
                      titre: 'Finances',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _montantTotalCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Montant total convenu (FCFA)',
                        prefixIcon: IconButton(
                          icon: Icon(_champEnDictee == 'montant' ? Icons.mic : Icons.mic_none),
                          color: _champEnDictee == 'montant' ? Colors.red : _bleuSeda,
                          onPressed: () => _basculerDictee(
                            'montant',
                            _montantTotalCtrl,
                            chiffresSeulement: true,
                          ),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                      onEditingComplete: _enregistrerFinancesGroupe,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _avanceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Avance déjà payée par le répondant',
                        prefixIcon: IconButton(
                          icon: Icon(_champEnDictee == 'avance' ? Icons.mic : Icons.mic_none),
                          color: _champEnDictee == 'avance' ? Colors.red : _bleuSeda,
                          onPressed: () => _basculerDictee(
                            'avance',
                            _avanceCtrl,
                            chiffresSeulement: true,
                          ),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                      onEditingComplete: _enregistrerFinancesGroupe,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEAE4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Reste à payer'),
                          Text(
                            Formatters.montant(
                              (double.tryParse(_montantTotalCtrl.text.replaceAll(',', '.')) ??
                                      0) -
                                  (double.tryParse(_avanceCtrl.text.replaceAll(',', '.')) ?? 0),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  EnTeteSection(
                    icone: Icons.event_available_outlined,
                    couleurFond: const Color(0xFFF0E6C8),
                    couleurIcone: const Color(0xFFA47B1B),
                    titre: 'Rendez-vous',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _ajouterRendezVousManuel,
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter un rendez-vous'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            foregroundColor: _bleuSeda,
                            side: const BorderSide(color: _bleuSeda),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: _champEnDictee == 'rendezvous' ? Colors.red : _bleuSeda,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            _champEnDictee == 'rendezvous' ? Icons.mic : Icons.mic_none,
                            color: Colors.white,
                          ),
                          tooltip: 'Dicter la date et l\'heure du rendez-vous',
                          onPressed: _dicterRendezVous,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(
            color: Color(0xFFFAF6F1),
            boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, -2))],
          ),
          child: FilledButton(
            onPressed: enCours ? null : _terminer,
            style: FilledButton.styleFrom(
              backgroundColor: _orangeSeda,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            ),
            child: enCours
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Enregistrer le groupe'),
          ),
        ),
      ),
    );
  }
}
