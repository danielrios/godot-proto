extends CharacterBody2D
## Player: reads input, delegates the math to Movement (pure), moves.

@export var speed: float = 140.0


func _physics_process(_delta: float) -> void:
	var pressed := {
		"move_left": Input.is_action_pressed("move_left"),
		"move_right": Input.is_action_pressed("move_right"),
		"move_up": Input.is_action_pressed("move_up"),
		"move_down": Input.is_action_pressed("move_down"),
	}
	var dir := Movement.direction(pressed)
	velocity = dir * speed
	move_and_slide()
