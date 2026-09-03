# features/branding/presentation

Dossier intentionnellement sans écran dédié : l'affichage du nom/logo de
l'atelier est appliqué directement dans `EcranAccueilProvisoire`
(`features/auth/presentation/`), et le bouton d'export PDF directement dans
`EcranFicheClient` (`features/clients/presentation/`) — la logique de
composition (téléchargement du logo, génération du PDF) reste dans
`features/branding/data/`, seule sa présentation est répartie là où elle
est utilisée plutôt que dans un écran à part entière.
