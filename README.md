# godot-proto

A tiny **Godot 4 / 2D** prototype built for a fully **agent-driven, text-first
dev loop** — every asset is a diffable text file, tests run headless from the
CLI, and no GUI clicking is required to build or verify the game.

Move with **WASD**, collect the three coins before the timer runs out. Win by
collecting all three; lose if the countdown hits zero. Either way an end screen
appears — press **R** or **Space** to play again.

## Why this exists
It's a minimal, reproducible example of a game project structured so an AI agent
(or any CI system) can develop and verify it without a human in the loop:

- **Pure game logic** (`GameState`, `Movement`, `Countdown`) is separated from
  Godot nodes, so the rules are unit-testable headless — no `InputEvent`, no
  frames, no physics.
- **Scenes are text** (`.tscn`), so every change is a readable diff.
- A single **authoritative gate** (`scripts/run_tests.sh`) runs lint, format
  check, and the full test suite headless and exits non-zero on any failure.

## Requirements
- **Godot 4.3+** (`godot` or `godot4` on your `PATH`). Verified on 4.7.2.
- **GUT** (Godot Unit Test) is fetched (pinned v9.6.1) by `scripts/setup.sh` —
  not vendored. `run_tests.sh` runs it automatically if `addons/gut/` is missing.
- Optional: **[gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit)**
  (`gdlint` / `gdformat`) for the lint/format gate — `pipx install gdtoolkit`.
  The gate skips lint gracefully if it isn't installed.

## First-time setup
```bash
./scripts/setup.sh    # fetches the pinned GUT addon into addons/gut/
```
Idempotent, and also run on demand by the gate. The GUT version is pinned in
`scripts/setup.sh`.

## Run the game
```bash
godot --path . scenes/main.tscn      # windowed
# or open project.godot in the Godot editor and press F5
```

## Run the gate (headless)
```bash
./scripts/run_tests.sh
```
This reimports the project, runs `gdlint` + `gdformat --check` (if installed),
then the full GUT suite. It exits non-zero on any failure — the project's single
source of truth for "is it green?".

## Install Godot 4 (Linux)
Godot is a single self-contained binary — no system install needed.
```bash
# grab the latest 4.x "Linux x86_64" build from
# https://godotengine.org/download/linux/
unzip Godot_v4.*_linux.x86_64.zip
sudo mv Godot_v4.*_linux.x86_64 /usr/local/bin/godot
godot --version
```
Or via a package manager: `flatpak install flathub org.godotengine.Godot`.

## Layout
```
project.godot              engine config, input map (WASD + restart), main scene
scenes/                    main.tscn, player.tscn, pickup.tscn  (text, diffable)
scripts/
  game_state.gd            pure: score / win accounting        (no Node)
  movement.gd              pure: input -> direction / clamp     (no Node)
  countdown.gd             pure: timer / game-over rule         (no Node)
  player.gd, pickup.gd     node scripts (input, collision, signals)
  main.gd                  scene controller: wiring, HUD, end screen, restart
  run_tests.sh             headless gate (lint + format + tests)
test/unit/                 GUT tests for the pure logic
test/integration/          GUT tests that instance the real scene tree
AGENTS.md                  contract for agent / CI sessions
```

## Contributing / agent sessions
See [AGENTS.md](AGENTS.md) for the working contract: pure-logic-first design,
the headless test gate as the authority, and text-only assets.

## License
[MIT](LICENSE). GUT (fetched into `addons/gut/`) is also MIT.
