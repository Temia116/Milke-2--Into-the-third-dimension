extends Node3D

@export var ball_scene: PackedScene
@export var launch_speed: float = 30.0
@onready var udder_spawn: Marker3D = $Cow/UdderSpawnPoint
@onready var camera: Camera3D = $Camera3D

var can_shoot: bool = true
var aim_mesh: ImmediateMesh
var aim_mesh_instance: MeshInstance3D
var current_shoot_dir: Vector3 = Vector3.DOWN

const GRAVITY_SCALE: float = 1.75
const GRAVITY: float = -9.8

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

func _get_cursor_world_pos() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	var udder_z = udder_spawn.global_position.z
	if abs(dir.z) > 0.001:
		var t = (udder_z - from.z) / dir.z
		return from + dir * t
	return udder_spawn.global_position + dir * 10.0

func _get_launch_velocity() -> Vector3:
	var origin = udder_spawn.global_position
	var target = _get_cursor_world_pos()
	var to_target = target - origin
	
	if to_target.length() < 0.01:
		return Vector3(0, -1, 0) * launch_speed
	
	var dir = to_target.normalized()
	
	# If aiming too far up, clamp Y to the max allowed
	var max_up_degrees = -10.0  # degrees above horizontal
	var max_y = sin(deg_to_rad(max_up_degrees))
	if dir.y > max_y:
		dir.y = max_y
		dir = dir.normalized()
	
	return dir * launch_speed

func _process(_delta):
	var velocity = _get_launch_velocity()
	if velocity.length() > 0.01:
		current_shoot_dir = velocity.normalized()
	_draw_aim_line()

func _shoot():
	if ball_scene == null:
		push_error("No ball_scene assigned!")
		return

	can_shoot = false

	var ball = ball_scene.instantiate()
	get_tree().root.add_child(ball)
	ball.global_position = udder_spawn.global_position
	ball.linear_velocity = _get_launch_velocity()
	ball.gravity_scale = GRAVITY_SCALE
	ball.tree_exited.connect(_on_ball_exited)

func _draw_aim_line():
	aim_mesh.clear_surfaces()

	if not can_shoot:
		return

	var pos = udder_spawn.global_position
	var velocity = _get_launch_velocity()
	print("udder:", pos, " cursor:", _get_cursor_world_pos(), " vel:", velocity)
	var gravity_vec = Vector3(0, GRAVITY * GRAVITY_SCALE, 0)

	var space = get_world_3d().direct_space_state
	aim_mesh.surface_begin(Mesh.PRIMITIVE_LINES)

	var sim_pos = pos
	var sim_vel = velocity
	var sim_dt = 0.04
	var steps = 50
	var dot_accum = 0.0
	var dot_spacing = 0.6
	var dot_len = 0.4
	var hit_pos: Vector3 = Vector3.ZERO
	var hit_found = false

	for i in range(steps):
		var next_pos = sim_pos + sim_vel * sim_dt + 0.5 * gravity_vec * sim_dt * sim_dt
		sim_vel += gravity_vec * sim_dt

		var query = PhysicsRayQueryParameters3D.create(sim_pos, next_pos)
		query.collide_with_areas = true
		query.collide_with_bodies = true
		query.collision_mask = 1
		var result = space.intersect_ray(query)
		if result.size() > 0:
			hit_pos = result.position
			hit_found = true
			break

		var seg_len = sim_pos.distance_to(next_pos)
		dot_accum += seg_len
		while dot_accum >= dot_spacing:
			dot_accum -= dot_spacing
			var frac = 1.0 - (dot_accum / seg_len)
			var dot_start = sim_pos.lerp(next_pos, frac)
			var dot_end = sim_pos.lerp(next_pos, min(frac + dot_len / seg_len, 1.0))
			var thickness = 0.18
			for offset in [Vector3(0,0,0), Vector3(thickness,0,0), Vector3(-thickness,0,0), Vector3(0,thickness,0), Vector3(0,-thickness,0)]:
				aim_mesh.surface_add_vertex(dot_start + offset)
				aim_mesh.surface_add_vertex(dot_end + offset)

		sim_pos = next_pos

	if hit_found:
		var radius = 0.3
		var segments = 16
		for i in range(segments):
			var angle_a = (float(i) / segments) * TAU
			var angle_b = (float(i + 1) / segments) * TAU
			aim_mesh.surface_add_vertex(hit_pos + Vector3(cos(angle_a) * radius, sin(angle_a) * radius, 0))
			aim_mesh.surface_add_vertex(hit_pos + Vector3(cos(angle_b) * radius, sin(angle_b) * radius, 0))

	aim_mesh.surface_end()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_shoot:
			_shoot()

func _on_ball_exited():
	can_shoot = true
