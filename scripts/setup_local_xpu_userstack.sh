#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_DIR=$(cd -- "$SCRIPT_DIR/.." && pwd)
STACK_DIR="$REPO_DIR/.cache/intel-userstack"
DEB_DIR="$STACK_DIR/debs"
ROOT_DIR="$STACK_DIR/root"

mkdir -p "$DEB_DIR" "$ROOT_DIR"

urls=(
  "https://github.com/intel/intel-graphics-compiler/releases/download/v2.36.3/intel-igc-core-2_2.36.3+21719_amd64.deb"
  "https://github.com/intel/intel-graphics-compiler/releases/download/v2.36.3/intel-igc-opencl-2_2.36.3+21719_amd64.deb"
  "https://github.com/intel/compute-runtime/releases/download/26.22.38646.4/intel-ocloc_26.22.38646.4-0_amd64.deb"
  "https://github.com/intel/compute-runtime/releases/download/26.22.38646.4/intel-opencl-icd_26.22.38646.4-0_amd64.deb"
  "https://github.com/intel/compute-runtime/releases/download/26.22.38646.4/libigdgmm12_22.10.0_amd64.deb"
  "https://github.com/intel/compute-runtime/releases/download/26.22.38646.4/libze-intel-gpu1_26.22.38646.4-0_amd64.deb"
  "https://ppa.launchpadcontent.net/kobuk-team/intel-graphics/ubuntu/pool/main/l/level-zero-loader/libze1_1.28.6-1~25.10~ppa1_amd64.deb"
)

for url in "${urls[@]}"; do
  file="$DEB_DIR/${url##*/}"
  if [[ ! -f "$file" ]]; then
    wget -q -O "$file.tmp" "$url" && mv "$file.tmp" "$file"
  fi
done

if [[ ! -x "$ROOT_DIR/usr/bin/ocloc" ]]; then
  rm -rf "$ROOT_DIR"
  mkdir -p "$ROOT_DIR"
  for deb in "$DEB_DIR"/*.deb; do
    dpkg-deb -x "$deb" "$ROOT_DIR"
  done
fi

printf '%s\n' "$ROOT_DIR"
