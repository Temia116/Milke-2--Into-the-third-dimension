extends Node3D

@export var ball_scene: PackedScene
@export var launch_speed: float = 20.0
@export var max_angle_deg: float = 80.0

@onready var udder_spawn: Marker3D = $Cow/UdderSpawnPoint
@onready var camera: Camera3D = $Camera3D

var aim_direction: Vector3 = Vector3.ZERO
var can_shoot: bool = true

func _process(_delta):
	_update_aim()

func _update_aim():
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	
	if abs(dir.z) > 0.001:
		var t = -from.z / dir.z
		var world_point = from + dir * t
		aim_direction = (world_point - udder_spawn.global_position).normalized()
	else:
		aim_direction = dir.normalized()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_shoot:
			_shoot()

func _shoot():
	if ball_scene == null:
		push_error("No ball_scene assigned!")
		return
	
	can_shoot = false
	var ball = ball_scene.instantiate()
	get_tree().root.add_child(ball)
	ball.global_position = udder_spawn.global_position
	ball.linear_velocity = aim_direction * launch_speed
	ball.tree_exited.connect(_on_ball_exited)

func _on_ball_exited():
	can_shoot = true
