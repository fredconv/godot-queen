# UI — Dame de Pique

Documentation du design system et de l'intégration UI/UX du projet.

## Contenu

| Fichier | Rôle |
|---------|------|
| [DesignSystem.md](DesignSystem.md) | Analyse assets, thème retenu, architecture |
| [StyleGuide.md](StyleGuide.md) | Couleurs, typo, espacements, sprites |
| [Components.md](Components.md) | Composants réutilisables et scènes |
| [UX.md](UX.md) | Parcours joueur, ergonomie, accessibilité |

## Code associé

- `scripts/core/ui/ui_palette.gd` — couleurs partagées
- `scripts/core/ui/ui_bundle_catalog.gd` — chemins et régions UIBundleFree
- `scripts/core/ui/ui_style_factory.gd` — StyleBoxTexture depuis les slices
- `scripts/core/ui/ui_focus_nav.gd` — navigation clavier / manette
- `resources/themes/pixel_theme.tres` — thème de base (formulaires, overlays)
- `assets/sprites/ui/medieval/` — slices découpées (MediavelFree)

## Workflow

Voir la mission Lead UI/UX dans le fil de discussion — pour chaque écran : besoin UX → sprite existant → composant → thème → doc.
