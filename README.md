# godot-proto

A tiny **Godot 4 / 2D** prototype, scaffolded for an agent-driven dev loop.
Move with **WASD**, collect the three coins, win.

## Requirements
- **Godot 4.3+** (`godot` or `godot4` on PATH). Verified on 4.7.2.
- **GUT** is already vendored at `addons/gut/` (v9.7.1) — nothing to install.

## Run the game
```bash
godot --path . scenes/main.tscn      # windowed
# or just open project.godot in the Godot editor and press F5
```

## Run the tests (headless)
```bash
./scripts/run_tests.sh
```
Exits non-zero on any failure. This is the project's authoritative gate.

## Install Godot 4 (Linux)
Godot is a single self-contained binary — no system install needed.
```bash
cd ~/Downloads
# grab the latest 4.x "Linux x86_64" build from https://godotengine.org/download/linux/
unzip Godot_v4.*_linux.x86_64.zip
sudo mv Godot_v4.*_linux.x86_64 /usr/local/bin/godot
godot --version
```
Or via package manager: `flatpak install flathub org.godotengine.Godot`.

## Layout
```
project.godot        engine config, input map (WASD), main scene
scenes/              main.tscn, player.tscn, pickup.tscn  (text, diffable)
scripts/             game_state.gd, movement.gd (pure) + node scripts
test/unit/           GUT tests for the pure logic
scripts/run_tests.sh headless test gate
AGENTS.md            contract for agent sessions
```
