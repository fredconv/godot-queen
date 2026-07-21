from pathlib import Path

from PIL import Image


SOURCE = Path("assets/sprites/ui/royal_salon/royal_components_v1.png")
OUTPUT = SOURCE.parent
REGIONS = {
    "button_normal_v1.png": (45, 112, 242, 313),
    "button_hover_v1.png": (286, 112, 494, 313),
    "button_pressed_v1.png": (529, 112, 725, 313),
    "button_selected_v1.png": (765, 112, 968, 313),
    "button_disabled_v1.png": (1009, 112, 1207, 313),
    "panel_main_v1.png": (40, 383, 608, 790),
    "panel_player_v1.png": (670, 545, 1206, 790),
    "panel_score_v1.png": (36, 906, 716, 1149),
    "panel_compact_v1.png": (770, 934, 1214, 1061),
    "drawer_handle_v1.png": (884, 1082, 1044, 1136),
}


def main() -> None:
    source = Image.open(SOURCE)
    for filename, box in REGIONS.items():
        crop = source.crop(box)
        crop = crop.resize((crop.width // 2, crop.height // 2), Image.Resampling.NEAREST)
        crop.save(OUTPUT / filename)


if __name__ == "__main__":
    main()
