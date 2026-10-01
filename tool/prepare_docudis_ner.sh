#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 debug|release OUTPUT_JNI_LIBS_DIR" >&2
  exit 2
fi

profile="$1"
output="$2"
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
    git -C "$source_dir" init
    git -C "$source_dir" remote add origin "$repository"
  fi
  git -C "$source_dir" fetch --depth 1 origin "$revision"
  git -C "$source_dir" checkout --detach FETCH_HEAD
fi

DOCUDIS_ANDROID_ABIS="${DOCUDIS_ANDROID_ABIS:-arm64-v8a,armeabi-v7a,x86_64}" \
  "$source_dir/scripts/build-android.sh" "$profile"

mkdir -p "$output"
rsync -a "$source_dir/dist/android/$profile/jniLibs/" "$output/"
