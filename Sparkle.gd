# Sparkle.gd
# Attach to a small star/sparkle MeshInstance3D as a child of the Power Peg.
# Spins it continuously - no AnimationPlayer needed, this is lighter weight.
extends MeshInstance3D

@export var spin_speed: float = 2.0  # radians per second

func _process(delta):
	rotate_y(spin_speed * delta)
