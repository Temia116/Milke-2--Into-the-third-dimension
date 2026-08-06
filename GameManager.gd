# GameManager.gd
extends Node

# --- Signals ---
signal score_changed(new_score: int)
signal balls_changed(new_count: int)
signal level_complete
signal game_over
signal threshold_bonus_ball  # emitted when a score threshold is crossed

# --- Game State ---
enum State { IDLE, AIMING, BALL_IN_PLAY, LEVEL_COMPLETE, GAME_OVER }
var current_state: State = State.IDLE

# --- Score ---
var score: int = 0
var multiplier: int = 1          # resets to 1 at the start of each shot

# --- Balls ---
var balls_remaining: int = 10

# --- Pegs ---
var total_orange_pegs: int = 0
var orange_pegs_hit: int = 0

# --- Level ---
const MAX_LEVEL: int = 3
var current_level: int = 1

# --- Cow Roster ---
signal cow_ability_activated
var selected_cow: String = "none"
var cow_ability_used: bool = false
var ability_score_multiplier: int = 1  # used by economy-based abilities like Moolinda

# Which cow is active on which level. Level 1 is the tutorial level - no ability.
const LEVEL_COWS = {
	1: "none",
	2: "bessie",
	3: "moolinda",
}

func get_cow_for_level(level: int) -> String:
	return LEVEL_COWS.get(level, "none")

func activate_cow_ability() -> bool:
	if cow_ability_used or selected_cow == "none":
		return false
	cow_ability_used = true
	cow_ability_activated.emit()
	return true

func reset_shot_multipliers():
	# Call this once a ball's shot has fully resolved (ball_exited)
	ability_score_multiplier = 1

# --- Score Threshold Bonus ---
const THRESHOLD_START: int = 5000
const THRESHOLD_STEP: int = 7000
var next_threshold: int = THRESHOLD_START

# --- Minimum score required to win a level, even with all oranges cleared ---
const MIN_SCORE_TO_WIN: int = THRESHOLD_START

# --- Base point values (bumped up so thresholds are reachable) ---
const BLUE_POINTS: int = 50
const ORANGE_POINTS: int = 300
const GREEN_POINTS: int = 150

func _ready():
	balls_changed.emit(balls_remaining)

func add_score(base_points: int):
	score += base_points * multiplier * ability_score_multiplier
	score_changed.emit(score)
	_check_threshold_bonus()

func _check_threshold_bonus():
	while score >= next_threshold:
		_award_threshold_bonus()
		next_threshold += THRESHOLD_STEP

func _award_threshold_bonus():
	balls_remaining += 1
	balls_changed.emit(balls_remaining)
	threshold_bonus_ball.emit()
	print("Score threshold reached! Free ball awarded. Next threshold: ", next_threshold + THRESHOLD_STEP)

func on_peg_hit(peg_type: String):
	match peg_type:
		"orange":
			orange_pegs_hit += 1
			add_score(ORANGE_POINTS)
			# Milk Peg multiplier stack (GDD 3.2):
			# 1st orange this shot -> x2, 2nd -> x3, 3rd+ -> +1 each
			if multiplier == 1:
				multiplier = 2
			else:
				multiplier += 1
			if orange_pegs_hit >= total_orange_pegs:
				if score >= MIN_SCORE_TO_WIN:
					level_complete.emit()
					current_state = State.LEVEL_COMPLETE
				else:
					current_state = State.GAME_OVER
					game_over.emit()
		"blue":
			add_score(BLUE_POINTS)
		"green":
			add_score(GREEN_POINTS)
			# green special ability hook - add later

func on_shot_fired():
	# Call this when a new ball is launched so the multiplier resets per shot
	multiplier = 1

func on_ball_caught():
	balls_remaining += 1
	balls_changed.emit(balls_remaining)
	score += 2000
	score_changed.emit(score)
	_check_threshold_bonus()
	print("Free ball awarded! Balls remaining: ", balls_remaining)

func on_ball_launched():
	current_state = State.BALL_IN_PLAY
	on_shot_fired()

func on_ball_lost():
	balls_remaining -= 1
	balls_changed.emit(balls_remaining)

func reset_for_level():
	score = 0
	balls_remaining = 10
	orange_pegs_hit = 0
	total_orange_pegs = 0
	current_state = State.IDLE
	next_threshold = THRESHOLD_START
	multiplier = 1
	cow_ability_used = false
	ability_score_multiplier = 1
	selected_cow = get_cow_for_level(current_level)

func _process(_delta):
	if balls_remaining <= 0 and current_state != State.GAME_OVER and current_state != State.LEVEL_COMPLETE:
		current_state = State.GAME_OVER
		game_over.emit()
