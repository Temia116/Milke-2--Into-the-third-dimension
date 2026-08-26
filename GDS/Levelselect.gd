# LevelSelect.gd
extends Control

@onready var buttons_container = $ButtonsContainer

func _ready():
	get_tree().paused = false
	MusicManager.play_menu()
	_setup_background()
	_setup_title()
	_setup_level_buttons()

func _setup_background():
	var viewport_size = get_viewport().get_visible_rect().size

	var gradient = Gradient.new()
	gradient.set_color(0, Color(0.05, 0.08, 0.18, 1.0))
	gradient.set_color(1, Color(0.1, 0.35, 0.12, 1.0))

	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.width = 4
	gradient_texture.height = int(viewport_size.y)
	gradient_texture.fill = GradientTexture2D.FILL_LINEAR
	gradient_texture.fill_from = Vector2(0, 0)
	gradient_texture.fill_to = Vector2(0, 1)

	var tex_rect = TextureRect.new()
	tex_rect.texture = gradient_texture
	tex_rect.position = Vector2.ZERO
	tex_rect.size = viewport_size
	tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
	tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tex_rect)
	move_child(tex_rect, 0)

func _setup_title():
	var viewport_size = get_viewport().get_visible_rect().size

	var title = Label.new()
	title.text = "SELECT LEVEL"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(1.0, 0.95, 0.85, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.05, 1.0))
	title.add_theme_constant_override("outline_size", 8)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 80)
	title.size = Vector2(viewport_size.x, 100)
	add_child(title)

const LEVEL_NAMES = {
	1: "Level 1\nThe Pasture",
	2: "Level 2\nThe Smile",
	3: "Level 3\nThe Rings",
}

func _setup_level_buttons():
	var viewport_size = get_viewport().get_visible_rect().size
	var button_width = 220
	var button_height = 100
	var spacing = 40
	var total_width = (button_width * GameManager.MAX_LEVEL) + (spacing * (GameManager.MAX_LEVEL - 1))
	var start_x = (viewport_size.x - total_width) / 2.0
	var y = viewport_size.y / 2.0 - button_height / 2.0

	for i in range(GameManager.MAX_LEVEL):
		var level_num = i + 1
		var button = Button.new()
		button.text = LEVEL_NAMES.get(level_num, "Level " + str(level_num))
		button.custom_minimum_size = Vector2(button_width, button_height)
		button.position = Vector2(start_x + i * (button_width + spacing), y)
		button.add_theme_font_size_override("font_size", 20)
		button.pressed.connect(_on_level_selected.bind(level_num))
		add_child(button)

	var back_button = Button.new()
	back_button.text = "Back"
	back_button.custom_minimum_size = Vector2(140, 50)
	back_button.position = Vector2(viewport_size.x / 2.0 - 70, y + button_height + 60)
	back_button.pressed.connect(_on_back_pressed)
	add_child(back_button)

func _on_level_selected(level_num: int):
	GameManager.current_level = level_num
	GameManager.reset_for_level()
	get_tree().change_scene_to_file("res://scenes/node_3d.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
