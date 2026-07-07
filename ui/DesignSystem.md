# Design System — Analyse initiale

Date : étape 8 (polish Play Store). Bundle : **UIBundleFree** (démos gratuites 256×256).

---

## 1. Contexte projet

| Contrainte | Impact UI |
|------------|-----------|
| Jeu de cartes 4 joueurs, paysage mobile | Table lisible, boutons larges, texte petit mais contrasté |
| GL Compatibility, pixel art ADR-008 | `default_texture_filter=Nearest`, pas de coins arrondis vectoriels |
| Press Start 2P | Titres courts ; libellés menu en MAJUSCULES |
| Tapis vert + barre bois | Thème **taverne médiévale** plutôt que cyber / horror |
| Cartes non pixel (pack actuel) | UI pixel + cartes lisses : acceptable en MVP ; pack cartes pixel = post-MVP |

---

## 2. Inventaire bundle UIBundleFree

| Feuille | Thème | Verdict |
|---------|-------|---------|
| **MediavelFree.png** | Bois, enseigne, boutons, icônes | **Principal** — menu, overlays, barre table |
| **freecasinoui.png** | Casino, néons, HIT/STAND | **Accents** — couronne vainqueur, cadres or |
| FreeUI.png | Violet / or, texte PLAY anglais | Référence coins ; fenêtres pré-texte **non utilisées** |
| FreeDemo.png | Bambou / forêt | Hors identité feutre vert |
| UiCozyFree, PastelUIFree | Doux / pastel | Secondaire (options futures) |
| FreeHorrorUi.png | Horreur | **Exclu** |
| freefantasy.png | Fantasy générique | Réserve |

### Assets existants projet

- `texture_tapis.jpg` — fond table / menu
- `8bit-color-retro-pixel-art-buttons-...png` — icônes rondes hamburger / réglages (barre table)
- Avatars joueurs — sièges table
- `pixel_theme.tres` — fallback formulaires (sliders, LineEdit)

---

## 3. Style dominant retenu

**« Taverne de cartes »** — médiéval bois + feutre vert + or (UiPalette).

- Panneau : enseigne suspendue (`panel_hanging`)
- Boutons menu : bois clair / pressé (`btn_light_*`)
- Overlays : panneau or existant → migration progressive vers coins bois
- Accent victoire : couronne casino (`casino_crown`)

---

## 4. Points forts actuels

- Architecture UI découplée (menus / table / overlays)
- Thème central + `UiPalette`
- Navigation clavier (`UiFocusNav`)
- Fond tapis + vignette menu
- i18n sur tous les écrans

## 5. Incohérences

- Cartes lissées vs UI pixel
- Barre table : mélange bois StyleBoxFlat + sprites 8bit
- Overlays encore panneau plat or (pas enseigne bois)
- Démos bundle : texte anglais incrusté sur certaines maquettes — **ne pas utiliser tels quels**
- Boutons bundle 16×16 étirés pour libellés longs — acceptable si marges 9-slice correctes

## 6. Ressources disponibles (slices)

Dossier `assets/sprites/ui/medieval/` :

| Fichier | Usage |
|---------|--------|
| `panel_hanging.png` | Décor menu principal |
| `btn_light_normal / pressed` | Boutons texte menu |
| `btn_dark_*` | Boutons secondaires / états |
| `icon_home, icon_gear, icon_check, icon_close` | Barre table, dialogs |
| `corner_*` | Futur NinePatch overlays |
| `progress_track.png` | Skin slider (à brancher) |

Dossier `assets/sprites/ui/casino/` : couronne, cadres (accents).

## 7. Ressources manquantes

- NinePatch panneau overlay complet (4 coins + bords + centre)
- États hover dédiés par sprite (modulate utilisé en interim)
- Curseur main pixel (optionnel)
- Icône app + splash Android
- Pack cartes pixel art (ADR-008 post-MVP)
- Animation bougies médiévales (décor table, optionnel)

## 8. Recommandations (priorité)

1. **Fait** — Menu principal : enseigne + boutons bois (`UiStyleFactory`)
2. **Suivant** — Overlays (config, scores, dialogs) : `medieval_panel` NinePatch
3. Barre table : remplacer texte par icônes bundle (home, gear) + tooltips i18n
4. Fin de partie : couronne casino sur vainqueur
5. Sliders config : texture `progress_track`
6. Ne pas mélanger plus de 2 thèmes bundle à l'écran

## 9. Architecture cible

```
scripts/core/ui/     → palette, catalog, factory, focus
assets/sprites/ui/   → slices exportées (source of truth visuelle)
resources/themes/    → pixel_theme.tres (+ variantes)
scenes/components/ui/ → composants réutilisables (à créer)
ui/                  → documentation
```

## 10. Décision

**Oui** — on pilote le design system avec **MediavelFree** + accents **freecasinoui**, en réutilisant le tapis et la palette or existants. Les autres feuilles demo restent en réserve documentée, pas dans le build actif.
