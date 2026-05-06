extends Node3D

@export var ball_scene: PackedScene
@export var launch_speed: float = 20.0
@export var max_angle_deg: float = 80.0

@onready var udder_spawn: Marker3D = $Cow/UdderSpawnPoint
@onready var camera: Camera3D = $Camera3D

var aim_direction: Vector3 = Vector3.ZERO
var can_shoot: bool = true
var aim_mesh: ImmediateMesh
var aim_mesh_instance: MeshInstance3D

func _ready():
	aim_mesh = ImmediateMesh.new()
	aim_mesh_instance = MeshInstance3D.new()
	aim_mesh_instance.mesh = aim_mesh
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.WHITE
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true 
	aim_mesh_instance.material_override = mat
	add_child(aim_mesh_instance)
	
	print("Aim line setup done")  

func _process(_delta):
	_update_aim()

func _shoot():
	if ball_scene == null:
		push_error("No ball_scene assigned!")
		return
	
	can_shoot = false
	var ball = ball_scene.instantiate()
	get_tree().root.add_child(ball)
	ball.global_position = udder_spawn.global_position
	ball.linear_velocity = aim_direction * launch_speed
	ball.gravity_scale = 1.75  # ADD THIS - tweak until it feels right
	ball.tree_exited.connect(_on_ball_exited)

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
	
	_draw_aim_line()  

func _draw_aim_line():
	aim_mesh.clear_surfaces()
	
	if not can_shoot:
		return
	
	var pos = udder_spawn.global_position
	var vel = aim_direction * launch_speed
	var gravity = Vector3(0, -9.8 * 1.75, 0)  # match your gravity_scale
	var step = 0.05
	var max_steps = 80
	var space = get_world_3d().direct_space_state
	
	aim_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	var prev_point = pos
	var hit_pos = Vector3.ZERO
	var hit_found = false
	
	for i in range(max_steps):
		var t = i * step
		# Simulate arc: pos + vel*t + 0.5*gravity*t^2
		var point = pos + vel * t + 0.5 * gravity * t * t
		
		# Raycast between previous and current point
		if i > 0:
			var query = PhysicsRayQueryParameters3D.create(prev_point, point)
			query.collide_with_areas = true
			query.collide_with_bodies = true
			query.collision_mask = 1
			var result = space.intersect_ray(query)
			
			if result.size() > 0:
				hit_pos = result.position
				hit_found = true
				# Draw last segment to hit point
				aim_mesh.surface_add_vertex(prev_point)
				aim_mesh.surface_add_vertex(hit_pos)
				break
		
		# Draw dotted segment
		aim_mesh.surface_add_vertex(prev_point)
		aim_mesh.surface_add_vertex(prev_point.lerp(point, 0.5))
		
		prev_point = point
	
	# Draw circle at hit point
	if hit_found:
		var radius = 0.3
		var segments = 16
		for i in range(segments):
			var angle_a = (float(i) / segments) * TAU
			var angle_b = (float(i + 1) / segments) * TAU
			aim_mesh.surface_add_vertex(hit_pos + Vector3(cos(angle_a) * radius, sin(angle_a) * radius, 0))
			aim_mesh.surface_add_vertex(hit_pos + Vector3(cos(angle_b) * radius, sin(angle_b) * radius, 0))
	
	aim_mesh.surface_end()

func _draw_circle_at(pos: Vector3):
	aim_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	var radius = 0.3
	var segments = 16
	
	for i in range(segments):
		var angle_a = (float(i) / segments) * TAU
		var angle_b = (float(i + 1) / segments) * TAU
		# Draw each segment as a line pair
		var point_a = pos + Vector3(cos(angle_a) * radius, sin(angle_a) * radius, 0)
		var point_b = pos + Vector3(cos(angle_b) * radius, sin(angle_b) * radius, 0)
		aim_mesh.surface_add_vertex(point_a)
		aim_mesh.surface_add_vertex(point_b)
	
	aim_mesh.surface_end()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_shoot:
			_shoot()



func _on_ball_exited():
	can_shoot = true
