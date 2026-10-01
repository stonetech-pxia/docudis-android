#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
version_file="$repo_root/tool/docudis_ner_version.json"
revision="$(sed -n 's/.*"revision": "\([^"]*\)".*/\1/p' "$version_file")"
expected_wordpiece="$(sed -n 's/.*"wordpiece_sha256": "\([^"]*\)".*/\1/p' "$version_file")"

source_dir="${DOCUDIS_NER_SOURCE:-}"
[[ -n "$source_dir" ]] || {
  echo "set DOCUDIS_NER_SOURCE to the pinned NER checkout" >&2
  exit 2
}
[[ "$(git -C "$source_dir" rev-parse HEAD)" == "$revision" ]] || {
  echo "NER checkout does not match pinned revision $revision" >&2
  exit 1
}

actual_wordpiece="$(shasum -a 256 "$source_dir/testdata/tokenizers/wordpiece.json" | awk '{print $1}')"
[[ "$actual_wordpiece" == "$expected_wordpiece" ]] || { echo "pinned tokenizer digest mismatch" >&2; exit 1; }

cmp "$source_dir/testdata/tokenizers/wordpiece.json" \
  "$repo_root/packages/docudis_engine/testdata/tokenizers/wordpiece.json"
cmp "$source_dir/models/distilbert_ner_hrl/model.json" \
  "$repo_root/packages/docudis_engine/testdata/models/distilbert_ner_hrl/model.json"
