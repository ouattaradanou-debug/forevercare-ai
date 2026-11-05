# Audit de sécurité — phase 14 (05/11/2026)

Audit fait sur le code du dépôt et sur une base Supabase locale identique au
serveur (toutes les migrations appliquées). Les contrôles marqués « auto »
sont rejoués à chaque modification par l'intégration continue : une
régression fait échouer la construction.

**Résultat : aucune faille critique ouverte.** Une faille moyenne a été
trouvée (sauvegarde du téléphone en clair) et corrigée. Deux points de
défense en profondeur ont été renforcés. Il reste 4 points à faire avant la
publication (signature, clé IA, sauvegarde des fichiers, revue juridique) ;
aucun ne bloque l'essai pilote.

## 1. Droits sur les données (RLS)
| Contrôle | Résultat | Preuve |
|---|---|---|
| RLS activée sur toutes les tables (données de l’école et dossier médical) | ✅ | auto : `00_rls_partout`, `27_phase14_audit` |
| Aucune règle ouverte à « tout le monde » ou aux personnes non connectées | ✅ | auto : `27_phase14_audit` |
| Une personne non connectée ne lit rien, même par l'API | ✅ **renforcé** : les droits par défaut de Supabase sur les tables et fonctions sont retirés au rôle « anon » (migration `20261109000100`) ; la lecture est refusée d'emblée | auto + essai réel |
| Enseignant : sa classe seulement (élèves, notes, appel, emploi du temps) | ✅ | auto : tests 03, 11, 26 ; intégration |
| Délégués : seulement les droits accordés (finances, cantine, cartes…) | ✅ | auto : tests 10, 20, 23 |
| Autre école : rien ne sort, rien ne s'écrit | ✅ | auto : un test « autre école » par module |
| Fonctions « security definer » : `search_path` fixé (pas de détournement) | ✅ | auto : `27_phase14_audit` |
| Suppression physique interdite (élèves, notes, présences) ; finances en ajout seul | ✅ | auto : `27_phase14_audit`, test 20 |

Tables sans règle d'accès (donc fermées à tous) : `document_classes`,
`document_levels`, `school_counters`, `scolarity_followups`,
`scolarity_followup_courses`. C'est voulu : elles ne servent qu'aux
fonctions du serveur.

## 2. Secrets
| Contrôle | Résultat |
|---|---|
| Aucune clé dans le dépôt ni dans son historique (clé Claude `sk-ant-`, clé serveur, jetons, clés privées) | ✅ recherche sur tout l'historique git |
| Fichiers secrets ignorés par git : `.env`, `.serveur-test.json`, `telephone.env`, `cle-ia.txt`, **et maintenant** `*.jks`, `*.keystore`, `android/key.properties` | ✅ |
| Clé « service » du serveur : jamais dans l'application (seulement dans les fonctions serveur et GitHub) | ✅ |
| Clé de l'IA : seulement dans les secrets des fonctions serveur | ✅ |
| Clé de la base du téléphone : coffre Android (Keystore), jamais envoyée | ✅ |

## 3. Stockage des fichiers
| Contrôle | Résultat |
|---|---|
| Les 3 compartiments (photos et en-têtes, documents, justificatifs) sont privés | ✅ auto |
| Taille limitée par fichier (2 Mo, 50 Mo, 10 Mo) et types autorisés | ✅ |
| Chemins rangés par école ; lecture seulement par les membres de l'école | ✅ tests 07, 17, 18 |
| Quota par école | ✅ test 18 |

## 4. Index de l'IA (bibliothèque)
| Contrôle | Résultat |
|---|---|
| Passages cherchés **avec les droits de la personne** (security invoker) | ✅ auto |
| Jamais une autre classe, les archives, un document exclu, sensible ou à la corbeille | ✅ test 25, intégration phase 12 |
| Noms des élèves remplacés par « [élève] » avant l'envoi au fournisseur | ✅ intégration phase 12 |
| Extraits recopiés de plus de 25 mots retirés | ✅ |
| Consignes cachées dans un document : données, jamais des ordres | ✅ (à revérifier avec la vraie clé) |

## 5. Dossier médico-scolaire
| Contrôle | Résultat |
|---|---|
| Schéma séparé ; aucune table lisible directement | ✅ auto |
| Accès seulement par des fonctions qui écrivent dans le journal d'accès | ✅ test 16 |
| Journal d'accès jamais modifié ni effacé | ✅ auto |
| Jamais dans l'IA, les exports, la recherche, le journal général, la sauvegarde du téléphone | ✅ (les données médicales ne sont pas sur le téléphone) |
| Module désactivé par défaut | ✅ |

## 6. Journaux
| Contrôle | Résultat |
|---|---|
| Journal d'activité et des conflits : lecture seule pour l'application | ✅ auto |
| Événements de sécurité signalés au directeur (connexion, mot de passe, téléphone déconnecté) | ✅ test sécurité |
| L'application n'écrit rien dans les journaux du téléphone (`print`) | ✅ recherche dans le code |

## 7. Téléphone
| Contrôle | Résultat |
|---|---|
| Base du téléphone chiffrée (AES, clé du Keystore) | ✅ |
| Sauvegarde Android automatique (Google Drive) désactivée | ✅ manifeste |
| Code de verrouillage : haché, jamais en clair ; blocage après erreurs | ✅ |
| Pas de micro sur les mots de passe, codes et réponses secrètes | ✅ |
| Permissions : Internet, réseau, micro (dictée), empreinte ; aucun accès aux fichiers du téléphone | ✅ |
| **Fichier de sauvegarde du téléphone** | ❌ trouvé en clair (toutes les données de l'école lisibles, empreinte du code de verrouillage incluse) → ✅ **corrigé** : chiffré avec un mot de passe choisi par le directeur (8 caractères au moins), empreinte du code retirée ; test : rien de lisible sans le mot de passe, mauvais mot de passe refusé |
| Code de l'application compacté et rendu illisible (`--obfuscate`) | ✅ ajouté à la construction |

## 8. Points restants (avant publication)
1. **Signature de publication** : créer la clé de l'application (voir
   `PUBLICATION.md`) ; aujourd'hui, les APK d'essai sont signés avec la clé
   de test.
2. **Clé IA réelle** : refaire le test « consigne cachée » avec Claude.
3. **Fichiers du stockage** (photos, documents) : ils ne sont pas dans la
   sauvegarde nocturne de la base. Supabase les garde, mais une copie
   séparée est conseillée (voir `SAUVEGARDE_SERVEUR.md`).
4. **Revue juridique** : `POINTS_JURIDIQUES.md`.
