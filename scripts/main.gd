extends Node2D
## Main scene controller. Owns the GameState and a Countdown, wires each
## Pickup's signal to the state, updates the HUD, and ends the game on either
## outcome: all pickups collected (win) or the timer reaching zero (game over).

const START_SECONDS := 30.0

@onready var _label: Label = $HUD/ScoreLabel
@onready var _time_label: Label = $HUD/TimeLabel
@onready var _end_panel: Panel = $HUD/EndPanel
@onready var _end_label: Label = $HUD/EndPanel/EndLabel

var _state: GameState
var _timer: Countdown
var _over: bool = false

func _ready() -> void:
	var pickups := get_tree().get_nodes_in_group("pickup")
	_state = GameState.new(pickups.size())
	_timer = Countdown.new(START_SECONDS)
	for p in pickups:
		if p.has_signal("collected"):
			p.collected.connect(_on_collected)
	_refresh()

func _process(delta: float) -> void:
	if _over:
		if _wants_restart():
			get_tree().reload_current_scene()
		return
	if _timer.tick(delta):
		_end_game(false)  # timer hit zero -> game over
		return
	_refresh_time()

## Restart is offered only after the game is over. Split from the reload effect
## so the decision is testable without tearing down the scene tree. Level-based
## (is_action_pressed) not edge: the scene reloads immediately, so there is no
## repeat-fire to guard, and level state is deterministic to test headless.
func _wants_restart() -> bool:
	return _over and Input.is_action_pressed("restart")

func _on_collected(points: int) -> void:
	if _over:
		return
	var won := _state.collect(points)
	_refresh()
	if won:
		_end_game(true)

func _end_game(won: bool) -> void:
	_over = true
	_refresh_time()  # land on "Time: 0" rather than freezing on the last tick
	if won:
		_label.text = "You win!  Score: %d" % _state.score
		_end_label.text = "You win!  Score: %d" % _state.score
	else:
		_label.text = "Game Over  Score: %d" % _state.score
		_end_label.text = "Game Over  Score: %d" % _state.score
	_end_panel.visible = true

func _refresh() -> void:
	if not _state.is_won():
		_label.text = "Score: %d   Left: %d" % [_state.score, _state.pickups_remaining]
	_refresh_time()

func _refresh_time() -> void:
	if _time_label:
		_time_label.text = "Time: %d" % _timer.display_seconds()
