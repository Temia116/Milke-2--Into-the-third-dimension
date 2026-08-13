# MusicManager.gd
# Autoload singleton. Handles per-level background music.
# Add this as an Autoload in Project Settings so it's available everywhere.
extends Node

@export var level_1_track: AudioStream
@export var level_2_track: AudioStream
@export var level_3_track: AudioStream

@onready var player: AudioStreamPlayer = AudioStreamPlayer.new()

var current_level_playing: int = -1

func _ready():
	add_child(player)
	player.bus = "Master"  # change to a "Music" bus if you set one up later

func play_for_level(level_num: int):
	if level_num == current_level_playing and player.playing:
		return  # already playing the right track, don't restart it

	var track = _get_track_for_level(level_num)
	if track == null:
		player.stop()
		current_level_playing = -1
		return

	player.stream = track
	player.play()
	current_level_playing = level_num

func stop_music():
	player.stop()
	current_level_playing = -1

func _get_track_for_level(level_num: int) -> AudioStream:
	match level_num:
		1: return level_1_track
		2: return level_2_track
		3: return level_3_track
	return null
