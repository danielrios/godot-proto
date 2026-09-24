#!/usr/bin/env bash
# Headless test gate. Runs the GUT suite with no window and exits non-zero on
# any failure — the single authoritative "is it green?" for this repo.
#
# Requires: Godot 4 on PATH (as `godot` or `godot4`) and the GUT addon at
# addons/gut/ (install once: see README).
set -euo pipefail
cd "$(dirname "$0")/.."

GODOT_BIN="${GODOT_BIN:-}"
if [[ -z "$GODOT_BIN" ]]; then
	if command -v godot >/dev/null 2>&1; then GODOT_BIN=godot
	elif command -v godot4 >/dev/null 2>&1; then GODOT_BIN=godot4
	else echo "ERROR: Godot 4 not found on PATH. Set GODOT_BIN." >&2; exit 127
	fi
fi

if [[ ! -d addons/gut ]]; then
	echo "ERROR: GUT addon missing at addons/gut/. See README 'Install GUT'." >&2
	exit 1
fi

# Reimport every run: GUT's class_names (GutTest, …) AND any project class_name
# (e.g. a newly added Countdown) must be registered before gut_cmdln.gd loads.
# A cached .godot/ does NOT pick up a brand-new class_name on its own, so guard-
# ing on "cache missing" intermittently fails the suite on machines that already
# ran the game. --import is idempotent and cheap once cached, so we always run it.
echo "[gate] importing project (registers GUT + project class_names)…"
"$GODOT_BIN" --headless --import >/dev/null 2>&1 || true

exec "$GODOT_BIN" --headless -s addons/gut/gut_cmdln.gd -gexit
