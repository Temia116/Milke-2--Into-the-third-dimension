extends Node3D

@export var ball_scene: PackedScene
@export var launch_speed: float = 35.0

@onready var udder_spawn: Marker3D = $Cow/UdderSpawnPoint
@onready var camera: Camera3D = $Camera3D

var can_shoot: bool = true
var aim_mesh: ImmediateMesh
var aim_mesh_instance: MeshInstance3D

func _ready():
	aim_mesh = ImmediateMesh.new()
	aim_mesh_instance = MeshInstance3D.new()
	aim_mesh_instance.mesh = aim_mesh
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.0, 0.5, 1.0)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	aim_mesh_instance.material_override = mat
	add_child(aim_mesh_instance)
	print("Aim line setup done")

var current_shoot_dir: Vector3 = Vector3.DOWN

func _process(_delta):
	# Calculate once per frame and cache
	current_shoot_dir = _get_shoot_dir()
	_draw_aim_line()

func _get_shoot_dir() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	
	# For orthographic camera, project onto the plane at udder Z
	var udder_z = udder_spawn.global_position.z
	if abs(dir.z) > 0.001:
		var t = (udder_z - from.z) / dir.z
		var cursor_world_pos = from + dir * t
		return (cursor_world_pos - udder_spawn.global_position).normalized()
	else:
		return dir.normalized()

func _shoot():
	if ball_scene == null:
		push_error("No ball_scene assigned!")
		return
	
	can_shoot = false
	
	var ball = ball_scene.instantiate()
	get_tree().root.add_child(ball)
	ball.global_position = udder_spawn.global_position
	
	# Add upward arc compensation based on distance to target
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	var udder_z = udder_spawn.global_position.z
	var t = (udder_z - from.z) / dir.z
	var cursor_world_pos = from + dir * t
	var distance = udder_spawn.global_position.distance_to(cursor_world_pos)
	
	# Arc upward proportional to distance
	var arc_strength = distance * 0.15
	var launch_dir = current_shoot_dir + Vector3(0, arc_strength, 0)
	launch_dir = launch_dir.normalized()
	
	ball.linear_velocity = launch_dir * launch_speed
	ball.gravity_scale = 1.75
	ball.tree_exited.connect(_on_ball_exited)
func _draw_aim_line():
	aim_mesh.clear_surfaces()
	
	if not can_shoot:
		return
	
	var pos = udder_spawn.global_position
	var shoot_dir = current_shoot_dir  # use cached direction
	
	# Raycast to find hit point
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(pos, pos + shoot_dir * 30.0)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 1
	var result = space.intersect_ray(query)
	
	var end_point = pos + shoot_dir * 30.0
	if result.size() > 0:
		end_point = result.position
	
	aim_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	# Straight dotted line stopping at hit point
	var total_dist = pos.distance_to(end_point)
	var dot_spacing = 0.4
	var current_dist = 0.0
	while current_dist < total_dist:
		var point = pos + shoot_dir * current_dist
		aim_mesh.surface_add_vertex(point)
		aim_mesh.surface_add_vertex(point + shoot_dir * 0.15)
		current_dist += dot_spacing
	
	# Circle at hit point
	if result.size() > 0:
		var hit = result.position
		var radius = 0.3
		var segments = 16
		for i in range(segments):
			var angle_a = (float(i) / segments) * TAU
			var angle_b = (float(i + 1) / segments) * TAU
			aim_mesh.surface_add_vertex(hit + Vector3(cos(angle_a) * radius, sin(angle_a) * radius, 0))
			aim_mesh.surface_add_vertex(hit + Vector3(cos(angle_b) * radius, sin(angle_b) * radius, 0))
	
	aim_mesh.surface_end()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_shoot:
			_shoot()

func _on_ball_exited():
	can_shoot = true
