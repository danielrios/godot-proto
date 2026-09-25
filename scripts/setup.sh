#!/usr/bin/env bash
# Fetch the pinned GUT testing addon into addons/gut.
# GUT's upstream repo is a full Godot project with the addon nested at
# addons/gut/addons/gut, so we download the tag tarball and extract only
# that addon. addons/gut is gitignored; this script is the single source
# of truth for the dependency version.
set -euo pipefail

GUT_VERSION="9.6.1"
GUT_TARBALL="https://github.com/bitwes/Gut/archive/refs/tags/v${GUT_VERSION}.tar.gz"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${ROOT}/addons/gut"

# Idempotent: skip if the pinned version is already present.
if [[ -f "${DEST}/plugin.cfg" ]] && grep -q "version=\"${GUT_VERSION}\"" "${DEST}/plugin.cfg"; then
  echo "GUT ${GUT_VERSION} already present in addons/gut — nothing to do."
  exit 0
fi

echo "Fetching GUT ${GUT_VERSION}..."
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

curl -fsSL "${GUT_TARBALL}" -o "${TMP}/gut.tar.gz"
tar -xzf "${TMP}/gut.tar.gz" -C "${TMP}"

# Tarball extracts to Gut-<version>/; the addon lives at addons/gut inside it.
SRC="${TMP}/Gut-${GUT_VERSION}/addons/gut"
if [[ ! -f "${SRC}/plugin.cfg" ]]; then
  echo "ERROR: addon not found at ${SRC} — GUT layout may have changed." >&2
  exit 1
fi

rm -rf "${DEST}"
mkdir -p "${ROOT}/addons"
cp -r "${SRC}" "${DEST}"

echo "GUT ${GUT_VERSION} installed to addons/gut."
