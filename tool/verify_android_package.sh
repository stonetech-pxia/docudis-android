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

for abi in "$@"; do
  if ! grep -Eq "^(base/)?lib/$abi/libdocudis_capi[.]so$" <<< "$entries"; then
    echo "$package does not contain libdocudis_capi.so for $abi" >&2
    exit 1
  fi
done
