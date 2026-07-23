# PegSpawner.gd
extends Node3D

@export var blue_peg_scene: PackedScene
@export var orange_peg_scene: PackedScene
@export var green_peg_scene: PackedScene

# ---------------------------------------------------------------------------
# LEVEL 1 — The Pasture (Tutorial)
# Classic staggered grid. Simple and open — teaches the basics.
# ---------------------------------------------------------------------------
var level_1 = [
	# Row 1
	[-12, 3.0, "blue"], [-8, 3.0, "blue"], [-4, 3.0, "blue"], [0, 3.0, "blue"],
	[4, 3.0, "blue"], [8, 3.0, "blue"], [12, 3.0, "blue"],
	# Row 2
	[-10, 1.5, "blue"], [-6, 1.5, "blue"], [-2, 1.5, "blue"], [2, 1.5, "blue"],
	[6, 1.5, "blue"], [10, 1.5, "blue"],
	# Row 3
	[-12, 0.0, "blue"], [-8, 0.0, "blue"], [-4, 0.0, "blue"], [0, 0.0, "blue"],
	[4, 0.0, "blue"], [8, 0.0, "blue"], [12, 0.0, "blue"],
	# Row 4
	[-10, -1.5, "blue"], [-6, -1.5, "blue"], [-2, -1.5, "blue"], [2, -1.5, "blue"],
	[6, -1.5, "blue"], [10, -1.5, "blue"],
	# Row 5
	[-12, -3.0, "blue"], [-8, -3.0, "blue"], [-4, -3.0, "blue"], [0, -3.0, "blue"],
	[4, -3.0, "blue"], [8, -3.0, "blue"], [12, -3.0, "blue"],
	# Row 6
	[-10, -4.5, "blue"], [-6, -4.5, "blue"], [-2, -4.5, "blue"], [2, -4.5, "blue"],
	[6, -4.5, "blue"], [10, -4.5, "blue"]
]

# ---------------------------------------------------------------------------
# LEVEL 2 — The Smile (Twin Arcs)
# Two curved arcs — a frown on top, a smile below.
# ---------------------------------------------------------------------------
var level_2 = [
	# Circle of pegs at top - centred at (0, 4.5), radius 3.5
	[0.0, 8.0, "blue"], [2.17, 7.25, "blue"], [3.5, 5.5, "blue"],
	[3.5, 3.5, "blue"], [2.17, 3.75, "blue"], [0.0, 3.0, "blue"],
	[-2.17, 3.75, "blue"], [-3.5, 3.5, "blue"], [-3.5, 5.5, "blue"],
	[-2.17, 7.25, "blue"],
	# Top arc (frown) - upper field
	[-10.0, 2.5, "blue"], [-9.51, 1.88, "blue"], [-8.09, 1.32, "blue"],
	[-5.88, 0.88, "blue"], [-3.09, 0.6, "blue"], [0.0, 0.5, "blue"],
	[3.09, 0.6, "blue"], [5.88, 0.88, "blue"], [8.09, 1.32, "blue"],
	[9.51, 1.88, "blue"], [10.0, 2.5, "blue"],
	# Bottom arc (smile) - lower field
	[10.0, -2.5, "blue"], [9.51, -1.88, "blue"], [8.09, -1.32, "blue"],
	[5.88, -0.88, "blue"], [3.09, -0.6, "blue"], [0.0, -0.5, "blue"],
	[-3.09, -0.6, "blue"], [-5.88, -0.88, "blue"], [-8.09, -1.32, "blue"],
	[-9.51, -1.88, "blue"], [-10.0, -2.5, "blue"],
	# Side columns
	[-11, 1.0, "blue"], [-11, -0.5, "blue"], [-11, -2.0, "blue"],
	[11, 1.0, "blue"], [11, -0.5, "blue"], [11, -2.0, "blue"],
	# Bottom scatter
	[-6, -3.5, "blue"], [-3, -4.0, "blue"], [0, -4.2, "blue"],
	[3, -4.0, "blue"], [6, -3.5, "blue"],
]

# ---------------------------------------------------------------------------
# LEVEL 3 — The Rings (Twin Circles + Diagonal)
# Two full peg rings with a diagonal scatter bridging them.
# ---------------------------------------------------------------------------
var level_3 = [
	[-0.5,  0.5,  "blue"], [-1.36, 3.15, "blue"], [-3.61, 4.78, "blue"],
	[-6.39, 4.78, "blue"], [-8.64, 3.15, "blue"], [-9.5,  0.5,  "blue"],
	[-8.64,-2.15, "blue"], [-6.39,-3.78, "blue"], [-3.61,-3.78, "blue"], [-1.36,-2.15, "blue"],
	[ 9.5,  0.5,  "blue"], [ 8.64, 3.15, "blue"], [ 6.39, 4.78, "blue"],
	[ 3.61, 4.78, "blue"], [ 1.36, 3.15, "blue"], [ 0.5,  0.5,  "blue"],
	[ 1.36,-2.15, "blue"], [ 3.61,-3.78, "blue"], [ 6.39,-3.78, "blue"], [ 8.64,-2.15, "blue"],
	[-11,  3.5, "blue"], [-8,  2.5, "blue"], [-2,  3.0, "blue"],
	[  2, -3.0, "blue"], [ 8, -2.5, "blue"], [11, -3.5, "blue"],
	[-10, -4.0, "blue"], [-7, -4.0, "blue"], [-4, -4.0, "blue"],
	[  0, -4.0, "blue"], [ 4, -4.0, "blue"], [ 7, -4.0, "blue"], [10, -4.0, "blue"],
	[0, 0.5, "blue"],
]

# ---------------------------------------------------------------------------

func _ready():
	spawn_level(GameManager.current_level)

func spawn_level(level_num: int):
	for child in get_children():
		child.queue_free()
	await get_tree().process_frame
	var layout: Array
	match level_num:
		1: layout = level_1
		2: layout = level_2
		3: layout = level_3
		_:
			push_error("PegSpawner: No layout defined for level " + str(level_num))
			return

	# Randomly assign ~20% of pegs as orange
	var orange_count = max(1, int(layout.size() * 0.20))
	var shuffled_indices = range(layout.size())
	shuffled_indices = Array(shuffled_indices)
	shuffled_indices.shuffle()
	var orange_indices = shuffled_indices.slice(0, orange_count)

	for i in range(layout.size()):
		var entry = layout[i]
		var x    = entry[0]
		var y    = entry[1]
		var type = "orange" if i in orange_indices else entry[2]

		var peg_scene = _get_scene_for_type(type)
		if peg_scene == null:
			continue

		var peg = peg_scene.instantiate()
		peg.peg_type = type  # SET BEFORE add_child
		add_child(peg)
		peg.position = Vector3(x, y, 0.0)

	# Wait one frame so all pegs finish _ready() and join their groups
	# THEN tell GameManager the real orange count
	await get_tree().process_frame
	GameManager.total_orange_pegs = get_tree().get_nodes_in_group("orange_pegs").size()
	print("Level ", level_num, " loaded. Orange pegs: ", GameManager.total_orange_pegs)

func _get_scene_for_type(type: String) -> PackedScene:
	match type:
		"blue":   return blue_peg_scene
		"orange": return orange_peg_scene
		"green":  return green_peg_scene
	return null
