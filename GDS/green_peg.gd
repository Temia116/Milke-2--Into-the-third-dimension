# GreenPeg.gd
# Same base behaviour as a normal peg, but refreshes the current cow's
# ability when hit — a small "Power Peg" bonus per the GDD.
extends StaticBody3D

@export var peg_type: String = "green"
var hit: bool = false

func _ready():
	add_to_group("green_pegs")

func on_hit():
	if hit:
		return
	hit = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.25, 1.25, 1.25), 0.08)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.08)

func on_ball_exited():
	if not hit:
		return
	GameManager.on_peg_hit(peg_type)
	GameManager.grant_and_activate_ability()
	print("Green peg hit! Cow ability granted instantly.")
	$CollisionShape3D.disabled = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(0.0, 0.0, 0.0), 0.2)
	await tween.finished
	queue_free()
