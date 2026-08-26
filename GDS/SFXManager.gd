# SFXManager.gd
# Autoload singleton. Handles one-shot sound effects per the GDD's Audio
# Direction (sec 9.2). Add this as an Autoload in Project Settings.
extends Node

@export var launch_sfx: AudioStream          # ball launch "whoosh"
@export var blue_peg_sfx: AudioStream        # light "tink"
@export var milk_peg_sfx: AudioStream        # richer "splash-pop"
@export var green_peg_sfx: AudioStream       # power-up chime
@export var multiplier_stinger_sfx: AudioStream  # rising pitch stinger, per orange hit in a chain
@export var truck_catch_sfx: AudioStream     # horn + jingle
@export var level_clear_sfx: AudioStream     # fanfare + moo
@export var fail_sfx: AudioStream            # sad trombone + moo

func play_sfx(stream: AudioStream, pitch: float = 1.0, volume_db: float = 0.0):
	if stream == null:
		return  # silently skip if this sound hasn't been assigned yet
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.pitch_scale = pitch
	player.volume_db = volume_db
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()

func play_launch():
	play_sfx(launch_sfx)

func play_peg_hit(peg_type: String):
	match peg_type:
		"blue":
			play_sfx(blue_peg_sfx)
		"orange":
			play_sfx(milk_peg_sfx)
		"green":
			play_sfx(green_peg_sfx)

func play_multiplier_stinger(multiplier: int):
	# Rising pitch stinger per the GDD - each successive orange hit in a
	# chain plays a bit higher than the last.
	var pitch = 1.0 + (float(multiplier - 1) * 0.12)
	pitch = clamp(pitch, 1.0, 2.2)
	play_sfx(multiplier_stinger_sfx, pitch)

func play_truck_catch():
	play_sfx(truck_catch_sfx)

func play_level_clear():
	play_sfx(level_clear_sfx)

func play_fail():
	play_sfx(fail_sfx)
