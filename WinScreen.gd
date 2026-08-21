# WinScreen.gd
extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var retry_button = $RetryButton
@onready var next_button = $NextButton
@onready var video = $VideoStreamPlayer

func _ready():
	visible = false
	layer = 100  # force this above the HUD regardless of the editor-saved value
	process_mode = Node.PROCESS_MODE_ALWAYS  # keep working once the game is paused
	retry_button.pressed.connect(_on_retry_pressed)
	next_button.pressed.connect(_on_next_pressed)
	GameManager.level_complete.connect(_on_level_complete)
	video.finished.connect(_on_video_finished)

func _on_level_complete():
	visible = true
	score_label.text = "SCORE: " + str(GameManager.score)
	next_button.visible = GameManager.current_level < GameManager.MAX_LEVEL
	get_tree().paused = true
	video.play()

func _on_video_finished():
	video.play()  # loop the win video

func _on_retry_pressed():
	get_tree().paused = false
	if GameManager.current_level >= GameManager.MAX_LEVEL:
		GameManager.current_level = 1
	GameManager.reset_for_level()
	get_tree().change_scene_to_file("res://scenes/node_3d.tscn")

func _on_next_pressed():
	get_tree().paused = false
	GameManager.current_level += 1
	GameManager.reset_for_level()
	get_tree().change_scene_to_file("res://scenes/node_3d.tscn")
