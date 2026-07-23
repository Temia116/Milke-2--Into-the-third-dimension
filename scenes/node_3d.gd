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
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	aim_mesh_instance.material_override = mat
	add_child(aim_mesh_instance)

func _get_cursor_world_pos() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var world_pos = camera.project_position(mouse_pos, camera.global_position.z - udder_spawn.global_position.z)
	return Vector3(world_pos.x, world_pos.y, udder_spawn.global_position.z)

func _get_launch_velocity() -> Vector3:
	var origin = udder_spawn.global_position
	var target = _get_cursor_world_pos()
	
	# Force target below the udder
	if target.y >= origin.y - 0.5:
		target.y = origin.y - 0.5
	
	var to_target = target - origin
	
	# Clamp direction to a max angle from straight down
	var max_angle_deg = 75.0
	var down = Vector3(0, -1, 0)
	var dir = to_target.normalized()
	var angle = rad_to_deg(acos(dir.dot(down)))
	if angle > max_angle_deg:
		# Lerp back toward straight down
		dir = down.lerp(dir.normalized(), max_angle_deg / angle).normalized()
	
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
	GameManager.on_ball_lost()

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
	var gravity_vec = Vector3(0, GRAVITY * GRAVITY_SCALE, 0)
	var space = get_world_3d().direct_space_state
	aim_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

	var sim_pos = pos
	var sim_vel = velocity
	var sim_dt = 0.04  # smaller step = evenly spaced dots
	var steps = 80
	var dot_accum = 0.0
	var dot_spacing = 1.0  # fixed world-space spacing
	var pill_half_len = 0.35
	var pill_radius = 0.12
	var pill_segs = 6

	for _i in range(steps):
		var next_pos = sim_pos + sim_vel * sim_dt + 0.5 * gravity_vec * sim_dt * sim_dt
		sim_vel += gravity_vec * sim_dt

		var query = PhysicsRayQueryParameters3D.create(sim_pos, next_pos)
		query.collide_with_areas = true
		query.collide_with_bodies = true
		query.collision_mask = 1
		var result = space.intersect_ray(query)
		if result.size() > 0:
			break

		var seg_len = sim_pos.distance_to(next_pos)
		dot_accum += seg_len
		while dot_accum >= dot_spacing:
			dot_accum -= dot_spacing
			var frac = 1.0 - (dot_accum / seg_len)
			var center = sim_pos.lerp(next_pos, frac)
			var travel_dir = (next_pos - sim_pos).normalized()
			var p0 = center - travel_dir * pill_half_len
			var p1 = center + travel_dir * pill_half_len
			var perp = Vector3(-travel_dir.y, travel_dir.x, 0).normalized() * pill_radius
			aim_mesh.surface_add_vertex(p0 - perp)
			aim_mesh.surface_add_vertex(p1 - perp)
			aim_mesh.surface_add_vertex(p1 + perp)
			aim_mesh.surface_add_vertex(p0 - perp)
			aim_mesh.surface_add_vertex(p1 + perp)
			aim_mesh.surface_add_vertex(p0 + perp)
			for s in range(pill_segs):
				var a0 = PI * 0.5 + PI * s / pill_segs
				var a1 = PI * 0.5 + PI * (s + 1) / pill_segs
				var t0 = Vector3(cos(a0), sin(a0), 0) * pill_radius
				var t1 = Vector3(cos(a1), sin(a1), 0) * pill_radius
				aim_mesh.surface_add_vertex(p0)
				aim_mesh.surface_add_vertex(p0 + t0)
				aim_mesh.surface_add_vertex(p0 + t1)
				a0 = -PI * 0.5 + PI * s / pill_segs
				a1 = -PI * 0.5 + PI * (s + 1) / pill_segs
				t0 = Vector3(cos(a0), sin(a0), 0) * pill_radius
				t1 = Vector3(cos(a1), sin(a1), 0) * pill_radius
				aim_mesh.surface_add_vertex(p1)
				aim_mesh.surface_add_vertex(p1 + t0)
				aim_mesh.surface_add_vertex(p1 + t1)

		sim_pos = next_pos

	aim_mesh.surface_end()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_shoot:
			_shoot()

func _on_ball_exited():
	can_shoot = true
