extends CanvasLayer

@onready var score_label = $TopBar/ScoreLabel
@onready var ball_stack = $BallStack

var ball_icons = []

# Creamy off-white so the fill reads as milk instead of flat white.
const MILK_COLOR := Color(0.99, 0.98, 0.93, 1.0)
const MILK_EMPTY := Color(0.3, 0.3, 0.3, 0.5)

func _ready():
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.balls_changed.connect(_on_balls_changed)
	score_label.text = "SCORE: 0"
	_setup_ball_icons()

func _setup_ball_icons():
	for icon in ball_icons:
		icon.queue_free()
	ball_icons.clear()

	for i in range(GameManager.balls_remaining):
		var circle = ColorRect.new()
		circle.color = MILK_COLOR
		circle.custom_minimum_size = Vector2(40, 40)
		ball_stack.add_child(circle)
		ball_icons.append(circle)

func _on_score_changed(new_score: int):
	score_label.text = "SCORE: " + str(new_score)

func _on_balls_changed(new_count: int):
	for i in range(ball_icons.size()):
		if i < new_count:
			ball_icons[i].color = MILK_COLOR
		else:
			ball_icons[i].color = MILK_EMPTY
