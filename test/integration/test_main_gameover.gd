extends GutTest
## Integration test: instances the REAL main.tscn and drives its controller.
## This is the test that catches a scene regression the pure tests cannot —
## e.g. main.gd detached from the root node (the whole feature dead on load),
## or broken pickup instancing. Signal/scene-tree behavior per AGENTS.md.

const MAIN := preload("res://scenes/main.tscn")

var _main: Node2D

func before_each() -> void:
	_main = MAIN.instantiate()
	add_child_autofree(_main)
	await get_tree().process_frame  # let _ready run

func test_main_scene_has_controller_script_attached() -> void:
	# Guards the exact regression the reviewer caught: a resave dropping the
	# root script silently kills every _ready/_process/_on_collected.
	assert_not_null(_main.get_script(), "Main root must have main.gd attached")
	assert_true(_main.has_method("_on_collected"), "controller wiring present")

func test_three_pickups_instanced_in_group() -> void:
	var pickups := _main.get_tree().get_nodes_in_group("pickup")
	assert_eq(pickups.size(), 3, "all three pickups instanced and grouped")

func test_hud_shows_time_and_score_at_start() -> void:
	var score: Label = _main.get_node("HUD/ScoreLabel")
	var time: Label = _main.get_node("HUD/TimeLabel")
	assert_string_contains(score.text, "Score: 0")
	assert_string_contains(time.text, "Time:")

func test_timer_expiry_drives_game_over_label() -> void:
	# Drive the controller's own countdown to zero, proving the timer ->
	# _end_game(false) -> HUD path runs end to end. Step several frames so the
	# crossing lands regardless of per-frame delta size.
	_main._timer.time_left = 0.05
	for _i in 10:
		if _main._over:
			break
		await get_tree().process_frame
	var score: Label = _main.get_node("HUD/ScoreLabel")
	assert_string_contains(score.text, "Game Over", "timer expiry sets Game Over")
	assert_true(_main._over, "game marked over")

func test_no_collection_after_game_over() -> void:
	_main._timer.time_left = 0.05
	for _i in 10:
		if _main._over:
			break
		await get_tree().process_frame
	assert_true(_main._over)
	# A late collect must be ignored once the game is over.
	_main._on_collected(1)
	var score: Label = _main.get_node("HUD/ScoreLabel")
	assert_string_contains(score.text, "Game Over", "no scoring after game over")
