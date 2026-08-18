# EnvironmentManager.gd
# Autoload singleton. Swaps the background sky plane's texture per level.
# Add this as an Autoload in Project Settings, ABOVE GameManager.
extends Node

@export var level_1_sky: Texture2D
@export var level_2_sky: Texture2D
@export var level_3_sky: Texture2D

var sky_plane: MeshInstance3D = null

func register_sky_plane(plane: MeshInstance3D):
	# Call this from node_3d.gd's _ready() so this manager knows which
	# background plane belongs to the currently loaded level scene.
	sky_plane = plane
	apply_for_level(GameManager.current_level)

func apply_for_level(level_num: int):
	if sky_plane == null:
		return

	var sky_tex = _get_sky_for_level(level_num)
	if sky_tex == null:
		return

	var mat = sky_plane.get_surface_override_material(0)
	if mat == null:
		mat = sky_plane.mesh.surface_get_material(0)

	if mat is StandardMaterial3D:
		# Duplicate so we don't overwrite the shared original resource
		var new_mat = mat.duplicate()
		new_mat.albedo_texture = sky_tex
		sky_plane.set_surface_override_material(0, new_mat)
	else:
		push_warning("EnvironmentManager: sky plane's material isn't a StandardMaterial3D, can't swap texture automatically.")

func _get_sky_for_level(level_num: int) -> Texture2D:
	match level_num:
		1: return level_1_sky
		2: return level_2_sky
		3: return level_3_sky
	return null
