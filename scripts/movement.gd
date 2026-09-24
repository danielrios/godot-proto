class_name Movement
extends RefCounted
## Pure movement math — no Node, no physics, no frames.
## Kept separate from Player so it is unit-testable headless.
## This is the "least powerful tool" seam: game rules live here as plain
## functions the test runner can drive directly.

## Returns a normalized direction vector from the four move actions.
## `pressed` maps action name -> bool, so tests inject input without an
## InputEvent or a running tree.
static func direction(pressed: Dictionary) -> Vector2:
	var v := Vector2(
		float(pressed.get("move_right", false)) - float(pressed.get("move_left", false)),
		float(pressed.get("move_down", false)) - float(pressed.get("move_up", false)),
	)
	return v.normalized() if v.length() > 0.0 else Vector2.ZERO


## New position after moving `speed` px/s for `delta` seconds in `dir`.
static func step(pos: Vector2, dir: Vector2, speed: float, delta: float) -> Vector2:
	return pos + dir * speed * delta


## Clamp a position inside a rectangular play area (inclusive bounds).
static func clamp_to(pos: Vector2, rect: Rect2) -> Vector2:
	return Vector2(
		clampf(pos.x, rect.position.x, rect.position.x + rect.size.x),
		clampf(pos.y, rect.position.y, rect.position.y + rect.size.y),
	)
