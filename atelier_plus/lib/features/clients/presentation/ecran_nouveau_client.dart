import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/client.dart';
import '../../../data/models/photo_client.dart';
import '../../../shared/widgets/selecteur_source_image.dart';
import '../../auth/providers/auth_providers.dart';
import '../../finances/providers/finances_providers.dart';
import '../../mesures/providers/gabarits_providers.dart';
import '../../mesures/providers/mesures_providers.dart';
import '../../../data/models/type_tenue.dart';
import '../providers/clients_providers.dart';
import '../providers/photos_providers.dart';

/// Création d'un client en un seul écran : informations, mesures, photos,
/// finances et rendez-vous — chaque section s'enregistre dès que possible
/// plutôt que d'exiger un unique gros formulaire validé d'un coup. Le
/// client lui-même est créé dès que son nom/prénom/téléphone/sexe sont
/// renseignés (déclenché par la première action qui en a besoin : ajouter
/// une photo, enregistrer des mesures/finances, ou le bouton final).
class EcranNouveauClient extends ConsumerStatefulWidget {
  const EcranNouveauClient({super.key});

  @override
  ConsumerState<EcranNouveauClient> createState() => _EcranNouveauClientState();
}

class _EcranNouveauClientState extends ConsumerState<EcranNouveauClient> {
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  DateTime? _datePriseMesures;
  String? _sexe;

  final _montantTotalCtrl = TextEditingController();
  final _avanceCtrl = TextEditingController();

  final Map<String, TextEditingController> _controleursMesure = {};

  Client? _client;
  bool _enregistrementClientEnCours = false;
  bool _mesuresEnregistrees = false;
  bool _financesEnregistrees = false;
  bool _photoEnCours = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      if (utilisateur != null) {
        await ref.read(gabaritsRepositoryProvider).chargerDepuisServeur(utilisateur.atelierId);
      }
    });
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _telephoneCtrl.dispose();
    _montantTotalCtrl.dispose();
    _avanceCtrl.dispose();
    for (final c in _controleursMesure.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controleurMesure(String champId) {
    return _controleursMesure.putIfAbsent(champId, () => TextEditingController());
  }

  Future<void> _choisirDate() async {
    final choisie = await showDatePicker(
      context: context,
      initialDate: _datePriseMesures ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (choisie != null) setState(() => _datePriseMesures = choisie);
  }

  /// Crée le client si ce n'est pas déjà fait, à partir des informations
  /// actuellement saisies. Retourne `null` (et affiche une erreur) si les
  /// champs obligatoires ne sont pas encore remplis.
  Future<Client?> _assurerClientCree() async {
    if (_client != null) return _client;

    final nom = _nomCtrl.text.trim();
    final prenom = _prenomCtrl.text.trim();
    final telephone = _telephoneCtrl.text.trim();
    if (nom.isEmpty || prenom.isEmpty || telephone.isEmpty || _sexe == null) {
      setState(() {
        _erreur = 'Renseignez le nom, le prénom, le téléphone et le sexe avant de continuer.';
      });
      return null;
    }

    setState(() {
      _enregistrementClientEnCours = true;
      _erreur = null;
    });
    try {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      final client = await ref.read(clientsRepositoryProvider).creerClient(
            atelierId: utilisateur!.atelierId,
            nom: nom,
            prenom: prenom,
            telephone: telephone,
            sexe: _sexe!,
            datePriseMesures: _datePriseMesures ?? DateTime.now(),
          );
      if (mounted) setState(() => _client = client);
      return client;
    } catch (e) {
      if (mounted) setState(() => _erreur = e.toString());
      return null;
    } finally {
      if (mounted) setState(() => _enregistrementClientEnCours = false);
    }
  }

  /// Id du gabarit par défaut (fourni par l'application) pour ce sexe —
  /// les mesures du client ne passent jamais par le choix d'un type de
  /// tenue, contrairement aux groupes d'uniformes : une seule liste fixe de
  /// champs par sexe, comme dans l'ancienne application.
  Future<String?> _idGabaritPourSexe(String sexe) async {
    final liste = await ref.read(typesTenueVisiblesProvider.future);
    for (final type in liste) {
      if (type.estGabaritParDefaut && type.sexe == sexe) return type.id;
    }
    return null;
  }

  /// Enregistre les mesures déjà saisies en une seule prise, appelée au
  /// moment d'"Enregistrer le client" (jamais par champ : `mesures` est une
  /// table historisée, chaque appel crée une nouvelle ligne).
  Future<void> _enregistrerMesures(Client client) async {
    if (_mesuresEnregistrees || _sexe == null) return;

    final valeurs = <String, String>{};
    for (final entree in _controleursMesure.entries) {
      final texte = entree.value.text.trim();
      if (texte.isNotEmpty) valeurs[entree.key] = texte;
    }
    if (valeurs.isEmpty) return;

    final typeTenueId = await _idGabaritPourSexe(_sexe!);
    if (typeTenueId == null) return;

    try {
      final utilisateur = await ref.read(utilisateurCourantProvider.future);
      await ref.read(mesuresRepositoryProvider).enregistrerNouvellePrise(
            atelierId: utilisateur!.atelierId,
            clientId: client.id,
            typeTenueId: typeTenueId,
            valeurs: valeurs,
            prisePar: utilisateur.id,
          );
      if (mounted) setState(() => _mesuresEnregistrees = true);
    } catch (e) {
      if (mounted) setState(() => _erreur = e.toString());
    }
  }

  Future<void> _enregistrerFinances() async {
    final client = await _assurerClientCree();
    if (client == null) return;

    final montantTotal = double.tryParse(_montantTotalCtrl.text.replaceAll(',', '.')) ?? 0;
    final avance = double.tryParse(_avanceCtrl.text.replaceAll(',', '.')) ?? 0;
    if (montantTotal <= 0 && avance <= 0) return;

    try {
      await ref.read(financesRepositoryProvider).definirCommande(
            atelierId: client.atelierId,
            clientId: client.id,
            montantTotal: montantTotal,
            avance: avance,
          );
      if (mounted) {
        setState(() => _financesEnregistrees = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Finances enregistrées.')),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _erreur = e.toString());
    }
  }

  Future<void> _ajouterPhoto(TypePhoto type) async {
    final client = await _assurerClientCree();
    if (client == null || !mounted) return;

    final resultat = await choisirSourceEtImage(context);
    if (resultat == null) return;
    final (fichier, sourceImage) = resultat;

    setState(() => _photoEnCours = true);
    try {
      await ref.read(photosRepositoryProvider).ajouterPhoto(
            atelierId: client.atelierId,
            clientId: client.id,
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
      if (mounted) setState(() => _photoEnCours = false);
    }
  }

  Future<void> _ajouterRendezVous() async {
    final client = await _assurerClientCree();
    if (client == null || !mounted) return;
    context.push(AppRoutes.creationRendezVous, extra: client);
  }

  Future<void> _terminer() async {
    final client = await _assurerClientCree();
    if (client == null || !mounted) return;
    await _enregistrerMesures(client);
    if (!mounted) return;
    context.pushReplacement(AppRoutes.ficheClient(client.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F1),
      appBar: AppBar(
        title: const Text('Nouveau client'),
        backgroundColor: const Color(0xFFE8E3DD),
        foregroundColor: const Color(0xFF231A14),
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _EnTeteSection(
                    icone: Icons.badge_outlined,
                    couleurFond: const Color(0xFFE3E1F5),
                    couleurIcone: const Color(0xFF3B3470),
                    titre: 'Informations du client',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nomCtrl,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _prenomCtrl,
                    decoration: const InputDecoration(labelText: 'Prénom'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _telephoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Contact (téléphone)'),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    tileColor: const Color(0xFFF3E9D8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFDDD3C8)),
                    ),
                    title: const Text('Date de prise des mesures'),
                    subtitle: Text(
                      _datePriseMesures == null
                          ? 'Non renseignée'
                          : Formatters.dateLongue(_datePriseMesures!),
                    ),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: _choisirDate,
                  ),
                  const SizedBox(height: 16),
                  const Text('Sexe', style: TextStyle(color: Color(0xFF6F6259))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _CarteSexe(
                          icone: Icons.male,
                          libelle: 'Homme',
                          selectionne: _sexe == 'Homme',
                          onTap: () => setState(() => _sexe = 'Homme'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CarteSexe(
                          icone: Icons.female,
                          libelle: 'Femme',
                          selectionne: _sexe == 'Femme',
                          onTap: () => setState(() => _sexe = 'Femme'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _EnTeteSection(
                    icone: Icons.straighten_outlined,
                    couleurFond: const Color(0xFFF5DCD3),
                    couleurIcone: const Color(0xFF8A4B24),
                    titre: 'Mesures',
                  ),
                  const SizedBox(height: 12),
                  if (_sexe == null)
                    const Text(
                      'Renseigne le sexe du client ci-dessus pour afficher les champs de mesure.',
                      style: TextStyle(color: Color(0xFF6F6259)),
                    )
                  else
                    _SectionMesures(
                      sexe: _sexe!,
                      controleurPour: _controleurMesure,
                    ),
                  const SizedBox(height: 28),
                  _EnTeteSection(
                    icone: Icons.texture_outlined,
                    couleurFond: const Color(0xFFF0E6C8),
                    couleurIcone: const Color(0xFFA47B1B),
                    titre: 'Photos du tissu',
                  ),
                  const SizedBox(height: 12),
                  _GrillePhotosSection(
                    clientId: _client?.id,
                    type: TypePhoto.tissu,
                    enCours: _photoEnCours,
                    onAjouter: () => _ajouterPhoto(TypePhoto.tissu),
                  ),
                  const SizedBox(height: 28),
                  _EnTeteSection(
                    icone: Icons.checkroom_outlined,
                    couleurFond: const Color(0xFFDCEADF),
                    couleurIcone: const Color(0xFF2E7D32),
                    titre: 'Photos du ou des modèles',
                  ),
                  const SizedBox(height: 12),
                  _GrillePhotosSection(
                    clientId: _client?.id,
                    type: TypePhoto.modele,
                    enCours: _photoEnCours,
                    onAjouter: () => _ajouterPhoto(TypePhoto.modele),
                  ),
                  const SizedBox(height: 28),
                  _EnTeteSection(
                    icone: Icons.savings_outlined,
                    couleurFond: const Color(0xFFDCEADF),
                    couleurIcone: const Color(0xFF2E7D32),
                    titre: 'Finances',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _montantTotalCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Montant total convenu (FCFA)'),
                    onChanged: (_) => setState(() {}),
                    onEditingComplete: _enregistrerFinances,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _avanceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Avance déjà payée par le client'),
                    onChanged: (_) => setState(() {}),
                    onEditingComplete: _enregistrerFinances,
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
                            (double.tryParse(_montantTotalCtrl.text.replaceAll(',', '.')) ?? 0) -
                                (double.tryParse(_avanceCtrl.text.replaceAll(',', '.')) ?? 0),
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _EnTeteSection(
                    icone: Icons.event_available_outlined,
                    couleurFond: const Color(0xFFF0E6C8),
                    couleurIcone: const Color(0xFFA47B1B),
                    titre: 'Rendez-vous',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _ajouterRendezVous,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un rendez-vous'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      foregroundColor: const Color(0xFF141B3E),
                      side: const BorderSide(color: Color(0xFF141B3E)),
                    ),
                  ),
                  if (_erreur != null) ...[
                    const SizedBox(height: 16),
                    Text(_erreur!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Color(0xFF2E7D32)),
                      SizedBox(width: 6),
                      Text('Enregistré automatiquement', style: TextStyle(color: Color(0xFF2E7D32))),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: FilledButton(
                onPressed: _enregistrementClientEnCours ? null : _terminer,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF141B3E),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                child: _enregistrementClientEnCours
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Enregistrer le client'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnTeteSection extends StatelessWidget {
  const _EnTeteSection({
    required this.icone,
    required this.couleurFond,
    required this.couleurIcone,
    required this.titre,
  });

  final IconData icone;
  final Color couleurFond;
  final Color couleurIcone;
  final String titre;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 20, backgroundColor: couleurFond, child: Icon(icone, color: couleurIcone)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            titre,
            style: const TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ],
    );
  }
}

class _CarteSexe extends StatelessWidget {
  const _CarteSexe({
    required this.icone,
    required this.libelle,
    required this.selectionne,
    required this.onTap,
  });

  final IconData icone;
  final String libelle;
  final bool selectionne;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selectionne ? const Color(0xFF141B3E) : const Color(0xFFDDD3C8),
              width: selectionne ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icone, size: 28),
              const SizedBox(height: 8),
              Text(libelle),
            ],
          ),
        ),
      ),
    );
  }
}

/// Liste fixe des champs de mesure selon le sexe du client — pas de choix
/// de type de tenue à cette étape (contrairement aux groupes d'uniformes) :
/// l'ancienne application affiche directement, dès le sexe choisi, la même
/// liste de ~20 (homme) ou ~23 (femme) champs, lue depuis les gabarits par
/// défaut `Standard homme`/`Standard femme` (voir schema.sql, section 6).
class _SectionMesures extends ConsumerWidget {
  const _SectionMesures({required this.sexe, required this.controleurPour});

  final String sexe;
  final TextEditingController Function(String champId) controleurPour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(typesTenueVisiblesProvider);

    return types.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Impossible de charger les champs de mesure.'),
      data: (liste) {
        TypeTenue? gabarit;
        for (final type in liste) {
          if (type.estGabaritParDefaut && type.sexe == sexe) {
            gabarit = type;
            break;
          }
        }
        if (gabarit == null) {
          return const Text(
            'Connectez-vous à internet une première fois pour récupérer les champs de mesure.',
            style: TextStyle(color: Color(0xFF6F6259)),
          );
        }

        final champs = ref.watch(champsActifsProvider(gabarit.id));
        return champs.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Impossible de charger les champs de mesure.'),
          data: (champsListe) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final champ in champsListe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: controleurPour(champ.id),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: '${champ.nom} (${champ.unite})'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GrillePhotosSection extends ConsumerWidget {
  const _GrillePhotosSection({
    required this.clientId,
    required this.type,
    required this.enCours,
    required this.onAjouter,
  });

  final String? clientId;
  final TypePhoto type;
  final bool enCours;
  final VoidCallback onAjouter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = clientId == null
        ? const AsyncValue<List<PhotoClient>>.data([])
        : ref.watch(photosDuClientProvider(clientId!));
    final liste = photos.valueOrNull?.where((p) => p.type == type).toList() ?? [];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final photo in liste) _TuilePhoto(photo: photo),
        InkWell(
          onTap: enCours ? null : onAjouter,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDDD3C8)),
            ),
            child: enCours
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.add_a_photo_outlined),
          ),
        ),
      ],
    );
  }
}

/// Vignette d'une photo avec, en superposition, le contrôle de note vocale
/// de description : un micro tant qu'aucun vocal n'existe (appui = démarre,
/// appui = arrête et envoie), puis un bouton lecture/pause une fois un
/// vocal enregistré.
class _TuilePhoto extends ConsumerStatefulWidget {
  const _TuilePhoto({required this.photo});

  final PhotoClient photo;

  @override
  ConsumerState<_TuilePhoto> createState() => _TuilePhotoState();
}

class _TuilePhotoState extends ConsumerState<_TuilePhoto> {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  bool _enregistrement = false;
  bool _enCoursEnvoi = false;
  bool _lecture = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _lecture = false);
    });
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _basculerEnregistrement() async {
    if (_enregistrement) {
      final chemin = await _recorder.stop();
      if (mounted) setState(() => _enregistrement = false);
      if (chemin == null) return;

      setState(() => _enCoursEnvoi = true);
      try {
        await ref.read(photosRepositoryProvider).ajouterAudioAPhoto(
              photo: widget.photo,
              cheminFichierAudio: chemin,
            );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec de l\'envoi du vocal : $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _enCoursEnvoi = false);
      }
      return;
    }

    if (!await _recorder.hasPermission()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autorisez le micro pour enregistrer une note vocale.')),
        );
      }
      return;
    }

    final dossierTemp = await getTemporaryDirectory();
    final chemin = p.join(dossierTemp.path, '${const Uuid().v4()}.m4a');
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: chemin);
    if (mounted) setState(() => _enregistrement = true);
  }

  Future<void> _basculerLecture() async {
    if (_lecture) {
      await _player.pause();
      if (mounted) setState(() => _lecture = false);
    } else {
      await _player.play(UrlSource(widget.photo.audioUrl!));
      if (mounted) setState(() => _lecture = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aUnAudio = widget.photo.audioUrl != null;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(widget.photo.url, width: 90, height: 90, fit: BoxFit.cover),
        ),
        Positioned(
          right: 4,
          bottom: 4,
          child: GestureDetector(
            onTap: _enCoursEnvoi ? null : (aUnAudio ? _basculerLecture : _basculerEnregistrement),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: _enregistrement ? Colors.red : const Color(0xFF141B3E),
              child: _enCoursEnvoi
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      aUnAudio
                          ? (_lecture ? Icons.pause : Icons.play_arrow)
                          : (_enregistrement ? Icons.stop : Icons.mic),
                      size: 16,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
