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


func test_end_panel_shown_with_message_on_game_over() -> void:
	# The end-of-game panel is hidden during play and appears on game over,
	# carrying the outcome + restart prompt.
	var panel: Panel = _main.get_node("HUD/EndPanel")
	assert_false(panel.visible, "end panel hidden during play")
	_main._timer.time_left = 0.05
	for _i in 10:
		if _main._over:
			break
		await get_tree().process_frame
	assert_true(panel.visible, "end panel shown on game over")
	var end_label: Label = _main.get_node("HUD/EndPanel/EndLabel")
	assert_string_contains(end_label.text, "Game Over", "end panel states the outcome")


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


func test_restart_only_offered_after_game_over() -> void:
	# Assert the restart DECISION (_wants_restart), not the reload effect. We
	# disable the node's live _process first, otherwise its own loop would call
	# the real get_tree().reload_current_scene() (which errors / tears down the
	# GUT runner, since _main is an added child, not the current_scene). The
	# true live scene reload is covered by the playtest-pilot runtime check.
	_main.set_process(false)

	Input.action_press("restart")
	await get_tree().process_frame
	assert_false(_main._wants_restart(), "restart ignored while the game is live")
	Input.action_release("restart")

	# Force game-over state directly (process is off, so drive the flag).
	_main._end_game(false)
	assert_true(_main._over, "game over state set")

	Input.action_press("restart")
	await get_tree().process_frame
	assert_true(_main._wants_restart(), "restart accepted once the game is over")
	Input.action_release("restart")
