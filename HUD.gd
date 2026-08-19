extends CanvasLayer

@onready var score_label = $TopBar/ScoreLabel
@onready var ball_stack = $BallStack
@onready var cow_label = $CowBar/CowLabel
@onready var ability_label = $CowBar/AbilityLabel
var ball_icons = []
var peg_progress_label: Label = null

# Dairy-fresh palette per the GDD (sec 9.1)
const SKY_BLUE := Color(0.35, 0.75, 0.95, 1.0)
const GRASS_GREEN := Color(0.35, 0.75, 0.35, 1.0)
const WARM_ORANGE := Color(0.98, 0.62, 0.18, 1.0)
const CREAM_WHITE := Color(0.99, 0.98, 0.93, 1.0)
const DARK_TEXT := Color(0.15, 0.12, 0.08, 1.0)

const MILK_COLOR := CREAM_WHITE
const MILK_EMPTY := Color(0.55, 0.55, 0.55, 0.4)

const COW_ABILITY_NAMES = {
	"bessie": "UDDERLY MASSIVE",
	"moolinda": "DOUBLE CREAM",
	"none": ""
}

func _ready():
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.balls_changed.connect(_on_balls_changed)
	GameManager.cow_ability_activated.connect(_on_ability_activated)
	_style_score_label()
	score_label.text = "SCORE: 0"
	_setup_ball_icons()
	_setup_peg_progress()
	_position_cow_bar()
	_update_cow_display()

func _style_score_label():
	score_label.add_theme_font_size_override("font_size", 32)
	score_label.add_theme_color_override("font_color", CREAM_WHITE)
	score_label.add_theme_color_override("font_outline_color", DARK_TEXT)
	score_label.add_theme_constant_override("outline_size", 6)

	# Rounded card behind the score
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(SKY_BLUE.r, SKY_BLUE.g, SKY_BLUE.b, 0.85)
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = CREAM_WHITE
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", style)

	var top_bar = score_label.get_parent()
	var idx = score_label.get_index()
	top_bar.remove_child(score_label)
	panel.add_child(score_label)
	top_bar.add_child(panel)
	top_bar.move_child(panel, idx)

func _setup_ball_icons():
	for icon in ball_icons:
		icon.queue_free()
	ball_icons.clear()
	for i in range(GameManager.balls_remaining):
		var circle = _make_ball_icon(MILK_COLOR)
		ball_stack.add_child(circle)
		ball_icons.append(circle)

func _make_ball_icon(color: Color) -> Control:
	var wrap = PanelContainer.new()
	wrap.custom_minimum_size = Vector2(36, 36)
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = WARM_ORANGE
	wrap.add_theme_stylebox_override("panel", style)
	return wrap

func _setup_peg_progress():
	var viewport_size = get_viewport().get_visible_rect().size

	peg_progress_label = Label.new()
	peg_progress_label.text = "MILK\nPEGS\n0/0"
	peg_progress_label.add_theme_font_size_override("font_size", 26)
	peg_progress_label.add_theme_color_override("font_color", WARM_ORANGE)
	peg_progress_label.add_theme_color_override("font_outline_color", DARK_TEXT)
	peg_progress_label.add_theme_constant_override("outline_size", 6)
	peg_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	peg_progress_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# A rounded card to match the score card, positioned on the right border
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(GRASS_GREEN.r, GRASS_GREEN.g, GRASS_GREEN.b, 0.85)
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = CREAM_WHITE
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)
	panel.add_child(peg_progress_label)

	panel.custom_minimum_size = Vector2(70, 140)
	panel.position = Vector2(viewport_size.x - 78, viewport_size.y / 2.0 - 70)
	add_child(panel)

	_update_peg_progress()

func _update_peg_progress():
	if peg_progress_label == null:
		return
	var hit = GameManager.orange_pegs_hit
	var total = GameManager.total_orange_pegs
	peg_progress_label.text = "MILK\nPEGS\n%d/%d" % [hit, total]

func _on_score_changed(new_score: int):
	score_label.text = "SCORE: " + str(new_score)
	_update_peg_progress()

func _on_balls_changed(new_count: int):
	for i in range(ball_icons.size()):
		var style = ball_icons[i].get_theme_stylebox("panel") as StyleBoxFlat
		if i < new_count:
			style.bg_color = MILK_COLOR
			style.border_color = WARM_ORANGE
		else:
			style.bg_color = MILK_EMPTY
			style.border_color = Color(0.4, 0.4, 0.4, 0.5)

func _position_cow_bar():
	var cow_bar = cow_label.get_parent()
	if cow_bar is Control:
		cow_bar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		cow_bar.position.y -= 60
	cow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ability_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	cow_label.add_theme_font_size_override("font_size", 24)
	cow_label.add_theme_color_override("font_color", GRASS_GREEN)
	cow_label.add_theme_color_override("font_outline_color", DARK_TEXT)
	cow_label.add_theme_constant_override("outline_size", 5)

	ability_label.add_theme_font_size_override("font_size", 18)
	ability_label.add_theme_color_override("font_color", WARM_ORANGE)
	ability_label.add_theme_color_override("font_outline_color", DARK_TEXT)
	ability_label.add_theme_constant_override("outline_size", 4)

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
		ability_label.modulate = Color(1, 1, 1, 0.5)
	else:
		ability_label.text = ability_name + " ready"
		ability_label.modulate = Color(1, 1, 1, 1.0)

func _on_ability_activated():
	_refresh_ability_label()
