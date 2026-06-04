extends RigidBody3D

signal ball_exited

var exited = false
var hit_pegs = []

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("on_hit") and body not in hit_pegs:
		hit_pegs.append(body)
		body.on_hit()

func _process(_delta):
	if global_position.y < -20.0 and not exited:
		exited = true
		for peg in hit_pegs:
			if is_instance_valid(peg):
				peg.on_ball_exited()
		ball_exited.emit()
		queue_free()
