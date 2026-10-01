#!/usr/bin/env bash
# Fills the git-ignored assets/models with each model.json and its verified
# binaries from the docudis-ner revision pinned in tool/docudis_ner_version.json.
#
#   tool/fetch_models.sh                  # the shipped model, xlmr_ner_docudis
#   tool/fetch_models.sh xlmr_ner_hrl     # named models (the stock ones are for A/B benchmarks)
#   tool/fetch_models.sh --all
#
# Needs `pip install huggingface_hub`; xlmr_ner_docudis is a private repo, so run
# `huggingface-cli login` once. Set DOCUDIS_NER_SOURCE to use a local checkout
# at the pinned revision; PYTHON selects the interpreter (default python3).
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
version_file="$repo_root/tool/docudis_ner_version.json"
revision="$(sed -n 's/.*"revision": "\([^"]*\)".*/\1/p' "$version_file")"
repository="$(sed -n 's/.*"repository": "\([^"]*\)".*/\1/p' "$version_file")"

[[ "$revision" =~ ^[0-9a-f]{40}$ ]] || { echo "invalid NER revision" >&2; exit 1; }
[[ -n "$repository" ]] || { echo "missing NER repository" >&2; exit 1; }

if [[ -n "${DOCUDIS_NER_SOURCE:-}" ]]; then
  source_dir="$DOCUDIS_NER_SOURCE"
  actual="$(git -C "$source_dir" rev-parse HEAD)"
  [[ "$actual" == "$revision" ]] || {
    echo "DOCUDIS_NER_SOURCE is $actual, expected $revision" >&2
    exit 1
  }
else
  source_dir="$repo_root/build/docudis-ner-source/$revision"
  if [[ ! -d "$source_dir/.git" ]]; then
    mkdir -p "$source_dir"
    git -C "$source_dir" init -q
    git -C "$source_dir" remote add origin "$repository"
  fi
  git -C "$source_dir" fetch -q --depth 1 origin "$revision"
  git -C "$source_dir" checkout -q --detach FETCH_HEAD
fi

"${PYTHON:-python3}" "$source_dir/tool/fetch_models.py" --dest "$repo_root/assets/models" "$@"
