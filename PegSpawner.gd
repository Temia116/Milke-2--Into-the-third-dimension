# PegSpawner.gd
extends Node3D

@export var blue_peg_scene: PackedScene
@export var orange_peg_scene: PackedScene
@export var green_peg_scene: PackedScene

var level_1 = [
	# Row 1
	[-12, 3, "blue"], [-10, 3, "blue"], [-8, 3, "blue"], [-6, 3, "blue"], [-4, 3, "blue"], [-2, 3, "blue"], [0, 3, "blue"], [2, 3, "blue"], [4, 3, "blue"], [6, 3, "blue"], [8, 3, "blue"], [10, 3, "blue"], [12, 3, "blue"],
	# Row 2
	[-11, 1.5, "blue"], [-9, 1.5, "blue"], [-7, 1.5, "blue"], [-5, 1.5, "blue"], [-3, 1.5, "blue"], [-1, 1.5, "blue"], [1, 1.5, "blue"], [3, 1.5, "blue"], [5, 1.5, "blue"], [7, 1.5, "blue"], [9, 1.5, "blue"], [11, 1.5, "blue"],
	# Row 3
	[-12, 0, "blue"], [-10, 0, "blue"], [-8, 0, "blue"], [-6, 0, "blue"], [-4, 0, "blue"], [-2, 0, "blue"], [0, 0, "blue"], [2, 0, "blue"], [4, 0, "blue"], [6, 0, "blue"], [8, 0, "blue"], [10, 0, "blue"], [12, 0, "blue"],
	# Row 4
	[-11, -1.5, "blue"], [-9, -1.5, "blue"], [-7, -1.5, "blue"], [-5, -1.5, "blue"], [-3, -1.5, "blue"], [-1, -1.5, "blue"], [1, -1.5, "blue"], [3, -1.5, "blue"], [5, -1.5, "blue"], [7, -1.5, "blue"], [9, -1.5, "blue"], [11, -1.5, "blue"],
	# Row 5
	[-12, -3, "blue"], [-10, -3, "blue"], [-8, -3, "blue"], [-6, -3, "blue"], [-4, -3, "blue"], [-2, -3, "blue"], [0, -3, "blue"], [2, -3, "blue"], [4, -3, "blue"], [6, -3, "blue"], [8, -3, "blue"], [10, -3, "blue"], [12, -3, "blue"],
	# Row 6
	[-11, -4.5, "blue"], [-9, -4.5, "blue"], [-7, -4.5, "blue"], [-5, -4.5, "blue"], [-3, -4.5, "blue"], [-1, -4.5, "blue"], [1, -4.5, "blue"], [3, -4.5, "blue"], [5, -4.5, "blue"], [7, -4.5, "blue"], [9, -4.5, "blue"], [11, -4.5, "blue"],
	# Row 7
	[-12, -6, "blue"], [-10, -6, "blue"], [-8, -6, "blue"], [-6, -6, "blue"], [-4, -6, "blue"], [-2, -6, "blue"], [0, -6, "blue"], [2, -6, "blue"], [4, -6, "blue"], [6, -6, "blue"], [8, -6, "blue"], [10, -6, "blue"], [12, -6, "blue"],
	# Row 8
	[-11, -7.5, "blue"], [-9, -7.5, "blue"], [-7, -7.5, "blue"], [-5, -7.5, "blue"], [-3, -7.5, "blue"], [-1, -7.5, "blue"], [1, -7.5, "blue"], [3, -7.5, "blue"], [5, -7.5, "blue"], [7, -7.5, "blue"], [9, -7.5, "blue"], [11, -7.5, "blue"],
	# Row 9
	[-12, -9, "blue"], [-10, -9, "blue"], [-8, -9, "blue"], [-6, -9, "blue"], [-4, -9, "blue"], [-2, -9, "blue"], [0, -9, "blue"], [2, -9, "blue"], [4, -9, "blue"], [6, -9, "blue"], [8, -9, "blue"], [10, -9, "blue"], [12, -9, "blue"],
]

func _ready():
	spawn_level(level_1)

func spawn_level(layout: Array):
	var blue_indices = []
	for i in range(layout.size()):
		if layout[i][2] == "blue":
			blue_indices.append(i)
	
	var orange_count = max(1, int(blue_indices.size() * 0.15))
	blue_indices.shuffle()
	var orange_indices = blue_indices.slice(0, orange_count)
	
	print("Total blue pegs: ", blue_indices.size())
	print("Orange count: ", orange_count)
	print("Orange indices: ", orange_indices)
	
	# Second pass: spawn pegs
	for i in range(layout.size()):
		var entry = layout[i]
		var x = entry[0]
		var y = entry[1]
		var type = entry[2]
		
		# Override blue to orange if selected
		if i in orange_indices:
			type = "orange"
		
		var peg_scene = _get_scene_for_type(type)
		if peg_scene == null:
			continue
		
		var peg = peg_scene.instantiate()
		add_child(peg)
		peg.position = Vector3(x, y, 0.0)

func _get_scene_for_type(type: String) -> PackedScene:
	match type:
		"blue": return blue_peg_scene
		"orange": return orange_peg_scene
		"green": return green_peg_scene
	return null
