# Assistant IA — installer la clé et régler les limites

La clé du fournisseur d'IA reste **sur le serveur** (variables de la
fonction `assistant-ia`) : jamais dans l'application, jamais dans le dépôt.

## Réglages retenus (05/11/2026, en attente de la décision finale)
| Réglage | Valeur | Où le changer |
|---|---|---|
| Fournisseur et modèle | Anthropic, `claude-haiku-5-5` | variables `AI_PROVIDER`, `AI_MODEL` |
| Modèle de secours | `claude-sonnet-5-5` | variable `AI_MODEL` |
| Recherche dans la bibliothèque | par les mots (texte intégral) | — |
| Limite par enseignant | 30 demandes / mois | table `ai_quotas.teacher_monthly_limit` ; par enseignant : écran du directeur |
| Limite par école | 300 demandes et 5 $ / mois | table `ai_quotas` (porteur du projet) |

## Installer la clé sur le serveur de test (Windows)
1. Sur **console.anthropic.com** : créez un compte, ajoutez un moyen de
   paiement et un **plafond de dépense mensuel** (ex. 20 $ pour l'essai).
2. « API keys » → « Create key » → copiez la clé (elle commence par
   `sk-ant-`).
3. Dans `Documents\ecoleplus-projet\ecoleplus`, créez un fichier texte
   **`cle-ia.txt`** contenant seulement la clé. Ce fichier est ignoré par
   git : il ne part jamais sur GitHub.
4. Lancez la commande habituelle (`tools\tester-sur-telephone.ps1`). ✅ Le
   script affiche « clé de l'assistant IA installée sur le serveur (modèle
   Claude Haiku 5.5) ».
5. Pour revenir au mode simulé : supprimez `cle-ia.txt` et, sur le serveur,
   la variable `AI_API_KEY` (tableau de bord Supabase → Edge Functions →
   Secrets).

## Passer à Claude Sonnet 5.5
Tableau de bord Supabase → Edge Functions → Secrets → `AI_MODEL` =
`claude-sonnet-5-5`. Aucune mise à jour des téléphones. Pensez au budget :
avec Sonnet, 5 $ font environ 110 demandes par école.

## Changer les limites d'une école
Dans l'éditeur SQL de Supabase (porteur du projet seulement) :
```sql
insert into public.ai_quotas (school_id, monthly_request_limit, monthly_budget_microusd, teacher_monthly_limit)
values ('<id de l’école>', 600, 10000000, 30)
on conflict (school_id) do update
  set monthly_request_limit = excluded.monthly_request_limit,
      monthly_budget_microusd = excluded.monthly_budget_microusd,
      teacher_monthly_limit = excluded.teacher_monthly_limit;
```
(5 000 000 micro-dollars = 5 $.)

## Ce que fait la fonction à chaque demande
1. Vérifie la personne (enseignant ou directeur de l'école).
2. Vérifie les limites du mois (enseignant, école, budget).
3. Remplace les noms des élèves de l'école par « [élève] ».
4. Cherche au plus 8 passages dans la bibliothèque **avec les droits de la
   personne** (jamais une autre classe, les archives, un document exclu,
   sensible ou à la corbeille).
5. Appelle Claude : consignes fixes en cache, réponse JSON imposée, effort
   bas ; les passages sont donnés comme des données, jamais comme des
   consignes.
6. Retire tout extrait recopié de plus de 25 mots.
7. Enregistre la demande et son coût (`ai_requests`) ; une demande qui
   échoue n'est pas comptée.
