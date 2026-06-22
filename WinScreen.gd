# WinScreen.gd
extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var retry_button = $RetryButton
@onready var next_button = $NextButton

func _ready():
	visible = false
	retry_button.pressed.connect(_on_retry_pressed)
	next_button.pressed.connect(_on_next_pressed)
	GameManager.level_complete.connect(_on_level_complete)

func _on_level_complete():
	visible = true
	score_label.text = "SCORE: " + str(GameManager.score)
	# Hide Next Level button if we're on the last level
	next_button.visible = GameManager.current_level < GameManager.MAX_LEVEL

func _on_retry_pressed():
	GameManager.reset_for_level()
	get_tree().change_scene_to_file("res://scenes/node_3d.tscn")

func _on_next_pressed():
	GameManager.current_level += 1
	GameManager.reset_for_level()
	get_tree().change_scene_to_file("res://scenes/node_3d.tscn")
