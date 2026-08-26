extends StaticBody3D

@export var speed: float = 3.0
@export var left_limit: float = -12.0
@export var right_limit: float = 12.0

var direction: float = 1.0

func _ready():
	$CatchZone.body_entered.connect(_on_catch_zone_body_entered)

func _process(delta):
	position.x += speed * direction * delta
	if position.x >= right_limit and direction == 1.0:
		direction = -1.0
		$van_1.rotation.y = PI
	elif position.x <= left_limit and direction == -1.0:
		direction = 1.0
		$van_1.rotation.y = 0.0

func _on_catch_zone_body_entered(body):
	if body is RigidBody3D and not body.exited:
		body.exited = true
		# Clear hit pegs same as normal ball exit
		for peg in body.hit_pegs:
			if is_instance_valid(peg):
				peg.on_ball_exited()
		GameManager.on_ball_caught()
		#await get_tree().create_timer(0.5).timeout
		if is_instance_valid(body):
			body.queue_free()
