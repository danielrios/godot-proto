extends GutTest
## Unit tests for Countdown — the pure timer / game-over rule.

func test_starts_with_given_time() -> void:
	var c := Countdown.new(30.0)
	assert_eq(c.time_left, 30.0)
	assert_false(c.is_expired())

func test_tick_decrements_time() -> void:
	var c := Countdown.new(10.0)
	var over := c.tick(3.0)
	assert_almost_eq(c.time_left, 7.0, 0.001)
	assert_false(over)

func test_expires_exactly_once_on_crossing_zero() -> void:
	var c := Countdown.new(5.0)
	assert_false(c.tick(4.0))       # 1.0 left, not over
	assert_true(c.tick(2.0))        # crosses zero -> over (edge fires once)
	assert_true(c.is_expired())
	assert_false(c.tick(1.0))       # already expired -> no repeat fire

func test_time_never_goes_negative() -> void:
	var c := Countdown.new(2.0)
	c.tick(10.0)
	assert_eq(c.time_left, 0.0)
	assert_true(c.is_expired())

func test_display_seconds_ceils() -> void:
	var c := Countdown.new(3.4)
	assert_eq(c.display_seconds(), 4)
	c.tick(0.5)                     # 2.9 left
	assert_eq(c.display_seconds(), 3)

func test_zero_start_is_immediately_expired() -> void:
	var c := Countdown.new(0.0)
	assert_true(c.is_expired())
	assert_false(c.tick(1.0))
