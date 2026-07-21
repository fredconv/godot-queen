# UI — Royal Salon Professional Redesign

```
Version : V01
Created : 2026-07-21
Status : PROPOSED — awaiting user validation
Inbox : IDEA-00027
Reference : moodboard Royal Salon fourni le 2026-07-21
```

## 1. Intention

Le moodboard est une **cible de qualité et un langage visuel**, pas une sprite sheet à reproduire. Le chantier consolide l'UI existante en un système thémable, responsive et réutilisable, sans modifier les règles de Hearts, l'IA ni l'orchestration de partie.

Direction : feutrine émeraude, acajou sombre, fer foncé, or ancien, parchemin/ivoire, accents bordeaux/violet/cyan. Ornements mesurés ; la main, le pli et l'information de tour restent prioritaires.

## 2. État réel audité

### Entrée et architecture

- Scène de démarrage : `res://scenes/bootstrap/bootstrap.tscn`.
- Table : `res://scenes/table/table.tscn`.
- Renderer : GL Compatibility ; référence 1280×720, paysage mobile-first.
- Présentation isolée dans `scenes/`, `scripts/ui/` et `scripts/components/`.
- `MatchManager` reste lié à la table et n'est pas un Autoload.

### Fondations à conserver

| Fondation | Rôle |
|---|---|
| `pixel_theme.tres` | Theme projet et contrôles standards |
| `UiPalette` | couleurs partagées |
| `UiThemeCatalog` | enrichissement et variations du Theme |
| `UiStyleFactory` | styles procéduraux et textures existantes |
| `UiBundleCatalog` / `UiIconCatalog` | catalogue d'assets |
| `NinePatchButton` | bouton vivant menus/dialogues |
| `ModalOverlayScreen` | cycle open/close des modales |
| `UiFocusNav` / `UiOffsetAnim` | focus et micro-interactions |
| `ContextShellHost` / `ContextShellLayout` | relayout table, sidebar et barre basse |

### Composants réutilisables présents

- `button_template.tscn`, `top_menu_bar.tscn`, `player_seat.tscn`, `match_scoreboard.tscn`.
- `confirm_dialog.tscn`, `hand_end_dialog.tscn`, `match_end_dialog.tscn`.
- `reaction_picker.gd`, `reaction_bubble.gd`, `pixel_notification.gd`.
- `score_bar_row.gd`, `score_results_list.gd`, `card_view.tscn`.

### Dette visuelle observée

1. Trois sources de style coexistent : Theme central, `UiStyleFactory` et overrides locaux.
2. De nombreuses scènes répètent marges, couleurs, tailles de police et `StyleBoxFlat`.
3. La barre supérieure, les modales et les boutons n'utilisent pas encore une famille de matériaux commune.
4. Les panneaux restent souvent des rectangles anthracite bordés d'or, sans vraie profondeur 9-slice.
5. `NinePatchButton` est réutilisable mais sa structure icône/texte doit devenir un véritable conteneur, pas un placement latéral ad hoc.
6. Le responsive avancé existe surtout dans `ContextShellHost`; les menus et dialogues ont encore plusieurs dimensions locales.
7. `PixelButton` est legacy et ne doit pas revenir dans le pipeline.
8. La passe V1 d'icônes est un prototype utile ; elle devra être normalisée sur une grille commune Royal Salon.

## 3. Architecture cible proposée

L'existant est une source d'information, pas une contrainte de conservation. La cible remplace progressivement le système courant : **il ne restera pas deux pipelines UI permanents**. Pas de nouvel Autoload ; le Theme actif est appliqué à la racine UI et les composants héritent naturellement.

```text
resources/themes/
  royal_salon_theme.tres           # source de vérité finale du thème principal

resources/ui/royal_salon/
  royal_salon_layout_tokens.tres   # uniquement dimensions/breakpoints hors capacités Theme

assets/sprites/ui/royal_salon/
  panels/ buttons/ icons/ ornaments/ portraits/

scenes/components/ui/royal_salon/
  royal_button.tscn
  royal_panel.tscn
  royal_icon_button.tscn
  royal_player_panel.tscn
  royal_score_drawer.tscn
  royal_reaction_picker.tscn

scripts/core/ui/
  ui_theme_access.gd               # lecture du Theme pour custom drawing seulement
  ui_asset_catalog.gd              # atlas/régions, sans styles ni couleurs
```

Principes :

- Le `Theme` porte couleurs, polices, constantes, icônes et `StyleBox` communs et devient l'unique source de vérité visuelle.
- Les `theme_type_variation` expriment la sémantique : Primary, Secondary, Danger, Compact, Selected, Disabled, Drawer, PlayerActive, Tooltip.
- Les textures 9-slice vivent dans des assets séparés et documentés.
- Les scènes composent la mise en page avec des Containers ; aucune logique de gameplay dans les composants.
- Les overrides locaux ne restent que pour une exception réellement spécifique.
- Les thèmes futurs remplacent une ressource Theme et un jeu d'assets, sans réécrire les écrans.
- `pixel_theme.tres`, `UiPalette`, l'enrichissement procédural et les factories historiques sont supprimés à la fin de la migration quand leur graphe de références atteint zéro.

### 3.1 Tableau de décision des fondations

| Élément | Responsabilité actuelle | Problème réel / consommateurs | Décision | Responsabilité cible | Migration, tests et suppression |
|---|---|---|---|---|---|
| `UiPalette` | constantes couleurs + trois tailles de texte | Utilisé directement par ~25 scripts ; mélange tokens de thème, états de composants et typographie ; empêche le remplacement naturel d'un Theme | **Remplacer** | Couleurs/tailles dans `royal_salon_theme.tres`; accessor limité au custom drawing | Ajouter les Theme items, migrer par famille, tests de présence/contraste ; supprimer `ui_palette.gd` lorsque `rg UiPalette` = 0 |
| `UiThemeCatalog` | enrichit `pixel_theme.tres` en mémoire et crée les variations | Génère des `StyleBox` au runtime, dépend de `UiPalette` et `UiStyleFactory`, méta d'enrichissement cachée ; Theme disque ≠ Theme réellement joué | **Remplacer** | Theme `.tres` entièrement authored, variations visibles dans l'éditeur | Reproduire les variations dans le nouveau Theme, test de snapshot des types, retirer les appels `ensure_project_theme_enriched`, puis supprimer le script |
| `UiStyleFactory` | fabrique textures, boutons, panneaux plats et applique des overrides | Responsabilités multiples ; styles instanciés et overrides locaux ; dépend de catalogues legacy et de la palette | **Scinder puis supprimer** | Styles dans Theme ; un `UiAssetCatalog` pur peut fournir AtlasTexture/régions aux rares consommateurs | Extraire le chargement d'assets avec cache, migrer styles vers `.tres`, tests de régions et 9-slice ; supprimer factory et tests associés après zéro référence |
| `NinePatchButton` | bouton custom, sizing, états, chrome opaque, icône placée manuellement, animation | Très utilisé ; contourne Theme, crée ses StyleBox, mélange layout/skin/animation, icône hors HBox | **Remplacer progressivement** | `RoyalButton` générique : BaseButton + HBox icône/Label, variantes Theme, sizing par presets/layout tokens, animation séparée | Construire en slice, adaptateur temporaire API `set_button_text/icon`, migrer écran par écran, tests clavier/tactile/i18n ; supprimer template et classe historiques à zéro référence |
| `ContextShellHost` | slots sidebar/bottom bar + calcul/applique insets + placeholder peint | Bonne séparation du gameplay, mais mélange host/layout et chrome ; largeur/hauteur codées dans `ContextShellLayout` | **Conserver le comportement, refactoriser** | `GameShellLayout` gère uniquement géométrie/slots ; contenu et chrome sont des composants thémés ; breakpoints dans layout tokens | Tests géométriques existants étendus à toutes résolutions ; retirer `_paint_placeholder` et les références visuelles ; renommer seulement après migration sûre |
| Overrides locaux | styles, marges, couleurs et tailles dans scènes/scripts | Très nombreux dans menus, dialogues, HUD, scores et réactions ; variations visuelles difficiles à tracer | **Migrer puis interdire par défaut** | Variations Theme + constantes de Containers ; exceptions documentées pour état réellement dynamique | Inventaire automatisé par scène, budget d'overrides décroissant, test/lint `rg theme_override`; supprimer SubResources et code d'application devenus inutiles |
| `UiBundleCatalog`, `UiNinePatchCatalog`, `UiIconCatalog` | trois catalogues de chemins/régions | Sources fragmentées ; bundle legacy, patch et atlas V1 se chevauchent | **Fusionner** | `UiAssetCatalog` orienté assets, sans logique de style | Manifeste unique, vérification dimensions/régions/import ; supprimer catalogues après migration |
| `PixelButton` | ancien bouton pixel | Déjà archivé, sans consommateur live | **Supprimer** | aucun | Vérifier références/export, supprimer script et scène archivée dans le lot de nettoyage final |

### 3.2 Risque et stratégie de compatibilité

- Risque élevé : boutons et Theme, car ils touchent tous les menus et dialogues.
- Risque moyen : extraction des couleurs utilisées par custom drawing, réactions et feedback de cartes.
- Risque faible : suppression de `PixelButton` et catalogues sans consommateur après audit.
- Les adaptateurs sont explicitement temporaires, portent un commentaire `TODO(IDEA-00027): remove after migration`, une tâche Backlog et un test de non-régression.
- La sortie du chantier exige : zéro ancien écran, zéro double catalogue, zéro appel d'enrichissement procédural et zéro override historique non justifié.

### 3.3 Séquence de migration architecture

1. Cartographier automatiquement références et overrides ; figer les comptes de départ.
2. Créer le Theme authored et les layout tokens, sans modifier les écrans.
3. Construire les composants du vertical slice avec le nouveau pipeline uniquement.
4. Migrer la table pilote et valider comportement + rendu.
5. Migrer un premier écran menu complet ; confirmer que le Theme couvre les deux contextes.
6. Migrer par familles : menus, dialogues, feedback table, formulaires.
7. Faire décroître les adaptateurs et overrides à chaque lot.
8. Vérifier par recherche et dépendances qu'aucune scène n'utilise l'ancien pipeline.
9. Supprimer scripts, ressources, tests et assets obsolètes ; mettre à jour les tests vers la cible.
10. Audit final visuel, accessibilité, performance et documentation.

## 4. Backlog proposé

| Lot | Résultat | Dépend de | Risque principal | Validation |
|---|---|---|---|---|
| R0 | Audit figé, baseline et inventaire | — | oubli d'un état | docs + captures |
| R1 | Tokens, palette, grille 8 px, typographie | R0 | contraste | tests tokens + planche |
| R2 | `royal_salon_theme.tres` et variations | R1 | cascade Theme | scène laboratoire |
| R3 | Famille de boutons complète | R2 | focus/tactile | normal/hover/pressed/focus/disabled |
| R4 | Panneaux et cadres 9-slice | R2 | étirement pixel | 5 tailles testées |
| R5 | Famille d'icônes homogène | R1 | silhouettes incohérentes | atlas + inspection Nearest |
| R6 | Barre supérieure Royal Salon | R3–R5 | surcharge horizontale | 6 formats |
| R7 | Panneaux joueurs et avatars | R2, R4, R5 | cartes/sièges coupés | 4 sièges + états |
| R8 | Tiroir des scores contextuel | R4, R7 | recouvre la table | ouvert/fermé + relayout |
| R9 | Réactions | R3–R5 | débordement viewport | picker + bulle + cooldown |
| R10 | **Vertical slice table** | R3–R9 | intégration | gate complète |
| R11 | Menu d'accueil | R10 | concurrence avec splash | clavier/souris/tactile |
| R12 | Menus secondaires | R10 | textes traduits longs | FR/EN + formats |
| R13 | Dialogues et résultats | R10 | hiérarchie score | fin manche/partie/lune |
| R14 | Notifications, tooltips, chargement/erreur | R10 | bruit visuel | états clés |
| R15 | Responsive, plein écran, accessibilité | R11–R14 | dette layout | matrice résolutions |
| R16 | Cohérence, performance et migration finale | R15 | régression globale | audit final + tests |

Chaque lot demeure réversible et passe `PROPOSED → READY → IN_PROGRESS → TESTED → WAITING_USER_VALIDATION → DONE`.

## 5. Vertical slice Royal Salon

### Périmètre

Une table jouable pilote comprenant :

1. un bouton texte+icône et ses six états ;
2. la barre supérieure assemblée ;
3. un panneau joueur complet décliné sur quatre sièges ;
4. le tiroir des scores ouvert/fermé avec relayout réel ;
5. le sélecteur et une bulle de réaction ;
6. un panneau 9-slice redimensionnable ;
7. une petite famille d'icônes définitive.

### Fichiers candidats du slice

- `resources/themes/royal_salon_theme.tres` (nouveau)
- `resources/ui/royal_salon/royal_salon_tokens.tres` (seulement si les tokens hors Theme le justifient)
- `assets/sprites/ui/royal_salon/**` (nouveaux assets séparés)
- `scripts/core/ui/ui_palette.gd`
- `scripts/core/ui/ui_theme_catalog.gd`
- `scripts/core/ui/ui_icon_catalog.gd`
- `scenes/menus/button_template.tscn`
- `scripts/components/ui/nine_patch_button.gd`
- `scenes/components/top_menu_bar.tscn` et `scripts/components/top_menu_bar.gd`
- `scenes/components/player_seat.tscn` et `scripts/components/player_seat.gd`
- `scenes/components/match_scoreboard.tscn` et son script
- `scripts/reactions/reaction_picker.gd`, `reaction_bubble.gd`
- `scripts/ui/context_shell/context_shell_host.gd`, uniquement pour le skin et les insets nécessaires
- `scenes/table/table.tscn`, uniquement pour l'assemblage

### Hors scope du slice

- règles, IA, réseau, scoring et orchestration ;
- migration des menus ;
- changement du pack de cartes ;
- animations longues ou nouveaux effets gameplay ;
- nouveau gestionnaire global de thèmes.

## 6. Manifeste initial des assets

| Famille | Assets | Format cible | Notes |
|---|---|---|---|
| Matériaux | swatches feutre, bois, or, fer, parchemin | 16/32 px tileables | références, pas de grands fonds |
| Boutons | normal, hover, pressed, selected, disabled, focus | patch 32×32 ou atlas documenté | texte toujours dynamique |
| Panneaux | principal, secondaire, modal, drawer, player | 9-slice 48×48 ou 64×64 | marges inscrites au manifeste |
| Icônes | règles, scores, plis, shuffle, options, retour, chat, réactions, plein écran, audio, aide, humain, IA, dealer, couleurs | grille 24×24 ou 32×32 | même épaisseur visuelle |
| Ornements | séparateur, poignée drawer, coins, marqueur actif | PNG alpha | décor limité |
| Joueurs | anneau actif/inactif, couronne, dealer, gagnant pli | overlays alpha | avatars source conservés |
| Réactions | quatre émotions pilote + toggle chat | 32×32 | lisibles à 1× et 2× |

Pour chaque fichier : PNG alpha, Nearest, mipmaps off, lossless, dimensions et marges 9-slice documentées, prompt source archivé si généré.

## 7. Critères d'acceptation du slice

- Même langage visuel sur bouton, barre, panneau joueur, score et réaction.
- Aucune couleur ou marge globale recopiée dans plusieurs scripts.
- Focus clavier visible et distinct du hover ; état disabled lisible sans dépendre uniquement de la couleur.
- Cibles tactiles ≥ 44 px pour les actions principales du nouveau système.
- Main humaine, centre du pli et valeurs des cartes jamais masqués.
- Ouverture du score = insets et relayout, pas simple superposition.
- Pixels nets à toutes les échelles testées ; icônes centrées ; aucun clipping.
- Aucun changement de résultat gameplay ni de séquence de signaux.

## 8. Matrice de tests et captures

Résolutions minimales : 1280×720, 1920×1080, 1024×768/desktop étroit, 960×540, tablette paysage, mobile paysage, fenêtre redimensionnée, plein écran.

États obligatoires :

- table neutre et tour humain ;
- bouton normal/hover/pressed/focus/disabled/selected ;
- score fermé puis ouvert ;
- panneau réaction fermé/ouvert/cooldown + bulle ;
- joueur actif/inactif, humain/IA, donneur et gagnant de pli ;
- texte FR puis locale à libellés longs ;
- souris, clavier/manette et contrôle tactile simulé.

Tests :

- GdUnit sur tokens, régions atlas, marges 9-slice, variations et géométrie du relayout ;
- tests d'intégration existants menu/table ;
- gate MCP : reload, runtime, interactions, captures réellement inspectées, erreurs/warnings ;
- baseline : `.mcp_audit/royal_salon_baseline_main_menu.png` et `.mcp_audit/royal_salon_baseline_table.png`.

## 9. Definition of Done

Un lot n'est pas DONE parce qu'il compile. Il doit être testé, capturé, inspecté, comparé au moodboard, validé aux formats convenus, sans nouvelle erreur et avec documentation/Inbox mises à jour. La validation humaine reste requise après `WAITING_USER_VALIDATION`.

## 10. Décision demandée

Valider ou ajuster :

1. l'architecture minimale sans nouvel Autoload ;
2. le vertical slice table R1–R10 avant les menus ;
3. la grille d'icônes 24 ou 32 px ;
4. le niveau d'ornementation (recommandé : celui du moodboard, réduit d'environ 15 % sur la table) ;
5. les résolutions de la matrice.

Aucune migration générale ne commence avant cette validation.
