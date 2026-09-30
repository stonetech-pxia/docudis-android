"""Render the Docudis app icon (concept A, see concept-a-page.svg) to PNGs.

Run from the repo root, with $PYTHON pointing at a Python that has Pillow:
"$PYTHON" design/logo/render_icons.py
The Android adaptive icon is a vector drawable and is edited by hand.
"""
import re
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
TERRACOTTA = "#C8623A"
PAGE = "#FFFCF8"
LINE = "#E3D6C7"
INK = "#2A2420"
SS = 4  # supersampling factor


def render(size, corner_radius=0.0):
    """Full-bleed icon on a 1024 grid; corner_radius (fraction of size) rounds the tile."""
    n = 1024 * SS
    s = lambda v: round(v * SS)
    img = Image.new("RGB", (n, n), TERRACOTTA)
    d = ImageDraw.Draw(img)

    # Page: radius 56 on three corners, 20 bottom-left (Clay icon-block shape).
    box = (s(292), s(232), s(732), s(792))
    mask = Image.new("L", (n, n), 0)
    m = ImageDraw.Draw(mask)
    m.rounded_rectangle(box, radius=s(56), fill=255, corners=(True, True, True, False))
    m.rectangle((s(292), s(700), s(400), s(792)), fill=0)
    m.rounded_rectangle((s(292), s(600), s(500), s(792)), radius=s(20), fill=255,
                        corners=(False, False, False, True))
    img.paste(PAGE, mask=mask)

    for x1, y, x2 in [(372, 340, 652), (372, 444, 440), (372, 548, 652), (372, 652, 548)]:
        d.rounded_rectangle((s(x1 - 20), s(y - 20), s(x2 + 20), s(y + 20)), radius=s(20), fill=LINE)
    d.rounded_rectangle((s(480), s(412), s(652), s(476)), radius=s(16), fill=INK)

    img = img.resize((size, size), Image.LANCZOS)
    if not corner_radius:
        return img
    tile = Image.new("L", (size * SS, size * SS), 0)
    ImageDraw.Draw(tile).rounded_rectangle((0, 0, size * SS - 1, size * SS - 1),
                                           radius=corner_radius * size * SS, fill=255)
    out = img.convert("RGBA")
    out.putalpha(tile.resize((size, size), Image.LANCZOS))
    return out


def main():
    logo = ROOT / "design" / "logo"
    render(1024).save(logo / "docudis-icon-1024.png")
    render(512).save(logo / "docudis-icon-512-play-store.png")

    res = ROOT / "android" / "app" / "src" / "main" / "res"
    for density, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        render(px, corner_radius=0.18).save(res / f"mipmap-{density}" / "ic_launcher.png")

    # iOS: full-bleed, no alpha (the system applies the mask).
    appicon = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    for f in appicon.glob("Icon-App-*.png"):
        w, scale = re.match(r"Icon-App-([\d.]+)x[\d.]+@(\d)x\.png", f.name).groups()
        render(round(float(w) * int(scale))).save(f)


if __name__ == "__main__":
    main()
