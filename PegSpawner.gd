# PegSpawner.gd
extends Node3D

@export var blue_peg_scene: PackedScene
@export var orange_peg_scene: PackedScene
@export var green_peg_scene: PackedScene

# Layout: each entry is [x, y, peg_type]
var level_1 = [
	# Row 1
	[-10, 3, "blue"], [-8, 3, "blue"], [-6, 3, "blue"], [-4, 3, "blue"], [-2, 3, "blue"], [0, 3, "blue"], [2, 3, "blue"], [4, 3, "blue"], [6, 3, "blue"], [8, 3, "blue"], [10, 3, "blue"],
	# Row 2
	[-9, 1.5, "blue"], [-7, 1.5, "blue"], [-5, 1.5, "blue"], [-3, 1.5, "blue"], [-1, 1.5, "blue"], [1, 1.5, "blue"], [3, 1.5, "blue"], [5, 1.5, "blue"], [7, 1.5, "blue"], [9, 1.5, "blue"],
	# Row 3
	[-10, 0, "blue"], [-8, 0, "blue"], [-6, 0, "blue"], [-4, 0, "blue"], [-2, 0, "blue"], [0, 0, "blue"], [2, 0, "blue"], [4, 0, "blue"], [6, 0, "blue"], [8, 0, "blue"], [10, 0, "blue"],
	# Row 4
	[-9, -1.5, "blue"], [-7, -1.5, "blue"], [-5, -1.5, "blue"], [-3, -1.5, "blue"], [-1, -1.5, "blue"], [1, -1.5, "blue"], [3, -1.5, "blue"], [5, -1.5, "blue"], [7, -1.5, "blue"], [9, -1.5, "blue"],
	# Row 5
	[-10, -3, "blue"], [-8, -3, "blue"], [-6, -3, "blue"], [-4, -3, "blue"], [-2, -3, "blue"], [0, -3, "blue"], [2, -3, "blue"], [4, -3, "blue"], [6, -3, "blue"], [8, -3, "blue"], [10, -3, "blue"],
	# Row 6
	[-9, -4.5, "blue"], [-7, -4.5, "blue"], [-5, -4.5, "blue"], [-3, -4.5, "blue"], [-1, -4.5, "blue"], [1, -4.5, "blue"], [3, -4.5, "blue"], [5, -4.5, "blue"], [7, -4.5, "blue"], [9, -4.5, "blue"],
	# Row 7
	[-10, -6, "blue"], [-8, -6, "blue"], [-6, -6, "blue"], [-4, -6, "blue"], [-2, -6, "blue"], [0, -6, "blue"], [2, -6, "blue"], [4, -6, "blue"], [6, -6, "blue"], [8, -6, "blue"], [10, -6, "blue"],
]
func _ready():
	spawn_level(level_1)

func spawn_level(layout: Array):
	for entry in layout:
		var x = entry[0]
		var y = entry[1]
		var type = entry[2]
		
		var peg_scene = _get_scene_for_type(type)
		if peg_scene == null:
			continue
			
		var peg = peg_scene.instantiate()
		add_child(peg)
		peg.position = Vector3(x, y, 0.0)

func _get_scene_for_type(type: String) -> PackedScene:
	match type:
		"blue": return blue_peg_scene
		"orange": return null  # will be skipped until you add the scene
		"green": return null   # same
	return null
