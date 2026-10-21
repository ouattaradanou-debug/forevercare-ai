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

$ErrorActionPreference = 'Stop'
$racine = Split-Path -Parent $PSScriptRoot          # dossier ecoleplus
Set-Location $racine
$fichierConfig = Join-Path $racine '.serveur-test.json'
$fichierEnv = Join-Path $racine 'telephone.env'

function Etape($texte) { Write-Host ''; Write-Host "==> $texte" -ForegroundColor Cyan }
function Ok($texte) { Write-Host "    OK : $texte" -ForegroundColor Green }
function Arret($texte) { Write-Host ''; Write-Host "ARRÊT : $texte" -ForegroundColor Red; exit 1 }

function Supabase {
  # CLI Supabase à version fixe (téléchargée automatiquement par npx).
  & npx --yes supabase@2.121.0 @args
  if ($LASTEXITCODE -ne 0) { throw "La commande « supabase $($args -join ' ') » a échoué." }
}

function SupabaseJson {
  $sortie = & npx --yes supabase@2.121.0 @args -o json 2>$null
  if ($LASTEXITCODE -ne 0) { throw "La commande « supabase $($args -join ' ') » a échoué." }
  return ($sortie -join "`n") | ConvertFrom-Json
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
  & npx --yes supabase@2.121.0 logout --yes *> $null
  # Oublie le serveur de test enregistré pour l'ancien compte (sur ce PC
  # seulement : rien n'est supprimé chez Supabase).
  Remove-Item -Force -ErrorAction SilentlyContinue $fichierConfig, $fichierEnv
  Write-Host '    Dans le navigateur, connectez-vous avec le NOUVEAU compte Supabase'
  Write-Host '    (déconnectez-vous d''abord de l''ancien sur supabase.com, ou utilisez une fenêtre de navigation privée).'
  Ok 'ancien compte oublié sur ce PC'
}

Etape 'Connexion à votre compte Supabase'
& npx --yes supabase@2.121.0 projects list *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Host '    Une page va s''ouvrir dans le navigateur : connectez-vous à Supabase et autorisez la CLI.'
  Supabase login
}
Ok 'connecté'

# --------------------------------------------------------------------------
if (Test-Path $fichierConfig) {
  $config = Get-Content $fichierConfig -Raw | ConvertFrom-Json
  Ok "serveur de test déjà créé (projet $($config.ref))"
  $nouveau = $false
} else {
  Etape 'Création du serveur de test « ecoleplus-test » (offre gratuite)'
  $orgs = @(SupabaseJson orgs list)
  if ($orgs.Count -eq 0) { Arret 'Aucune organisation Supabase sur ce compte.' }
  $org = $orgs[0]
  Write-Host "    Organisation : $($org.name)"
  # Mot de passe de la base, long et aléatoire, gardé sur ce PC seulement.
  $octets = New-Object byte[] 24
  [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($octets)
  $motDePasse = ([Convert]::ToBase64String($octets) -replace '[+/=]', 'x')
  try {
    Supabase projects create ecoleplus-test --org-id $org.id --db-password $motDePasse --region $Region --size micro
  } catch {
    Arret ("Création impossible. L'offre gratuite permet 2 projets actifs : si Atelier Plus et un autre " +
           "projet existent déjà, mettez-en un en pause sur supabase.com puis relancez ce script.")
  }
  $projet = @(SupabaseJson projects list) | Where-Object { $_.name -eq 'ecoleplus-test' } | Select-Object -First 1
  $ref = if ($projet.ref) { $projet.ref } else { $projet.id }
  $config = [pscustomobject]@{ ref = $ref; motDePasse = $motDePasse; url = "https://$ref.supabase.co"; cle = '' }
  $config | ConvertTo-Json | Set-Content $fichierConfig -Encoding UTF8
  Ok "projet créé : $ref"
  $nouveau = $true

  Write-Host '    Préparation du serveur par Supabase (2 à 5 minutes)...'
  for ($i = 0; $i -lt 60; $i++) {
    $etat = (@(SupabaseJson projects list) | Where-Object { $_.name -eq 'ecoleplus-test' } | Select-Object -First 1).status
    if ($etat -eq 'ACTIVE_HEALTHY') { break }
    Start-Sleep -Seconds 10
  }
  Ok 'serveur prêt'
}

if (-not $config.cle) {
  $cles = @(SupabaseJson projects api-keys --project-ref $config.ref)
  $anon = $cles | Where-Object { $_.name -eq 'anon' } | Select-Object -First 1
  if (-not $anon) { $anon = $cles | Where-Object { $_.type -eq 'publishable' } | Select-Object -First 1 }
  $config.cle = $anon.api_key
  $config | ConvertTo-Json | Set-Content $fichierConfig -Encoding UTF8
}

# --------------------------------------------------------------------------
Etape 'Mise à jour du serveur de test'
$env:SUPABASE_DB_PASSWORD = $config.motDePasse
Supabase link --project-ref $config.ref -p $config.motDePasse
if ($nouveau -or $Reinitialiser) {
  Write-Host '    Installation de toutes les tables et du jeu « École Test »...'
  Supabase db reset --linked --yes
} else {
  Supabase db push --linked -p $config.motDePasse
}
Ok 'tables à jour'
try { Supabase config push --project-ref $config.ref --yes; Ok 'réglages de connexion appliqués' }
catch { Write-Host '    (réglages de connexion non appliqués : sans gravité pour l''essai)' -ForegroundColor Yellow }
Supabase functions deploy gerer-membres recuperer-mot-de-passe --project-ref $config.ref --use-api
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
