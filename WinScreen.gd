# WinScreen.gd
extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var retry_button = $RetryButton
@onready var next_button = $NextButton
@onready var video = $VideoStreamPlayer

func _ready():
	visible = false
	retry_button.pressed.connect(_on_retry_pressed)
	next_button.pressed.connect(_on_next_pressed)
	GameManager.level_complete.connect(_on_level_complete)

func _on_level_complete():
	visible = true
	score_label.text = "SCORE: " + str(GameManager.score)
	next_button.visible = GameManager.current_level < GameManager.MAX_LEVEL
	get_tree().paused = true  # stop everything
	process_mode = Node.PROCESS_MODE_ALWAYS  # but keep this screen running
	await get_tree().process_frame
	video.play()

func _on_retry_pressed():
	get_tree().paused = false
	await get_tree().process_frame
	await get_tree().process_frame  # two frames to be safe
	GameManager.reset_for_level()
	get_tree().change_scene_to_file("res://scenes/node_3d.tscn")

func _on_next_pressed():
	get_tree().paused = false
	await get_tree().process_frame
	await get_tree().process_frame
	GameManager.current_level += 1
	GameManager.reset_for_level()
	get_tree().change_scene_to_file("res://scenes/node_3d.tscn")
