# PegSpawner.gd
extends Node3D

@export var blue_peg_scene: PackedScene
@export var orange_peg_scene: PackedScene
@export var green_peg_scene: PackedScene

var level_1 = [
	# Row 1
	[-12, 3, "blue"], [-8, 3, "blue"], [-4, 3, "blue"], [0, 3, "blue"], [4, 3, "blue"], [8, 3, "blue"], [12, 3, "blue"],
	# Row 2
	[-10, 1.5, "blue"], [-6, 1.5, "blue"], [-2, 1.5, "blue"], [2, 1.5, "blue"], [6, 1.5, "blue"], [10, 1.5, "blue"],
	# Row 3
	[-12, 0, "blue"], [-8, 0, "blue"], [-4, 0, "blue"], [0, 0, "blue"], [4, 0, "blue"], [8, 0, "blue"], [12, 0, "blue"],
	# Row 4
	[-10, -1.5, "blue"], [-6, -1.5, "blue"], [-2, -1.5, "blue"], [2, -1.5, "blue"], [6, -1.5, "blue"], [10, -1.5, "blue"],
	# Row 5
	[-12, -3, "blue"], [-8, -3, "blue"], [-4, -3, "blue"], [0, -3, "blue"], [4, -3, "blue"], [8, -3, "blue"], [12, -3, "blue"],
	#Row 6
	[-10, -4.5, "blue"], [-6, -4.5, "blue"], [-2, -4.5, "blue"], [2, -4.5, "blue"], [6, -4.5, "blue"], [10, -4.5, "blue"]
	]
func _ready():
	spawn_level(level_1)

func spawn_level(layout: Array):
	var blue_indices = []
	for i in range(layout.size()):
		if layout[i][2] == "blue":
			blue_indices.append(i)
	
	var orange_count = max(1, int(blue_indices.size() * 0.20))
	blue_indices.shuffle()
	var orange_indices = blue_indices.slice(0, orange_count)
	
	print("Total blue pegs: ", blue_indices.size())
	print("Orange count: ", orange_count)
	print("Orange indices: ", orange_indices)
	
	for i in range(layout.size()):
		var entry = layout[i]
		var x = entry[0]
		var y = entry[1]
		var type = entry[2]
		
		if i in orange_indices:
			type = "orange"
		
		var peg_scene = _get_scene_for_type(type)
		if peg_scene == null:
			continue
		
		var peg = peg_scene.instantiate()
		peg.peg_type = type  # SET BEFORE add_child
		add_child(peg)
		peg.position = Vector3(x, y, 0.0)

func _get_scene_for_type(type: String) -> PackedScene:
	match type:
		"blue": return blue_peg_scene
		"orange": return orange_peg_scene
		"green": return green_peg_scene
	return null
