# WhiteBall.gd
extends RigidBody3D

signal ball_exited

var exited = false
var hit_pegs = []
var stuck_timer = 0.0
const STUCK_THRESHOLD = 2.0  # seconds of low movement before forcing exit
const STUCK_SPEED = 0.3      # below this speed counts as "stuck"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("on_hit") and body not in hit_pegs:
		hit_pegs.append(body)
		body.on_hit()

func _process(delta):
	if global_position.y < -20.0 and not exited:
		_force_exit()
		return

	# Stuck detection
	if linear_velocity.length() < STUCK_SPEED:
		stuck_timer += delta
		if stuck_timer >= STUCK_THRESHOLD and not exited:
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
