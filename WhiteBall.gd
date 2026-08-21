# WhiteBall.gd
extends RigidBody3D

signal ball_exited

var exited = false
var hit_pegs = []
var stuck_timer = 0.0
const STUCK_THRESHOLD = 2.0
const STUCK_SPEED = 0.3

# Bessie's ability - travels in a straight, unbouncing line so it plows
# through pegs instead of deflecting off them.
var is_bulldozer: bool = false
var locked_dir: Vector3 = Vector3.ZERO
var locked_speed: float = 0.0
var start_pos: Vector3 = Vector3.ZERO
var original_collision_mask: int = 1
var ghost_area: Area3D = null

func _ready():
	body_entered.connect(_on_body_entered)
	# Make sure every ball (not just bulldozer ones) collides with both
	# pegs (layer 1) and walls (layer 2) by default.
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	original_collision_mask = collision_mask

func _on_body_entered(body):
	if body.has_method("on_hit") and body not in hit_pegs:
		hit_pegs.append(body)
		body.on_hit()

func _on_ghost_area_entered(body):
	_on_body_entered(body)

func start_bulldozer(velocity: Vector3):
	is_bulldozer = true
	locked_dir = velocity.normalized()
	locked_speed = velocity.length()
	start_pos = global_position
	gravity_scale = 0.0

	# Stop physically colliding with pegs (layer 1) - we control motion
	# manually below, so physical collision response would only fight us.
	# Still collide with walls (layer 2) so the ball can't bulldoze offscreen.
	collision_mask = 0
	set_collision_mask_value(2, true)

	ghost_area = Area3D.new()
	ghost_area.collision_mask = original_collision_mask
	ghost_area.monitoring = true
	ghost_area.monitorable = false
	add_child(ghost_area)

	var existing_shape = get_node_or_null("CollisionShape3D")
	var ghost_shape = CollisionShape3D.new()
	if existing_shape and existing_shape.shape:
		ghost_shape.shape = existing_shape.shape.duplicate()
	else:
		var sphere = SphereShape3D.new()
		sphere.radius = 0.6
		ghost_shape.shape = sphere
	ghost_area.add_child(ghost_shape)
	ghost_area.body_entered.connect(_on_ghost_area_entered)

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if is_bulldozer:
		var hit_wall = false
		var wall_normal = Vector3.ZERO
		for i in range(state.get_contact_count()):
			var collider = state.get_contact_collider_object(i)
			if collider and collider.has_method("get_collision_layer_value") and collider.get_collision_layer_value(2):
				hit_wall = true
				wall_normal = state.get_contact_local_normal(i)
				break

		if hit_wall:
			# Manually bounce off the wall by reflecting our locked direction,
			# rather than leaving it to the physics engine, which can cause
			# sticking with a zero-gravity, fully-overridden body like this.
			locked_dir = locked_dir - 2.0 * locked_dir.dot(wall_normal) * wall_normal
			locked_dir = locked_dir.normalized()
			start_pos = state.transform.origin

		var signed_traveled = (state.transform.origin - start_pos).dot(locked_dir)
		var corrected_pos = start_pos + locked_dir * signed_traveled
		state.transform.origin = corrected_pos
		state.linear_velocity = locked_dir * locked_speed

func _process(delta):
	if global_position.y < -20.0 and not exited:
		_force_exit()
		return

	var threshold = 0.5 if is_bulldozer else STUCK_THRESHOLD
	if linear_velocity.length() < STUCK_SPEED:
		stuck_timer += delta
		if stuck_timer >= threshold and not exited:
			_force_exit()
	else:
		stuck_timer = 0.0

func _force_exit():
	exited = true
	for peg in hit_pegs:
		if is_instance_valid(peg):
			peg.on_ball_exited()
	ball_exited.emit()
	queue_free()
