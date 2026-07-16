# Parties en ligne — configuration Supabase

Pour que les **codes d'invitation** et la **recherche par pseudo** fonctionnent entre amis (Belgique, La Réunion, etc.), le jeu utilise un petit registre Supabase (gratuit).

## Étapes (une seule fois)

1. Créer un projet sur [supabase.com](https://supabase.com).
2. Exécuter le SQL dans `supabase/migrations/001_public_lobbies.sql` (SQL Editor).
3. Récupérer **Project URL** et **anon public key** (Settings → API).
4. Renseigner `resources/data/online_registry_config.tres` dans Godot :
   - `supabase_url` → `https://xxxxx.supabase.co`
   - `supabase_anon_key` → clé `anon`

## Flux joueur

| Rôle | Action |
|------|--------|
| **Hôte** | Héberger → copier le code `XXXX-XXXX` |
| **Ami** | Saisir le code → Rejoindre |
| **Ami** | Ou chercher le pseudo → sélectionner → Rejoindre |
| **Même Wi‑Fi** | Liste automatique (LAN), sans code |

La connexion jeu reste **P2P ENet** ; Supabase ne sert qu’à retrouver l’adresse de l’hôte.

## Secours

**Connexion manuelle (IP)** reste disponible en bas du lobby (debug / cas extrêmes).
