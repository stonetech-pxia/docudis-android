"""Copy the store graphics rendered by test/store/ into upload-ready files.

Play rejects screenshots and feature graphics with an alpha channel, and the
Flutter goldens are RGBA, so each image is flattened to RGB here.

Run from the repo root after `flutter test --update-goldens test/store`, with
$PYTHON pointing at a Python that has Pillow:
"$PYTHON" design/store/export_play_assets.py
"""
import shutil
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
GOLDENS = ROOT / "test" / "goldens" / "store"
OUT = ROOT / "design" / "store" / "play"


def main():
    for lang_dir in sorted(p for p in GOLDENS.iterdir() if p.is_dir()):
        out = OUT / lang_dir.name
        out.mkdir(parents=True, exist_ok=True)
        for png in sorted(lang_dir.glob("*.png")):
            Image.open(png).convert("RGB").save(out / png.name, optimize=True)
            print(out / png.name)
    icon = OUT / "icon-512.png"
    shutil.copyfile(ROOT / "design" / "logo" / "docudis-icon-512-play-store.png", icon)
    print(icon)


if __name__ == "__main__":
    main()
