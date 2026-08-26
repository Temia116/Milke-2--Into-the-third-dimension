# GameOver.gd
extends CanvasLayer

@onready var audio = $AudioStreamPlayer2D
@onready var retry_button = $Button
@onready var video = $VideoStreamPlayer

func _ready():
	visible = false
	layer = 100  # force this above the HUD regardless of the editor-saved value
	process_mode = Node.PROCESS_MODE_ALWAYS  # keep working once the game is paused
	retry_button.pressed.connect(_on_retry_pressed)
	GameManager.game_over.connect(_on_game_over)
	video.finished.connect(_on_video_finished)

func _on_game_over():
	visible = true
	audio.play()
	video.play()
	get_tree().paused = true

func _on_video_finished():
	video.play()  # replay for looping

func _on_retry_pressed():
	get_tree().paused = false
	GameManager.reset_for_level()
	get_tree().change_scene_to_file("res://scenes/node_3d.tscn")
