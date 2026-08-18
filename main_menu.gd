# main_menu.gd
extends Control

@onready var play_button = $PlayButton
@onready var quit_button = $QuitButton

func _ready():
	get_tree().paused = false  # safety net in case we arrived here still paused
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	MusicManager.play_menu()
	_setup_background()
	_setup_title()
	_position_buttons()

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
	move_child(tex_rect, 0)  # keep it behind everything else

func _setup_title():
	var viewport_size = get_viewport().get_visible_rect().size

	var title = Label.new()
	title.text = "MILKLE 2\nINTO THE THIRD DIMENSION"
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color(1.0, 0.95, 0.85, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.05, 1.0))
	title.add_theme_constant_override("outline_size", 8)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 80)
	title.size = Vector2(viewport_size.x, 140)
	add_child(title)

func _position_buttons():
	var viewport_size = get_viewport().get_visible_rect().size
	var center_x = viewport_size.x / 2.0

	play_button.position = Vector2(center_x - play_button.size.x / 2.0, 420)
	quit_button.position = Vector2(center_x - quit_button.size.x / 2.0, 490)

func _on_play_pressed():
	GameManager.current_level = 1
	GameManager.reset_for_level()
	get_tree().change_scene_to_file("res://scenes/node_3d.tscn")

func _on_quit_pressed():
	get_tree().quit()
