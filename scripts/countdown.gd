class_name Countdown
extends RefCounted
## Pure countdown timer — no Node, no engine clock. The scene feeds it elapsed
## deltas so the game-over rule is unit-tested without instancing the tree.

var time_left: float
var _expired: bool = false

func _init(seconds: float = 30.0) -> void:
	time_left = maxf(0.0, seconds)
	_expired = time_left == 0.0

## Advance the clock by `delta` seconds. Returns true ONLY on the tick that
## crosses zero (edge, not level) so the caller fires game-over exactly once.
func tick(delta: float) -> bool:
	if _expired:
		return false
	time_left = maxf(0.0, time_left - maxf(0.0, delta))
	if time_left == 0.0:
		_expired = true
		return true
	return false

func is_expired() -> bool:
	return _expired

## Whole seconds remaining, for HUD display (ceil so "1" shows until true 0).
func display_seconds() -> int:
	return int(ceil(time_left))
