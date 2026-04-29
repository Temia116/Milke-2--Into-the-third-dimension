extends Area3D

@export var peg_type: String = "blue"
var hit: bool = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody3D and not hit:
		hit = true
		$CollisionShape3D.disabled = true
		await get_tree().create_timer(0.5).timeout
		queue_free()
