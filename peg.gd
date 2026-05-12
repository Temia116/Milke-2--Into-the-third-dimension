extends Area3D

@export var peg_type: String = "blue"
var hit: bool = false
var hit_tween: Tween

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody3D and not hit:
		hit = true
		if hit_tween:
			hit_tween.kill()
		hit_tween = create_tween()
		hit_tween.tween_property(self, "scale", Vector3(1.6, 1.6, 1.6), 0.08)
		hit_tween.tween_property(self, "scale", Vector3(1.2, 1.2, 1.2), 0.08)
		body.ball_exited.connect(_on_ball_exited)

func _on_ball_exited():
	GameManager.on_peg_hit(peg_type)  # ADD THIS
	$StaticBody3D/CollisionShape3D.disabled = true
	$CollisionShape3D.disabled = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.4, 1.4, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector3(0.0, 0.0, 0.0), 0.15)
	await tween.finished
	queue_free()
