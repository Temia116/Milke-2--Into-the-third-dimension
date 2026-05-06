extends RigidBody3D

signal ball_exited

func _process(_delta):
	if global_position.y < -20.0:
		ball_exited.emit()
		queue_free()
