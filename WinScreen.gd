extends CanvasLayer

@onready var retry_button = $Button
@onready var score_label = $ScoreLabel

func _ready():
	visible = false
	retry_button.pressed.connect(_on_retry_pressed)
	GameManager.level_complete.connect(_on_level_complete)

func _on_level_complete():
	visible = true
	score_label.text = "SCORE: " + str(GameManager.score)

func _on_retry_pressed():
	GameManager.score = 0
	GameManager.balls_remaining = 10
	GameManager.orange_pegs_hit = 0
	GameManager.current_state = GameManager.State.IDLE
	get_tree().change_scene_to_file("res://scenes/node_3d.tscn")
