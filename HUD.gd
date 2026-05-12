extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var balls_label = $BallsContainer/BallsLabel

func _ready():
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.balls_changed.connect(_on_balls_changed)
	score_label.text = "SCORE: 0"
	balls_label.text = str(GameManager.balls_remaining)  # pull live value

func _on_score_changed(new_score: int):
	score_label.text = "SCORE: " + str(new_score)

func _on_balls_changed(new_count: int):
	balls_label.text = str(new_count)
