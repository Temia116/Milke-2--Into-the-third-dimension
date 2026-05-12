extends CanvasLayer

@onready var audio = $AudioStreamPlayer2D
@onready var retry_button = $Button
@onready var video = $VideoStreamPlayer

func _ready():
	visible = false
	retry_button.pressed.connect(_on_retry_pressed)
	GameManager.game_over.connect(_on_game_over)
	# Loop the video
	video.finished.connect(_on_video_finished)

func _on_game_over():
	visible = true
	audio.play()
	video.play()

func _on_video_finished():
	video.play()  # replay for looping

func _on_retry_pressed():
	GameManager.score = 0
	GameManager.balls_remaining = 10
	GameManager.orange_pegs_hit = 0
	GameManager.current_state = GameManager.State.IDLE
	


func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/node_3d.tscn")
