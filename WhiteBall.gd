extends RigidBody3D

signal ball_exited

var exited = false

func _process(_delta):
	if global_position.y < -20.0 and not exited:
		exited = true
		GameManager.on_ball_lost()
		ball_exited.emit()
		queue_free()
