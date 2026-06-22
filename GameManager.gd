# GameManager.gd
extends Node

# --- Signals ---
signal score_changed(new_score: int)
signal balls_changed(new_count: int)
signal level_complete
signal game_over

# --- Game State ---
enum State { IDLE, AIMING, BALL_IN_PLAY, LEVEL_COMPLETE, GAME_OVER }
var current_state: State = State.IDLE

# --- Score ---
var score: int = 0
var multiplier: int = 1

# --- Balls ---
var balls_remaining: int = 10

# --- Pegs ---
var total_orange_pegs: int = 0
var orange_pegs_hit: int = 0

# --- Level ---
const MAX_LEVEL: int = 3
var current_level: int = 1

func _ready():
	# total_orange_pegs is set by PegSpawner after it finishes spawning
	balls_changed.emit(balls_remaining)

func add_score(base_points: int):
	score += base_points * multiplier
	score_changed.emit(score)

func on_peg_hit(peg_type: String):
	match peg_type:
		"orange":
			orange_pegs_hit += 1
			add_score(100)
			if orange_pegs_hit >= total_orange_pegs:
				level_complete.emit()
				current_state = State.LEVEL_COMPLETE
		"blue":
			add_score(10)
		"green":
			add_score(25)
			# green special ability hook - add later

func on_ball_caught():
	balls_remaining += 1
	balls_changed.emit(balls_remaining)
	score += 2000
	score_changed.emit(score)
	print("Free ball awarded! Balls remaining: ", balls_remaining)

func on_ball_launched():
	current_state = State.BALL_IN_PLAY

func on_ball_lost():
	balls_remaining -= 1
	balls_changed.emit(balls_remaining)

func reset_for_level():
	score = 0
	balls_remaining = 10
	orange_pegs_hit = 0
	total_orange_pegs = 0
	current_state = State.IDLE

func _process(_delta):
	if balls_remaining <= 0 and current_state != State.GAME_OVER and current_state != State.LEVEL_COMPLETE:
		current_state = State.GAME_OVER
		game_over.emit()
