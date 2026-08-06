extends CanvasLayer
@onready var score_label = $TopBar/ScoreLabel
@onready var ball_stack = $BallStack
@onready var cow_label = $CowBar/CowLabel
@onready var ability_label = $CowBar/AbilityLabel
var ball_icons = []

# Creamy off-white so the fill reads as milk instead of flat white.
const MILK_COLOR := Color(0.99, 0.98, 0.93, 1.0)
const MILK_EMPTY := Color(0.3, 0.3, 0.3, 0.5)

const COW_ABILITY_NAMES = {
	"bessie": "UDDERLY MASSIVE",
	"moolinda": "DOUBLE CREAM",
	"none": ""
}

func _ready():
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.balls_changed.connect(_on_balls_changed)
	GameManager.cow_ability_activated.connect(_on_ability_activated)
	score_label.text = "SCORE: 0"
	_setup_ball_icons()
	_update_cow_display()

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

func _update_cow_display():
	var cow = GameManager.selected_cow
	if cow == "none" or cow == "":
		cow_label.text = ""
		ability_label.text = ""
		return
	cow_label.text = cow.capitalize()
	_refresh_ability_label()

func _refresh_ability_label():
	var cow = GameManager.selected_cow
	var ability_name = COW_ABILITY_NAMES.get(cow, "")
	if GameManager.cow_ability_used:
		ability_label.text = ability_name + " (USED)"
		ability_label.modulate = Color(0.5, 0.5, 0.5, 1.0)
	else:
		ability_label.text = ability_name + " — Press E"
		ability_label.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_ability_activated():
	_refresh_ability_label()
