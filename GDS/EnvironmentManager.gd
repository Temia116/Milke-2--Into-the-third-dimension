# EnvironmentManager.gd
# Autoload singleton. Swaps the background sky plane's texture per level.
# Add this as an Autoload in Project Settings, ABOVE GameManager.
extends Node

@export var level_1_sky: PanoramaSkyMaterial
@export var level_2_sky: PanoramaSkyMaterial
@export var level_3_sky: PanoramaSkyMaterial

var sky_planes: Array = []

func register_sky_planes(planes: Array):
	sky_planes = planes
	apply_for_level(GameManager.current_level)

func apply_for_level(level_num: int):
	var sky_mat = _get_sky_for_level(level_num)
	if sky_mat == null:
		print("EnvironmentManager: no sky material assigned for level ", level_num, " - check the Inspector slots")
		return

	var sky_tex = sky_mat.panorama
	if sky_tex == null:
		print("EnvironmentManager: sky material for level ", level_num, " has no panorama texture set")
		return

	for plane in sky_planes:
		if plane == null:
			continue
		var mat = plane.get_surface_override_material(0)
		if mat == null:
			mat = plane.mesh.surface_get_material(0)

		if mat is StandardMaterial3D:
			var new_mat = mat.duplicate()
			new_mat.albedo_texture = sky_tex
			plane.set_surface_override_material(0, new_mat)
		else:
			print("EnvironmentManager: material on ", plane.name, " is not a StandardMaterial3D: ", mat)

func _get_sky_for_level(level_num: int) -> PanoramaSkyMaterial:
	match level_num:
		1: return level_1_sky
		2: return level_2_sky
		3: return level_3_sky
	return null
