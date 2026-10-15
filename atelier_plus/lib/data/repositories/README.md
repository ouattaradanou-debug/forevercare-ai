# data/repositories

Repositories exposant une API unique aux features, masquant si la donnée
vient du cache local (Drift) ou du réseau (Supabase) : écriture toujours en
local d'abord, lecture prioritairement locale, synchronisation en tâche de
fond.

Introduit à partir de la Phase 1.
