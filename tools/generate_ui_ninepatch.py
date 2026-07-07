#!/usr/bin/env python3
"""Génère les textures NinePatch 32×32 (marges 8 px) à partir des planches médiévales."""
from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MEDIEVAL = ROOT / "assets" / "sprites" / "ui" / "medieval"
SHEET = ROOT / "assets" / "sprites" / "UIBundleFree" / "MediavelFree.png"
NINEPATCH = ROOT / "assets" / "sprites" / "ui" / "ninepatch"

SIZE = 32
MARGIN = 8


def _blit_region(target: Image.Image, source: Image.Image, tx: int, ty: int, sx: int, sy: int, w: int, h: int) -> None:
    region = source.crop((sx, sy, sx + w, sy + h))
    if region.size != (w, h):
        region = region.resize((w, h), Image.NEAREST)
    target.paste(region, (tx, ty))


def build_button_ninepatch(plank: Image.Image) -> Image.Image:
    pw, ph = plank.size
    left_end = 8
    right_start = pw - 8
    center_w = right_start - left_end

    out = Image.new("RGBA", (SIZE, SIZE))

    # Coins
    _blit_region(out, plank, 0, 0, 0, 0, MARGIN, MARGIN)
    _blit_region(out, plank, SIZE - MARGIN, 0, right_start, 0, MARGIN, MARGIN)
    _blit_region(out, plank, 0, SIZE - MARGIN, 0, ph - MARGIN, MARGIN, MARGIN)
    _blit_region(out, plank, SIZE - MARGIN, SIZE - MARGIN, right_start, ph - MARGIN, MARGIN, MARGIN)

    # Bords haut / bas (centre répété)
    for x in range(MARGIN, SIZE - MARGIN):
        src_x = left_end + ((x - MARGIN) % max(1, center_w))
        _blit_region(out, plank, x, 0, src_x, 0, 1, MARGIN)
        _blit_region(out, plank, x, SIZE - MARGIN, src_x, ph - MARGIN, 1, MARGIN)

    # Bords gauche / droite (milieu vertical)
    mid_y = max(0, ph // 2 - MARGIN // 2)
    for y in range(MARGIN, SIZE - MARGIN):
        src_y = mid_y + ((y - MARGIN) % max(1, ph - MARGIN * 2))
        _blit_region(out, plank, 0, y, 0, src_y, MARGIN, 1)
        _blit_region(out, plank, SIZE - MARGIN, y, right_start, src_y, MARGIN, 1)

    # Centre
    for y in range(MARGIN, SIZE - MARGIN):
        src_y = mid_y + ((y - MARGIN) % max(1, ph - MARGIN * 2))
        for x in range(MARGIN, SIZE - MARGIN):
            src_x = left_end + ((x - MARGIN) % max(1, center_w))
            _blit_region(out, plank, x, y, src_x, src_y, 1, 1)

    return out


def export_panel_sign_only() -> None:
    sheet = Image.open(SHEET)
    sign = sheet.crop((2, 1, 74, 92))
    sign.save(MEDIEVAL / "panel_hanging.png")
    print(f"panel_hanging.png -> {sign.size}")


def export_ninepatch_buttons() -> None:
    NINEPATCH.mkdir(parents=True, exist_ok=True)
    for name, src in (
        ("btn_wood_32.png", "btn_plank_normal.png"),
        ("btn_wood_32_pressed.png", "btn_plank_pressed.png"),
    ):
        plank = Image.open(MEDIEVAL / src)
        patch = build_button_ninepatch(plank)
        patch.save(NINEPATCH / name)
        print(f"{name} -> {patch.size}")


if __name__ == "__main__":
    export_panel_sign_only()
    export_ninepatch_buttons()
