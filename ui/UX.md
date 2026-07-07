# UX — Principes Dame de Pique

## Objectifs joueur

1. Lancer une partie en **1 clic** depuis le menu
2. Comprendre **à qui le tour** et **les scores** sans quitter la table
3. Configurer volume / langue **sans perdre la partie**
4. Quitter avec **confirmation** si partie en cours

## Parcours principaux

### Premier lancement
Pseudo → menu → nouvelle partie. Pas de skip pseudo (multijoueur futur).

### Partie
Table → jouer cartes (main bas) → popups fin de manche → fin partie → rejouer ou menu.

### Hors partie
Menu → scores / config / crédits → retour (Échap ou RETOUR).

## Hiérarchie visuelle (table)

1. Main du joueur (bas)
2. Carte en cours / pli central
3. Indicateur tour (`TurnLabel`)
4. Scores (`ScoreLabel`, scoreboard)
5. Barre menu (actions rares)

## Accessibilité

- Focus visible (bordure or / violette)
- Navigation clavier : menus verticaux, barre table horizontale
- Échap = fermer overlay / annuler dialog
- Entrée = valider (profil, fin de manche)
- Contraste crème/or sur fond sombre ou bois

## Mobile

- Boutons ≥ 36px hauteur
- Pas de hover obligatoire (états pressed/focus suffisants)
- Safe area : marges table déjà ancrées (ADR-006)

## Charge cognitive

- Pas plus de 5 entrées menu principal
- Dialogs : 1 message + 2 boutons max
- Pas d'animation bloquante > 2s sans skip (pli : déjà géré)

## Métriques qualité (étape 8)

- [ ] Menu identifiable en < 1s
- [ ] Toutes les actions menu atteignables au clavier
- [ ] Même langage visuel menu ↔ overlays (en cours)
- [ ] Feedback sonore sur clic (AudioService)
