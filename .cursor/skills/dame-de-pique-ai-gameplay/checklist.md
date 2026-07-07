# Checklist — modification IA Dame de pique

## Analyse (avant code)

- [ ] La règle est-elle **faisabilité** (MoonFeasibility), **décision** (AdaptiveAiStrategy) ou **UI** ?
- [ ] Impact sur les 3 modes MINIMIZE / CHASE_MOON / BREAK_MOON ?
- [ ] Faut-il un nouveau message ? Si oui : respecte-t-il « pas de tactique explicite » + limite 1/manche ?
- [ ] Faut-il une clé i18n dans `translations/` (6 langues) ?

## Implémentation

- [ ] Logique pure sans nœud Godot dans `scripts/ai/` (sauf `AiPlayer`)
- [ ] Contexte enrichi via `MatchManager.build_ai_context` si nouveau champ
- [ ] Pas de `print()` — `DebugService`
- [ ] Identifiants code en anglais, commentaires FR

## Validation

- [ ] Tests unitaires IA / Lune passent (GdUnit4)
- [ ] Si seuils modifiés : simulation 1000 parties
- [ ] `LocaleAware` + `_refresh_locale()` dans les dialogs si nouveau libellé bouton

## Messages — revue rapide

- [ ] Pas « je vise la Lune » / « je casse la Lune »
- [ ] `suspect_moon` = observation (« pense que … vise la Lune »)
- [ ] Pas d'annonce par pli
