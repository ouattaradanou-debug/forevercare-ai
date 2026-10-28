# Dossier médico-scolaire — points à faire vérifier par un professionnel du droit

Le module enregistre des **données de santé d'enfants mineurs**. Avant toute
utilisation avec de vrais élèves, faites vérifier les points suivants par un
juriste ou l'autorité compétente au Burkina Faso (par exemple la Commission
de l'Informatique et des Libertés — CIL). Rien ici n'est un avis juridique.

| # | Point à vérifier | Ce que fait l'application aujourd'hui |
|---|---|---|
| J1 | Base légale pour qu'une école enregistre des données de santé d'élèves (mission de service public ? consentement des parents ?) | Module désactivé par défaut ; activation explicite par le directeur avec avertissement |
| J2 | Formalités auprès de l'autorité de protection des données (déclaration, autorisation) | Aucune ; à faire par l'école ou le porteur |
| J3 | Information et consentement des parents : contenu, forme (écrit, signé), langue | Texte d'information **proposé**, imprimable (« Options » → « Information des parents ») ; signature sur papier |
| J4 | Qui peut accéder : directeur seul ? infirmier, médecin scolaire, personne désignée ? | Directeur seulement ; l'enseignant(e) ne voit que la mention d'aptitude, si le directeur l'expose |
| J5 | Durée de conservation ; sort des fiches quand l'élève quitte l'école ou à l'archivage définitif | **À définir** : rien n'est effacé automatiquement ; la fiche n'est pas transmise à l'école suivante |
| J6 | Droit des parents d'accéder, de faire corriger, de refuser certains champs | Tous les champs sont facultatifs ; consultation et correction par le directeur |
| J7 | Hébergement des données : serveur hors du Burkina Faso (Supabase) ; transfert autorisé ? | Données sur le serveur de l'école (Supabase), chiffrées en transit ; sauvegardes chiffrées |
| J8 | Journal des accès : durée de conservation du journal, qui peut le consulter | Journal non modifiable ; lisible par le directeur seul ; conservé sans limite pour l'instant |
| J9 | Impression et partage du PDF : règles de conservation du papier, envoi par WhatsApp | Possible pour le directeur ; chaque impression est journalisée ; mention « Document confidentiel » |
| J10 | Responsabilité en cas de fuite (école, porteur, hébergeur) ; procédure de notification | Aucune procédure automatique ; à définir |

Mesures techniques en place (phase 7) :
- données dans un schéma séparé du serveur, **jamais** synchronisées vers les téléphones (rien n'est gardé en local, même chiffré) ;
- accès uniquement par des fonctions du serveur qui vérifient « directeur + module actif » et **journalisent chaque tentative**, autorisée ou refusée ;
- jamais envoyées à l'assistant IA, ni dans la recherche globale, les exports généraux, le journal d'activité ou les notifications (contrôle automatique dans les tests) ;
- pas de micro sur la fiche (la dictée passerait par un service extérieur au téléphone).
