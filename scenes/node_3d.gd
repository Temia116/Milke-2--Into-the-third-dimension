extends Node3D

@export var ball_scene: PackedScene
@export var launch_speed: float = 30.0
@onready var udder_spawn: Marker3D = $Cow/UdderSpawnPoint
@onready var camera: Camera3D = $Camera3D

var can_shoot: bool = true
var aim_mesh: ImmediateMesh
var aim_mesh_instance: MeshInstance3D
var current_shoot_dir: Vector3 = Vector3.DOWN
var bessie_next_shot: bool = false
var pause_menu_instance: CanvasLayer = null

@export var pause_menu_scene: PackedScene

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
	GameManager.cow_ability_activated.connect(_on_cow_ability_activated)

func _on_cow_ability_activated():
	match GameManager.selected_cow:
		"bessie":
			bessie_next_shot = true
			print("Bessie's ability is active! Next shot is UDDERLY MASSIVE.")
		"moolinda":
			GameManager.ability_score_multiplier = 2
			print("Moolinda's ability is active! Next shot scores DOUBLE CREAM.")

func _get_cursor_world_pos() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var world_pos = camera.project_position(mouse_pos, camera.global_position.z - udder_spawn.global_position.z)
	return Vector3(world_pos.x, world_pos.y, udder_spawn.global_position.z)

func _get_launch_velocity() -> Vector3:
	var origin = udder_spawn.global_position
	var target = _get_cursor_world_pos()

	if target.y >= origin.y - 0.5:
		target.y = origin.y - 0.5

	var to_target = target - origin
	var max_angle_deg = 85.0
	var down = Vector3(0, -1, 0)
	var dir = to_target.normalized()
	var angle = rad_to_deg(acos(clamp(dir.dot(down), -1.0, 1.0)))

	if angle > max_angle_deg:
		var axis = down.cross(dir)
		if axis.length() < 0.001:
			axis = Vector3(0, 0, 1)
		axis = axis.normalized()
		dir = down.rotated(axis, deg_to_rad(max_angle_deg))

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

	if bessie_next_shot:
		ball.scale = Vector3(3, 3, 3)
		var phys_mat = PhysicsMaterial.new()
		phys_mat.bounce = 0.05
		phys_mat.friction = 0.1
		ball.physics_material_override = phys_mat
		ball.mass = 6.0
		bessie_next_shot = false

func _draw_aim_line():
	aim_mesh.clear_surfaces()
	if not can_shoot:
		return
	var sim_pos = udder_spawn.global_position
	var sim_vel = _get_launch_velocity()
	var gravity_vec = Vector3(0, GRAVITY * GRAVITY_SCALE, 0)
	var space = get_world_3d().direct_space_state
	var sim_dt = 0.02   # smaller step so the line starts closer to the udder
	var steps = 160     # doubled to cover the same total distance
	var dot_accum = 0.0
	var dot_spacing = 1.0
	var pill_half_len = 0.3
	var pill_radius = 0.08
	var min_draw_distance = 0.4
	var start_pos = udder_spawn.global_position
	aim_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for _i in range(steps):
		var next_pos = sim_pos + sim_vel * sim_dt + 0.5 * gravity_vec * sim_dt * sim_dt
		sim_vel += gravity_vec * sim_dt
		var dist_from_origin = sim_pos.distance_to(start_pos)
		if dist_from_origin > min_draw_distance:
			var sphere_params = PhysicsShapeQueryParameters3D.new()
			var sphere_shape = SphereShape3D.new()
			sphere_shape.radius = 0.25
			sphere_params.shape = sphere_shape
			sphere_params.transform = Transform3D(Basis(), sim_pos)
			sphere_params.motion = next_pos - sim_pos
			sphere_params.collide_with_bodies = true
			sphere_params.collision_mask = 1
			var result = space.cast_motion(sphere_params)
			if result[0] < 1.0:
				sim_pos = sim_pos.lerp(next_pos, result[0])
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
		sim_pos = next_pos
	var radius = 0.35
	var segments = 16
	for i in range(segments):
		var angle_a = (float(i) / segments) * TAU
		var angle_b = (float(i + 1) / segments) * TAU
		aim_mesh.surface_add_vertex(sim_pos)
		aim_mesh.surface_add_vertex(sim_pos + Vector3(cos(angle_a) * radius, sin(angle_a) * radius, 0))
		aim_mesh.surface_add_vertex(sim_pos + Vector3(cos(angle_b) * radius, sin(angle_b) * radius, 0))
	aim_mesh.surface_end()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_shoot:
			_shoot()
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			_toggle_pause_menu()

func _toggle_pause_menu():
	if pause_menu_instance != null and is_instance_valid(pause_menu_instance):
		pause_menu_instance.queue_free()
		pause_menu_instance = null
		get_tree().paused = false
		return
	if pause_menu_scene == null:
		push_error("No pause_menu_scene assigned!")
		return
	pause_menu_instance = pause_menu_scene.instantiate()
	get_tree().root.add_child(pause_menu_instance)
	pause_menu_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

func _on_ball_exited():
	can_shoot = true
	GameManager.reset_shot_multipliers()
