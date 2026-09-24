extends GutTest
## Unit tests for Movement — pure direction/step/clamp math.


func test_no_input_is_zero() -> void:
	assert_eq(Movement.direction({}), Vector2.ZERO)


func test_right_is_unit_x() -> void:
	assert_eq(Movement.direction({"move_right": true}), Vector2.RIGHT)


func test_diagonal_is_normalized() -> void:
	var d := Movement.direction({"move_right": true, "move_down": true})
	assert_almost_eq(d.length(), 1.0, 0.0001)


func test_opposite_keys_cancel() -> void:
	assert_eq(Movement.direction({"move_left": true, "move_right": true}), Vector2.ZERO)


func test_step_advances_by_speed_times_delta() -> void:
	var p := Movement.step(Vector2.ZERO, Vector2.RIGHT, 100.0, 0.5)
	assert_almost_eq(p.x, 50.0, 0.0001)


func test_clamp_keeps_inside_rect() -> void:
	var rect := Rect2(0, 0, 100, 100)
	assert_eq(Movement.clamp_to(Vector2(-10, 200), rect), Vector2(0, 100))
