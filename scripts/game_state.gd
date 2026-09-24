class_name GameState
extends RefCounted
## Pure game state — score and pickup accounting. No Node.
## Player/pickup scenes call into this so win/score rules are unit-tested
## without instancing the scene tree.

var score: int = 0
var pickups_remaining: int


func _init(total_pickups: int = 0) -> void:
	pickups_remaining = total_pickups


## Register one pickup collected. Returns true if that was the last one (win).
func collect(points: int = 1) -> bool:
	score += points
	pickups_remaining = maxi(0, pickups_remaining - 1)
	return pickups_remaining == 0


func is_won() -> bool:
	return pickups_remaining == 0
