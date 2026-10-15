# data/sync

Couche de synchronisation bidirectionnelle Drift ↔ Supabase : file d'attente
des opérations en attente, déclenchement automatique via `connectivity_plus`,
résolution de conflit par horodatage (`updated_at`) avec journalisation dans
`journal_actions`.

Implémenté en Phase 3.
