"""Check docs/store/listing.md against Play's length limits.

Each language section has three `###` blocks in order: app name, short
description, full description. HTML comments are notes, not listing text.
"""
import re
import sys
from pathlib import Path

LIMITS = [("name", 30), ("short", 80), ("full", 4000)]

text = Path(__file__).with_name("listing.md").read_text(encoding="utf-8")
text = re.sub(r"<!--.*?-->", "", text, flags=re.S)

failed = False
for lang, body in re.findall(r"^## (\S+)\n(.*?)(?=^---$|\Z)", text, flags=re.S | re.M):
    blocks = [b.strip() for b in re.split(r"^### .*\n", body, flags=re.M)[1:]]
    if len(blocks) != 3:
        continue
    for (field, limit), block in zip(LIMITS, blocks):
        ok = len(block) <= limit
        failed |= not ok
        print(f"{lang:6} {field:5} {len(block):5} / {limit}  {'ok' if ok else 'TOO LONG'}")

sys.exit(1 if failed else 0)
