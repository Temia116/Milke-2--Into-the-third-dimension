# PegSpawner.gd
extends Node3D

@export var blue_peg_scene: PackedScene
@export var orange_peg_scene: PackedScene
@export var green_peg_scene: PackedScene

# ---------------------------------------------------------------------------
# LEVEL 1 — The Pasture (Tutorial)
# ---------------------------------------------------------------------------
var level_1 = [
	[-12, 3.0, "blue"], [-8, 3.0, "blue"], [-4, 3.0, "blue"], [0, 3.0, "blue"],
	[4, 3.0, "blue"], [8, 3.0, "blue"], [12, 3.0, "blue"],
	[-10, 1.5, "blue"], [-6, 1.5, "blue"], [-2, 1.5, "blue"], [2, 1.5, "blue"],
	[6, 1.5, "blue"], [10, 1.5, "blue"],
	[-12, 0.0, "blue"], [-8, 0.0, "blue"], [-4, 0.0, "blue"], [0, 0.0, "blue"],
	[4, 0.0, "blue"], [8, 0.0, "blue"], [12, 0.0, "blue"],
	[-10, -1.5, "blue"], [-6, -1.5, "blue"], [-2, -1.5, "blue"], [2, -1.5, "blue"],
	[6, -1.5, "blue"], [10, -1.5, "blue"],
	[-12, -3.0, "blue"], [-8, -3.0, "blue"], [-4, -3.0, "blue"], [0, -3.0, "blue"],
	[4, -3.0, "blue"], [8, -3.0, "blue"], [12, -3.0, "blue"],
	[-10, -4.5, "blue"], [-6, -4.5, "blue"], [-2, -4.5, "blue"], [2, -4.5, "blue"],
	[6, -4.5, "blue"], [10, -4.5, "blue"]
]

# ---------------------------------------------------------------------------
# LEVEL 2 — The Smile (Twin Arcs)
# ---------------------------------------------------------------------------
var level_2 = [
	[-9.51, 1.88, "blue"], [-8.09, 1.32, "blue"],
	[-5.88, 0.88, "blue"], [-3.09, 0.6, "blue"], [0.0, 0.5, "blue"],
	[3.09, 0.6, "blue"], [5.88, 0.88, "blue"], [8.09, 1.32, "blue"],
	[9.51, 1.88, "blue"],
	[10.0, -2.5, "blue"], [9.51, -1.88, "blue"], [8.09, -1.32, "blue"],
	[5.88, -0.88, "blue"], [3.09, -0.6, "blue"], [0.0, -0.5, "blue"],
	[-3.09, -0.6, "blue"], [-5.88, -0.88, "blue"], [-8.09, -1.32, "blue"],
	[-9.51, -1.88, "blue"], [-10.0, -2.5, "blue"],
	[-11, 1.0, "blue"], [-11, -0.5, "blue"], [-11, -2.0, "blue"],
	[11, 1.0, "blue"], [11, -0.5, "blue"], [11, -2.0, "blue"],
	[-6, -3.5, "blue"], [-3, -4.0, "blue"], [0, -4.2, "blue"],
	[3, -4.0, "blue"], [6, -3.5, "blue"],
]

# ---------------------------------------------------------------------------
# LEVEL 3 — The Rings (Twin Circles)
# ---------------------------------------------------------------------------
var level_3 = [
	# Left ring (12 pegs, full loop)
	[-1.0, -1.0, "blue"], [-1.54, 1.0, "blue"], [-3.0, 2.46, "blue"],
	[-5.0, 3.0, "blue"], [-7.0, 2.46, "blue"], [-8.46, 1.0, "blue"],
	[-9.0, -1.0, "blue"], [-8.46, -3.0, "blue"], [-7.0, -4.46, "blue"],
	[-5.0, -5.0, "blue"], [-3.0, -4.46, "blue"], [-1.54, -3.0, "blue"],
	# Right ring (12 pegs, full loop)
	[9.0, -1.0, "blue"], [8.46, 1.0, "blue"], [7.0, 2.46, "blue"],
	[5.0, 3.0, "blue"], [3.0, 2.46, "blue"], [1.54, 1.0, "blue"],
	[1.0, -1.0, "blue"], [1.54, -3.0, "blue"], [3.0, -4.46, "blue"],
	[5.0, -5.0, "blue"], [7.0, -4.46, "blue"], [8.46, -3.0, "blue"],
	# Bottom row
	[-10, -6.5, "blue"], [-7, -6.5, "blue"], [-4, -6.5, "blue"],
	[0, -6.5, "blue"], [4, -6.5, "blue"], [7, -6.5, "blue"], [10, -6.5, "blue"],
]

# ---------------------------------------------------------------------------

func _ready():
	spawn_level(GameManager.current_level)

func spawn_level(level_num: int):
	var layout: Array
	match level_num:
		1: layout = level_1
		2: layout = level_2
		3: layout = level_3
		_:
			push_error("PegSpawner: No layout defined for level " + str(level_num))
			return

	# Only randomize orange/green among entries that are still "blue" in the layout.
	var blue_indices = []
	for i in range(layout.size()):
		if layout[i][2] == "blue":
			blue_indices.append(i)

	var orange_count = max(1, int(blue_indices.size() * 0.35))
	var shuffled_indices = blue_indices.duplicate()
	shuffled_indices.shuffle()
	var orange_indices = shuffled_indices.slice(0, orange_count)

	# Pick exactly one remaining blue peg to become the green Power Peg -
	# but only if this level actually has a cow ability to grant.
	var green_index = -1
	if GameManager.get_cow_for_level(level_num) != "none":
		for idx in shuffled_indices:
			if not (idx in orange_indices):
				green_index = idx
				break

	for i in range(layout.size()):
		var entry = layout[i]
		var x    = entry[0]
		var y    = entry[1]
		var type = entry[2]
		if i in orange_indices:
			type = "orange"
		elif i == green_index:
			type = "green"

		var peg_scene = _get_scene_for_type(type)
		if peg_scene == null:
			continue

		var peg = peg_scene.instantiate()
		peg.peg_type = type  # SET BEFORE add_child
		add_child(peg)
		peg.position = Vector3(x, y, 0.0)

	await get_tree().process_frame
	GameManager.total_orange_pegs = get_tree().get_nodes_in_group("orange_pegs").size()
	print("Level ", level_num, " loaded. Orange pegs: ", GameManager.total_orange_pegs)

func _get_scene_for_type(type: String) -> PackedScene:
	match type:
		"blue":   return blue_peg_scene
		"orange": return orange_peg_scene
		"green":  return green_peg_scene
	return null
