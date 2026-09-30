#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
version_file="$repo_root/tool/docudis_core_version.json"
revision="$(sed -n 's/.*"revision": "\([^"]*\)".*/\1/p' "$version_file")"
expected_rules="$(sed -n 's/.*"rules_sha256": "\([^"]*\)".*/\1/p' "$version_file")"
expected_lists="$(sed -n 's/.*"lists_sha256": "\([^"]*\)".*/\1/p' "$version_file")"
expected_fixtures="$(sed -n 's/.*"fixtures_sha256": "\([^"]*\)".*/\1/p' "$version_file")"
expected_wordpiece="$(sed -n 's/.*"wordpiece_sha256": "\([^"]*\)".*/\1/p' "$version_file")"

source_dir="${DOCUDIS_CORE_SOURCE:-}"
[[ -n "$source_dir" ]] || {
  echo "set DOCUDIS_CORE_SOURCE to the pinned Core checkout" >&2
  exit 2
}
[[ "$(git -C "$source_dir" rev-parse HEAD)" == "$revision" ]] || {
  echo "Core checkout does not match pinned revision $revision" >&2
  exit 1
}

digest_dir() {
  local directory="$1"
  (cd "$directory" && find . -maxdepth 1 -type f -name '*.json' -print0 | \
    sort -z | xargs -0 shasum -a 256 | shasum -a 256 | awk '{print $1}')
}

actual_rules="$(digest_dir "$source_dir/data/rules")"
actual_lists="$(digest_dir "$source_dir/data/lists")"
actual_fixtures="$(digest_dir "$source_dir/conformance/fixtures/v1")"
actual_wordpiece="$(shasum -a 256 "$source_dir/testdata/tokenizers/wordpiece.json" | awk '{print $1}')"
[[ "$actual_rules" == "$expected_rules" ]] || { echo "pinned rule digest mismatch" >&2; exit 1; }
[[ "$actual_lists" == "$expected_lists" ]] || { echo "pinned list digest mismatch" >&2; exit 1; }
[[ "$actual_fixtures" == "$expected_fixtures" ]] || { echo "pinned fixture digest mismatch" >&2; exit 1; }
[[ "$actual_wordpiece" == "$expected_wordpiece" ]] || { echo "pinned tokenizer digest mismatch" >&2; exit 1; }

diff -ru "$source_dir/data/rules" "$repo_root/packages/docudis_engine/rules"
diff -ru "$source_dir/data/lists" "$repo_root/packages/docudis_engine/lists"
diff -ru "$source_dir/conformance/fixtures/v1" "$repo_root/packages/docudis_engine/testdata/core-v1"
cmp "$source_dir/testdata/tokenizers/wordpiece.json" \
  "$repo_root/packages/docudis_engine/testdata/tokenizers/wordpiece.json"
