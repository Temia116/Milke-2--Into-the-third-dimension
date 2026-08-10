# StonePeg.gd
# Indestructible bumper peg. Never scores, never gets removed.
extends StaticBody3D

@export var peg_type: String = "stone"

func _ready():
	pass  # nothing to register - stone pegs aren't tracked or destroyed

func on_hit():
	# Small bounce reaction so it still feels alive on contact, but no destruction.
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.1, 1.1, 1.1), 0.06)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.08)

func on_ball_exited():
	pass  # stone pegs are permanent - do nothing when the ball leaves
