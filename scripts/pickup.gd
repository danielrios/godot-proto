extends Area2D
## Coin/pickup. Emits `collected` when the player enters, then removes itself.

signal collected(points: int)

@export var points: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		collected.emit(points)
		queue_free()
