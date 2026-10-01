#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $0 APK_OR_AAB ABI [ABI ...]" >&2
  exit 2
fi

package="$1"
shift
[[ -s "$package" ]] || { echo "missing package: $package" >&2; exit 1; }
entries="$(unzip -Z1 "$package")"

# Core, the NER inference library, and the ONNX Runtime it loads by name.
for abi in "$@"; do
  for library in libdocudis_capi libdocudis_ner_capi libonnxruntime; do
    if ! grep -Eq "^(base/)?lib/$abi/$library[.]so$" <<< "$entries"; then
      echo "$package does not contain $library.so for $abi" >&2
      exit 1
    fi
  done
done
