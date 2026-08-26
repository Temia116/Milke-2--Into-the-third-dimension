# PauseMenu.gd
# Simple pause overlay with Resume and Main Menu buttons.
extends CanvasLayer

@onready var resume_button = $ResumeButton
@onready var main_menu_button = $MainMenuButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  # keep working while the game is paused
	resume_button.pressed.connect(_on_resume_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	await get_tree().process_frame
	_setup_background()
	_setup_title()
	_position_buttons()

func _setup_background():
	var viewport_size = get_viewport().get_visible_rect().size

	var dim = ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.6)
	dim.position = Vector2.ZERO
	dim.size = viewport_size
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	move_child(dim, 0)  # keep it behind everything else

func _setup_title():
	var viewport_size = get_viewport().get_visible_rect().size

	var title = Label.new()
	title.text = "GAME PAUSED"
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color(1.0, 0.95, 0.85, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.05, 1.0))
	title.add_theme_constant_override("outline_size", 8)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 200)
	title.size = Vector2(viewport_size.x, 100)
	add_child(title)

func _position_buttons():
	var viewport_size = get_viewport().get_visible_rect().size
	var center_x = viewport_size.x / 2.0

	resume_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
	main_menu_button.set_anchors_preset(Control.PRESET_TOP_LEFT)

	resume_button.visible = true
	main_menu_button.visible = true

	resume_button.position = Vector2(center_x - resume_button.size.x / 2.0, 380)
	main_menu_button.position = Vector2(center_x - main_menu_button.size.x / 2.0, 450)

func _on_resume_pressed():
	get_tree().paused = false
	queue_free()

func _on_main_menu_pressed():
	get_tree().paused = false
	MusicManager.play_menu()

	var old_scene = get_tree().current_scene
	var new_scene = load("res://scenes/MainMenu.tscn").instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

	if old_scene:
		old_scene.queue_free()
	queue_free()
