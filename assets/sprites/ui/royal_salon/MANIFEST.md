# Royal Salon — asset manifest

Generated for IDEA-00027. Pixel UI uses Nearest filtering, lossless import and no mipmaps.

| Asset | Source crop | 9-slice margins | Use |
|---|---:|---:|---|
| `button_normal_v1.png` | 98×100 | 12 all | default button |
| `button_hover_v1.png` | 104×100 | 12 all | pointer hover |
| `button_pressed_v1.png` | 98×100 | 12 all | pressed |
| `button_selected_v1.png` | 101×100 | 12 all | focus/selected |
| `button_disabled_v1.png` | 99×100 | 12 all | disabled |
| `panel_main_v1.png` | 284×203 | 16 / 39 / 16 / 14 | modal and principal panel |
| `panel_player_v1.png` | 268×122 | 24 / 17 / 24 / 14 | player panel pilot |
| `panel_score_v1.png` | 340×121 | 24 / 16 / 24 / 15 | score drawer/banner |
| `panel_compact_v1.png` | 222×63 | 24 / 12 / 24 / 12 | toolbar/notification |
| `drawer_handle_v1.png` | 80×27 | — | drawer handle |
| `table_background_v1.png` | 1672×941 | — | first unified table plate, retained as source iteration |
| `table_background_v2.png` | 1672×941 | — | active empty table plate: wood frame, emerald felt, right score rail |

`royal_components_chroma_v1.png` is the generated chroma source. `royal_components_v1.png` is the transparent master. Crops are reproducible with `tools/crop_royal_components.py`.

Prompt source: see `docs/ui/ROYAL_SALON_REDESIGN_BRIEF.md`. Generated with the built-in image tool using the supplied moodboard as a style/quality reference, then chroma-keyed locally.

The table plate was generated separately with the built-in image tool from the three supplied quality/composition references. Production constraints were: background only, straight-on 16:9 composition, uninterrupted felt, no cards, avatars, controls, panels or text. `table_background_v2.png` is the cleaned edit with all generated center slots removed so the responsive Godot nodes remain the single source of truth.
