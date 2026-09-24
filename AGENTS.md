# AGENTS.md — godot-proto

Contract between agent sessions and this repo. Read this first.

## What this is
A small **Godot 4 / 2D** prototype. Player moves (WASD), collects pickups, wins
when all are collected. Built for an **agent-driven dev loop**: everything is
text, tests run headless, no GUI clicking required.

## Stack
- **Engine:** Godot 4.3+, GL Compatibility renderer (works headless/low-end).
- **Language:** GDScript. Package/`class_name` types: `GameState`, `Movement`, `Countdown`.
- **Layout:**
  - `scripts/` — GDScript. Pure logic (`game_state.gd`, `movement.gd`) is
	separated from node scripts (`player.gd`, `pickup.gd`, `main.gd`) so rules
	are unit-testable without the scene tree.
  - `scenes/` — `.tscn` (text, diffable): `main`, `player`, `pickup`.
  - `test/unit/` — GUT tests (`test_*.gd`).

## The test gate (authoritative)
A change is **done** only when the headless GUT suite is green. Reading the diff
is not evidence.

```bash
./scripts/run_tests.sh          # runs GUT headless, exits non-zero on failure
# or explicitly:
godot --headless -s addons/gut/gut_cmdln.gd -gexit
```

- Put game rules in the **pure** classes (`GameState`, `Movement`) and test them
  directly — no `InputEvent`, no frames, no physics.
- A green suite proves only what it exercises. Behavior that needs the real
  scene tree (signals firing, `body_entered`) needs an integration test that
  instances the scene, not a pure unit test.

## GUT (vendored)
GUT (Godot Unit Test) **v9.7.1 is committed** at `addons/gut/` — no install
step. The runner does a one-time headless `--import` on a fresh checkout (no
`.godot/` cache yet) so GUT's `class_name`s register before the suite loads.
To update GUT: replace `addons/gut/` from https://github.com/bitwes/Gut
(pick a Godot-4 release) and delete `.godot/` to force a re-import.

## Rules for agents
1. **Least power.** Solve with the simplest thing: a function before a node,
   a pure class before a scene. New rules go in `GameState`/`Movement` first.
2. **Text-only assets.** Keep scenes as `.tscn`. No binary resources that break
   diffs.
3. **Don't run the editor in foreground.** For a visual check, export/run
   headless or use a screenshot; the loop is edit → `run_tests.sh` → read → fix.
4. **State rule.** If it isn't committed or in the test suite, it doesn't exist.
5. **Never push to `main`/`master`.** Feature branches + PR.
