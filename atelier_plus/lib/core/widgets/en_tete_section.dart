import 'package:flutter/material.dart';

/// En-tête de section fidèle à l'ancienne application : icône dans un
/// cercle coloré, puis titre en gras avec une police à empattements.
/// Utilisé par "Nouveau client" et par la fiche client, pour que les deux
/// écrans restent visuellement cohérents.
class EnTeteSection extends StatelessWidget {
  const EnTeteSection({
    super.key,
    required this.icone,
    required this.couleurFond,
    required this.couleurIcone,
    required this.titre,
    this.onTap,
  });

  final IconData icone;
  final Color couleurFond;
  final Color couleurIcone;
  final String titre;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final contenu = Row(
      children: [
        CircleAvatar(radius: 20, backgroundColor: couleurFond, child: Icon(icone, color: couleurIcone)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            titre,
            style: const TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        if (onTap != null) const Icon(Icons.chevron_right, color: Color(0xFF6F6259)),
      ],
    );
    if (onTap == null) return contenu;
    return InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap, child: contenu);
  }
}
