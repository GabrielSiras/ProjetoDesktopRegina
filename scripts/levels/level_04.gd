extends Node2D

@export var level_music: AudioStream
@export var music_volume_db: float = -15

func _ready() -> void:
	if level_music and has_node("/root/AudioSettings"):
		AudioSettings.play_music(level_music, music_volume_db)

func _process(delta: float) -> void:
	pass
