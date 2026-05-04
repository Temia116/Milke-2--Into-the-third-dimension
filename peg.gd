extends Area3D

@export var peg_type: String = "blue"
var hit: bool = false

func _ready():
	# Force collision shape to correct size
	var shape = $CollisionShape3D.shape
	if shape is SphereShape3D:
		shape.radius = 0.5  # adjust this to match your mesh size
	
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody3D and not hit:
		hit = true
		$CollisionShape3D.disabled = true
		await get_tree().create_timer(0.5).timeout
		queue_free()
