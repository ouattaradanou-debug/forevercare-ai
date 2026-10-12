import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../core/utils/telephone.dart';
import '../../../data/models/client.dart';

/// Vérifie que [client] existe dans les Contacts du téléphone (pas
/// seulement dans Atelier+) et l'y ajoute si besoin, pour que WhatsApp
/// puisse reconnaître son numéro et présélectionner sa conversation lors de
/// l'envoi d'une facture (voir envoi_whatsapp_natif.dart) — WhatsApp ne
/// résout fiablement un numéro en conversation connue que s'il correspond à
/// un contact enregistré. Ne fait rien si la permission Contacts est
/// refusée, ou si un contact avec ce numéro existe déjà (pas de doublon
/// créé à chaque envoi de facture). Une erreur ici (permission, Contacts
/// indisponible…) est avalée : ce n'est qu'une amélioration, elle ne doit
/// jamais empêcher l'envoi de la facture qui suit.
Future<void> assurerContactTelephone(Client client) async {
  try {
    final autorise = await FlutterContacts.requestPermission();
    if (!autorise) return;

    final numeroClient = Telephone.normaliser(client.telephone);
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    final dejaPresent = contacts.any(
      (c) => c.phones.any((p) => Telephone.normaliser(p.number) == numeroClient),
    );
    if (dejaPresent) return;

    final nouveauContact = Contact()
      ..name.first = client.nomComplet
      ..phones = [Phone(client.telephone)];
    await nouveauContact.insert();
  } catch (_) {
    // Amélioration best-effort : on continue l'envoi même si l'ajout aux
    // Contacts échoue pour une raison quelconque.
  }
}
