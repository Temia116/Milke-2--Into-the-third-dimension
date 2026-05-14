extends StaticBody3D

@export var peg_type: String = "blue"
var hit: bool = false

func _ready():
	if peg_type == "orange":
		add_to_group("orange_pegs")

func on_hit():
	if hit:
		return
	hit = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.6, 1.6, 1.6), 0.08)
	tween.tween_property(self, "scale", Vector3(1.2, 1.2, 1.2), 0.08)

func on_ball_exited():
	if not hit:
		return
	GameManager.on_peg_hit(peg_type)
	$CollisionShape3D.disabled = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.4, 1.4, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector3(0.0, 0.0, 0.0), 0.15)
	await tween.finished
	queue_free()
