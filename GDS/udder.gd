extends Node3D

var node_3d: Node3D

func _ready():
	node_3d = get_tree().get_root().get_node("Node3D")
	print("node_3d is: ", node_3d)

func _process(_delta):
	if node_3d and node_3d.current_shoot_dir != Vector3.ZERO:
		look_at(global_position + node_3d.current_shoot_dir, Vector3.UP)
		rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
