extends GutTest
## Unit tests for GameState — the pure scoring/win rules.


func test_starts_empty() -> void:
	var s := GameState.new(3)
	assert_eq(s.score, 0)
	assert_eq(s.pickups_remaining, 3)
	assert_false(s.is_won())


func test_collect_increments_score_and_decrements_remaining() -> void:
	var s := GameState.new(2)
	var won := s.collect(5)
	assert_eq(s.score, 5)
	assert_eq(s.pickups_remaining, 1)
	assert_false(won)


func test_last_pickup_wins() -> void:
	var s := GameState.new(1)
	var won := s.collect()
	assert_true(won)
	assert_true(s.is_won())
	assert_eq(s.score, 1)


func test_remaining_never_goes_negative() -> void:
	var s := GameState.new(1)
	s.collect()
	s.collect()
	assert_eq(s.pickups_remaining, 0)
