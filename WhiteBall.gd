extends RigidBody3D

func _process(_delta):
	if global_position.y < -20.0:
		queue_free()
