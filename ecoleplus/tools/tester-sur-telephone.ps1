<#
.SYNOPSIS
  EcolePlus : prépare le serveur de test et installe l'application sur le
  portable branché en USB. Une seule commande, à relancer après chaque phase.

.DESCRIPTION
  1re fois : crée le projet Supabase « ecoleplus-test » (offre gratuite), y
  installe toutes les tables et « École Test », déploie les fonctions serveur.
  Fois suivantes : applique seulement les nouveautés (vos essais sont gardés).
  Puis : construit l'application et l'installe sur le portable.

  Les informations du serveur de test (dont son mot de passe) sont gardées
  dans ecoleplus\.serveur-test.json, sur VOTRE ordinateur seulement (jamais
  envoyé sur GitHub).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tools\tester-sur-telephone.ps1
  powershell -ExecutionPolicy Bypass -File tools\tester-sur-telephone.ps1 -Reinitialiser
  powershell -ExecutionPolicy Bypass -File tools\tester-sur-telephone.ps1 -ChangerDeCompte
#>
param(
  # Remet le serveur de test à zéro avec « École Test » (efface vos essais).
  [switch]$Reinitialiser,
  # Met seulement le serveur à jour, sans installer sur le portable.
  [switch]$SansInstallation,
  # Se déconnecter du compte Supabase actuel pour en utiliser un autre
  # (ex. un compte réservé à EcolePlus). Ne touche à aucun projet existant.
  [switch]$ChangerDeCompte,
  # Région du serveur (Paris par défaut, la plus proche du Burkina Faso).
  [string]$Region = 'eu-west-3'
)

# « Continue » et non « Stop » : sous Windows PowerShell 5.1, les messages
# normaux que la CLI Supabase écrit sur le canal d'erreur seraient sinon pris
# pour des erreurs et arrêteraient le script. Chaque commande est vérifiée
# explicitement (code de retour).
$ErrorActionPreference = 'Continue'
$racine = Split-Path -Parent $PSScriptRoot          # dossier ecoleplus
Set-Location $racine
$fichierConfig = Join-Path $racine '.serveur-test.json'
$fichierEnv = Join-Path $racine 'telephone.env'

function Etape($texte) { Write-Host ''; Write-Host "==> $texte" -ForegroundColor Cyan }
function Ok($texte) { Write-Host "    OK : $texte" -ForegroundColor Green }
function Arret($texte) { Write-Host ''; Write-Host "ARRÊT : $texte" -ForegroundColor Red; exit 1 }

# Chaque commande est transmise sous forme de LISTE explicite, ex.
#   Supabase @('link', '--project-ref', $ref, '-p', $mdp)
# (sous Windows PowerShell 5.1, « @args » n'est pas transmis à npx, et des mots
# comme « -p » seraient pris pour des options de PowerShell).
function Supabase([string[]]$Mots) {
  # CLI Supabase à version fixe (téléchargée automatiquement par npx). Ses
  # messages sont affichés en texte normal (sinon PowerShell 5.1 les montre
  # en rouge alors que ce ne sont pas des erreurs).
  # (Les lignes vides d'erreur s'affichent « System.Management...RemoteException ».)
  $lignes = @(& npx --yes supabase@2.121.0 $Mots 2>&1 | ForEach-Object { "$_" } |
              ForEach-Object { if ($_ -eq 'System.Management.Automation.RemoteException') { '' } else { $_ } })
  $lignes | ForEach-Object { Write-Host "    $_" }
  if ($LASTEXITCODE -ne 0 -or ($lignes -match '^\s*SUBCOMMANDS\s*$')) {
    throw "La commande « supabase $($Mots -join ' ') » a échoué."
  }
}

function SupabaseJson([string[]]$Mots) {
  # Réponse JSON de la CLI (option --output-format json). Selon les commandes,
  # la liste peut être directe ou rangée dans une enveloppe : on la retrouve.
  $sortie = & npx --yes supabase@2.121.0 ($Mots + @('--output-format', 'json')) 2>$null
  $texte = ($sortie | Where-Object { $_ -is [string] }) -join "`n"
  $script:derniereReponse = $texte
  $debut = $texte.IndexOfAny([char[]]'[{')
  if ($debut -lt 0) {
    if ($LASTEXITCODE -ne 0) { throw "La commande « supabase $($Mots -join ' ') » a échoué." }
    return @()
  }
  $json = $texte.Substring($debut) | ConvertFrom-Json
  # Déballe jusqu'à trouver la liste : {"organizations":[...]}, {"data":...}…
  for ($n = 0; $n -lt 5; $n++) {
    if ($json -is [array]) { return $json }
    if ($json._tag -eq 'Error') { throw "Supabase a répondu : $($json.error.message)" }
    if ($json._tag -eq 'Help') { throw "Commande « supabase $($Mots -join ' ') » non comprise par Supabase." }
    $suivant = $null
    if ($json.PSObject.Properties['data']) { $suivant = $json.data }
    else {
      foreach ($p in $json.PSObject.Properties) { if ($p.Value -is [array]) { $suivant = $p.Value; break } }
    }
    if ($null -eq $suivant) { return @($json) }
    $json = $suivant
  }
  return @($json)
}

function Champ($objet, [string[]]$noms) {
  foreach ($n in $noms) {
    if ($objet -and $objet.PSObject.Properties[$n] -and "$($objet.$n)" -ne '') { return "$($objet.$n)" }
  }
  return ''
}

function ArretAvecReponse($texte) {
  Write-Host ''
  Write-Host 'Réponse reçue de Supabase (à copier pour l''assistant) :' -ForegroundColor Yellow
  Write-Host $script:derniereReponse
  Arret $texte
}

# --------------------------------------------------------------------------
Etape 'Vérification des outils'
foreach ($outil in @('flutter', 'npx', 'git')) {
  if (-not (Get-Command $outil -ErrorAction SilentlyContinue)) {
    Arret "« $outil » est introuvable. Il était installé pour Atelier Plus : ouvrez un nouveau PowerShell ou réinstallez-le."
  }
}
Ok 'flutter, npx et git sont présents'
try {
  $versions = (& flutter --version --machine) -join "`n" | ConvertFrom-Json
  if ([version]($versions.dartSdkVersion -replace '[^0-9.].*$', '') -lt [version]'3.13.0') {
    Write-Host "    Votre Flutter est trop ancien ($($versions.frameworkVersion)) : mise à jour (une seule fois)..." -ForegroundColor Yellow
    & flutter upgrade
  }
} catch { Write-Host '    (version de Flutter non vérifiée)' -ForegroundColor Yellow }

if ($ChangerDeCompte) {
  Etape 'Changement de compte Supabase'
  & npx --yes supabase@2.121.0 logout --yes 2>&1 | Out-Null
  # Oublie le serveur de test enregistré pour l'ancien compte (sur ce PC
  # seulement : rien n'est supprimé chez Supabase).
  Remove-Item -Force -ErrorAction SilentlyContinue $fichierConfig, $fichierEnv
  Write-Host '    Dans le navigateur, connectez-vous avec le NOUVEAU compte Supabase'
  Write-Host '    (déconnectez-vous d''abord de l''ancien sur supabase.com, ou utilisez une fenêtre de navigation privée).'
  Ok 'ancien compte oublié sur ce PC'
}

Etape 'Connexion à votre compte Supabase'
& npx --yes supabase@2.121.0 projects list 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Host '    Une page va s''ouvrir dans le navigateur : connectez-vous à Supabase et autorisez la CLI.'
  & npx --yes supabase@2.121.0 login
  if ($LASTEXITCODE -ne 0) { Arret 'Connexion à Supabase impossible.' }
}
Ok 'connecté'

# --------------------------------------------------------------------------
if (Test-Path $fichierConfig) {
  $config = Get-Content $fichierConfig -Raw | ConvertFrom-Json
  if (-not $config.ref) { Remove-Item -Force $fichierConfig; $config = $null }
}
if ($config) {
  Ok "serveur de test déjà créé (projet $($config.ref))"
  $nouveau = $false
} else {
  Etape 'Création du serveur de test « ecoleplus-test » (offre gratuite)'
  $orgs = @(SupabaseJson @('orgs', 'list'))
  if ($orgs.Count -eq 0) {
    Write-Host '    Aucune organisation sur ce compte : création de l''organisation « EcolePlus »...'
    Supabase @('orgs', 'create', 'EcolePlus')
    $orgs = @(SupabaseJson @('orgs', 'list'))
    if ($orgs.Count -eq 0) { Arret 'Impossible de créer l''organisation. Créez-en une sur supabase.com (offre Free), puis relancez.' }
  }
  $org = $orgs[0]
  $orgId = Champ $org @('id', 'slug', 'organization_id', 'organization_slug')
  if (-not $orgId) { ArretAvecReponse 'Organisation Supabase illisible.' }
  Write-Host "    Organisation : $(Champ $org @('name')) ($orgId)"
  # Mot de passe de la base, long et aléatoire, gardé sur ce PC seulement.
  $octets = New-Object byte[] 24
  [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($octets)
  $motDePasse = ([Convert]::ToBase64String($octets) -replace '[+/=]', 'x')
  try {
    Supabase @('projects', 'create', 'ecoleplus-test', '--org-id', $orgId, '--db-password', $motDePasse, '--region', $Region)
  } catch {
    Arret ("Création du projet impossible : lisez le message de Supabase juste au-dessus. " +
           "(Si c'est la limite de 2 projets gratuits actifs, mettez-en un en pause sur supabase.com.)")
  }
  $projet = @(SupabaseJson @('projects', 'list')) | Where-Object { (Champ $_ @('name')) -eq 'ecoleplus-test' } | Select-Object -First 1
  $ref = Champ $projet @('ref', 'id', 'project_ref')
  if (-not $ref) { ArretAvecReponse 'Le projet « ecoleplus-test » est introuvable après sa création.' }
  $config = [pscustomobject]@{ ref = $ref; motDePasse = $motDePasse; url = "https://$ref.supabase.co"; cle = '' }
  $config | ConvertTo-Json | Set-Content $fichierConfig -Encoding UTF8
  Ok "projet créé : $ref"
  $nouveau = $true

  Write-Host '    Préparation du serveur par Supabase (2 à 5 minutes)...'
  for ($i = 0; $i -lt 60; $i++) {
    $etat = Champ (@(SupabaseJson @('projects', 'list')) | Where-Object { (Champ $_ @('name')) -eq 'ecoleplus-test' } | Select-Object -First 1) @('status')
    if ($etat -eq 'ACTIVE_HEALTHY') { break }
    Start-Sleep -Seconds 10
  }
  Ok 'serveur prêt'
}

if (-not $config.cle) {
  $cles = @(SupabaseJson @('projects', 'api-keys', '--project-ref', $config.ref))
  $anon = $cles | Where-Object { (Champ $_ @('name')) -eq 'anon' } | Select-Object -First 1
  if (-not $anon) { $anon = $cles | Where-Object { (Champ $_ @('type')) -eq 'publishable' } | Select-Object -First 1 }
  $config.cle = Champ $anon @('api_key', 'key')
  if (-not $config.cle) { ArretAvecReponse 'Clé publique du projet introuvable.' }
  $config | ConvertTo-Json | Set-Content $fichierConfig -Encoding UTF8
}

# --------------------------------------------------------------------------
Etape 'Mise à jour du serveur de test'
$env:SUPABASE_DB_PASSWORD = $config.motDePasse
Supabase @('link', '--project-ref', $config.ref, '-p', $config.motDePasse)
if ($Reinitialiser) {
  # La remise à zéro complète passe par la connexion directe à la base.
  Write-Host '    Remise à zéro du serveur de test...'
  try { Supabase @('db', 'reset', '--linked', '--yes') }
  catch {
    Arret ("La remise à zéro a besoin d'une connexion directe à la base (port 5432/6543), " +
           "bloquée sur ce réseau. Essayez depuis une autre connexion (ex. partage de connexion du téléphone).")
  }
} else {
  # Installation par l'accès web de Supabase (HTTPS), qui fonctionne même si
  # le réseau bloque la connexion directe à la base. Le registre des mises à
  # jour installées est celui de l'outil officiel (supabase_migrations).
  $tmp = Join-Path ([System.IO.Path]::GetTempPath()) 'ecoleplus-sql.sql'
  function ExecuterSql([string]$sql, [string]$Etiquette = 'préparation') {
    [System.IO.File]::WriteAllText($tmp, $sql, (New-Object System.Text.UTF8Encoding($false)))
    # Sortie complète (erreurs comprises) pour pouvoir la montrer en cas d'échec.
    $sortie = & npx --yes supabase@2.121.0 db query --linked -f $tmp --output-format json 2>&1
    $script:derniereReponse = ($sortie | ForEach-Object { "$_" }) -join "`n"
    if ($LASTEXITCODE -ne 0 -or $script:derniereReponse -match '"_tag"\s*:\s*"Error"') {
      ArretAvecReponse "Le serveur a refusé une partie de l'installation ($Etiquette)."
    }
  }
  ExecuterSql ("create schema if not exists supabase_migrations;`n" +
               "create table if not exists supabase_migrations.schema_migrations " +
               "(version text not null primary key, statements text[], name text);")
  $faites = @(SupabaseJson @('db', 'query', '--linked',
              'select version from supabase_migrations.schema_migrations')) |
            ForEach-Object { Champ $_ @('version') }
  $baseVide = ($faites.Count -eq 0)
  $migrations = Get-ChildItem (Join-Path $racine 'supabase\migrations') -Filter '*.sql' | Sort-Object Name
  foreach ($m in $migrations) {
    $version = $m.BaseName.Split('_')[0]
    if ($faites -contains $version) { continue }
    $nom = $m.BaseName.Substring($version.Length + 1)
    Write-Host "    Installation : $nom"
    $contenu = [System.IO.File]::ReadAllText($m.FullName)
    ExecuterSql ("begin;`n$contenu`n" +
                 "insert into supabase_migrations.schema_migrations (version, name) values ('$version', '$nom');`n" +
                 "commit;") $nom
  }
  if ($baseVide) {
    Write-Host '    Installation du jeu de données fictif « École Test »...'
    ExecuterSql ("begin;`n" + [System.IO.File]::ReadAllText((Join-Path $racine 'supabase\seed.sql')) + "`ncommit;") 'École Test'
  }
  Remove-Item -Force -ErrorAction SilentlyContinue $tmp
}
Ok 'tables à jour'
# Réglages de connexion (mot de passe de 8 caractères, durée de session...).
# L'offre gratuite refuse de modifier le modèle d'e-mail : on envoie alors
# une copie des réglages sans ce modèle (inutile ici, la récupération du mot
# de passe passant par la question secrète).
$dossierReglages = Join-Path ([System.IO.Path]::GetTempPath()) 'ecoleplus-reglages'
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $dossierReglages
$null = New-Item -ItemType Directory -Force (Join-Path $dossierReglages 'supabase')
$horsModele = $true
$lignesReglages = foreach ($l in [System.IO.File]::ReadAllLines((Join-Path $racine 'supabase\config.toml'))) {
  if ($l -match '^\s*\[') { $horsModele = ($l -notmatch '^\s*\[auth\.email\.template\.') }
  if ($horsModele) { $l }
}
[System.IO.File]::WriteAllLines((Join-Path $dossierReglages 'supabase\config.toml'), [string[]]$lignesReglages,
                                (New-Object System.Text.UTF8Encoding($false)))
try {
  Supabase @('config', 'push', '--project-ref', $config.ref, '--workdir', $dossierReglages, '--yes')
  Ok 'réglages de connexion appliqués'
}
catch { Write-Host '    (réglages de connexion non appliqués : sans gravité pour l''essai)' -ForegroundColor Yellow }
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $dossierReglages
Supabase @('functions', 'deploy', 'gerer-membres', 'recuperer-mot-de-passe', '--project-ref', $config.ref, '--use-api')
Ok 'fonctions serveur déployées'

# Fin de ligne Unix et sans BOM : sinon la clé lue par Flutter serait altérée.
[System.IO.File]::WriteAllText($fichierEnv, "SUPABASE_URL=$($config.url)`nSUPABASE_ANON_KEY=$($config.cle)`n")
if ($SansInstallation) { Ok 'serveur prêt (installation sur le portable non demandée)'; exit 0 }

# --------------------------------------------------------------------------
Etape 'Recherche du portable branché en USB'
& flutter pub get | Out-Null
$appareils = (& flutter devices --machine) -join "`n" | ConvertFrom-Json
$portable = @($appareils) | Where-Object { $_.targetPlatform -like 'android*' -and -not $_.emulator } | Select-Object -First 1
if (-not $portable) {
  $portable = @($appareils) | Where-Object { $_.targetPlatform -like 'android*' } | Select-Object -First 1
}
if (-not $portable) {
  Arret ("Aucun téléphone Android trouvé. Branchez le portable en USB, déverrouillez-le, " +
         "acceptez « Autoriser le débogage USB », puis relancez ce script.")
}
Ok "$($portable.name)"

Etape 'Construction et installation de EcolePlus sur le portable (5 à 10 minutes la 1re fois)'
& flutter run --release -d $portable.id --dart-define-from-file=$fichierEnv
# « flutter run » reste ouvert : tapez q pour quitter ; l'application reste installée.

Write-Host ''
Write-Host 'Comptes de test (mot de passe : motdepasse-test) :' -ForegroundColor Cyan
Write-Host '  directeur@ecole-test.local   enseignant1@ecole-test.local   secretaire@ecole-test.local'
Write-Host 'Suivez ensuite docs\TESTS_PHASE_1.md.'
