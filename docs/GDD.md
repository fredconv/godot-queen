# GDD — Dame de Pique (Hearts)

## Pitch

Jeu de cartes « Dame de Pique » (variante française du jeu Hearts), jouable en solo contre 3 IA dans une première version, avec table locale (hot-seat) envisageable plus tard.

## Règles du jeu (rappel)

- **Joueurs** : 4 joueurs, chacun reçoit 13 cartes (jeu de 52 cartes, sans jokers).
- **Objectif** : terminer la partie avec le **moins de points possible**. La partie s'arrête quand un joueur atteint un score seuil (classiquement 100 points).
- **Distribution** : 13 cartes par joueur. Selon la variante, une phase de passe de cartes (3 cartes) peut précéder chaque manche (rotation gauche / droite / en face / pas de passe).
- **Déroulement d'un pli (trick)** :
  - Le joueur possédant le 2 de trèfle entame le premier pli.
  - Chaque joueur doit suivre la couleur demandée s'il le peut.
  - Le pli est remporté par la carte la plus forte de la couleur demandée.
  - Le vainqueur du pli entame le pli suivant.
- **Contraintes spécifiques** (implémentées dans `scripts/rules/`, voir `docs/DECISIONS.md` ADR-016 pour le détail des choix de variante) :
  - Le 2 de Trèfle doit obligatoirement entamer le tout premier pli d'une manche (joué immédiatement s'il est en main du joueur qui entame).
  - On ne peut pas entamer un pli avec un Cœur tant que les Cœurs n'ont pas été « défoncés » (joué par un Cœur **ou** la Dame de Pique), sauf si le joueur n'a que des Cœurs en main.
  - Aucune carte à points (Cœur ou Dame de Pique) ne peut être jouée au tout premier pli — ni pour l'entamer, ni en défausse — sauf si le joueur n'a plus que des cartes à points en main (Cœurs et/ou Dame de Pique).
- **Score par manche** :
  - Chaque Cœur remporté vaut **1 point**.
  - La Dame de Pique vaut **13 points**.
  - **Réussite totale (« Shooting the Moon »)** : un joueur qui remporte tous les Cœurs ET la Dame de Pique dans une même manche marque **0 point**, et tous les autres joueurs marquent **26 points**.
- **Fin de partie** : la partie se termine dès qu'un joueur atteint (ou dépasse) le score seuil ; le vainqueur est celui qui a le score total le plus bas.

## Portée du MVP

- 1 joueur humain + 3 IA (difficulté simple, pas de triche/anticipation avancée).
- Table unique, pas de multijoueur en ligne.
- Manche complète jouable de bout en bout : distribution → passe (optionnelle) → plis → score → manche suivante → fin de partie.
- UI minimale mais claire : main du joueur, table centrale, scores, indication du joueur actif.
- Pas de progression/méta-jeu (succès, monnaie, cosmétiques) en MVP.
- Pas de son/musique final en MVP (structure prête via `AudioService`, mais pas d'assets requis).

## Hors scope (MVP)

- Multijoueur réseau.
- Personnalisation avancée (thèmes de cartes, avatars).
- IA avancée avec apprentissage.
- Statistiques persistantes détaillées (au-delà d'une sauvegarde basique).

## Plateformes cibles

- Godot 4.7, rendu **GL Compatibility** (compatibilité large, y compris machines modestes).
- PC (Windows) en priorité pour le développement ; portage éventuel plus tard.
- Cible **mobile first**, orientation **paysage** en priorité (portrait envisagé plus tard si l'ergonomie le permet).

## UI/UX — table de jeu (aperçu)

Disposition cible de la table de jeu, à 4 joueurs :

- **Table** : fond feutre vert, occupant tout l'écran.
- **Barre de menu** (haut, style bois) : bouton menu hamburger, boutons AIDE et SCORES à gauche, informations dynamiques au centre (tour en cours, résumé des scores), boutons NOUVEAU, MENU et réglages (roue crantée) à droite.
- **Sièges joueurs** (haut, gauche, droite, bas) : avatar (placeholder), nom, score entre parenthèses, indicateur de pénalité cœur. Le joueur humain ("Vous") occupe le siège du bas.
- **Mains adverses** : affichées face cachée avec le dos de carte **rouge** (`card_back_red`), jamais la face des cartes adverses.
- **Main du joueur** : affichée en éventail, face visible, en bas de l'écran.
- **Zone de pli** : centrale, disposition en croix (une carte par direction : haut/bas/gauche/droite), un emplacement par siège.

Cette disposition est un objectif de rendu ; l'implémentation détaillée (arborescence de scène, composants) est documentée dans `docs/TECHNICAL_DESIGN.md`.

## Identité visuelle

Direction artistique cible pour l'habillage graphique (chrome UI en priorité, cartes potentiellement plus tard — voir `docs/DECISIONS.md`, ADR-008) :

- **Pixel art** : esthétique rétro à pixels nets (barre de menu, boutons, panneaux, menu de réglages orné), inspirée de références utilisateur (cartes pixel art, table de jeu pixel art, menu de réglages pixel art).
- **Coloré** : palette vive et contrastée (feutre vert vif, boutons or/jaune, accents bleu/jaune), pas de tons délavés ou pastel.
- **Clarté** : priorité absolue à la lisibilité mobile — rangs et couleurs de carte identifiables au premier coup d'œil, textes UI à fort contraste, surbrillance de sélection de carte explicite (coins en crochet bleu/jaune sur la carte sélectionnée, façon référence utilisateur).
- **Dos de carte** : reste `card_back_red` (voir ADR-005), inchangé par cette direction artistique.
- **Cartes (recto)** : le pack actuel (`kerenel_Cards_seperated`) n'est pas dessiné en pixel art ; il est conservé pour le MVP le temps que le chrome UI pixel art se mette en place. Un remplacement par un pack de cartes pixel art est envisageable dans une itération ultérieure, à condition de ne pas sacrifier la clarté des rangs/couleurs (voir « Pipeline art » dans `docs/TECHNICAL_DESIGN.md`).

Détails techniques (filtrage de texture, thème, police, palette précise) dans `docs/TECHNICAL_DESIGN.md`.
