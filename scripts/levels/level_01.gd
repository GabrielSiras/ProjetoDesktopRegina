extends Node2D

@export var level_music: AudioStream
@export var music_volume_db: float = -15

func _ready() -> void:
	if level_music and has_node("/root/AudioSettings"):
		AudioSettings.play_music(level_music, music_volume_db)
	
	await get_tree().physics_frame
	
	var dialog_box = find_child("DialogueBox", true, false)
	
	if dialog_box:
		# Lista de frases
		var introducao: Array[String] = [
			"Este é o esgoto do castelo do mal!",
			"Meu cavalheiro deve ter sido raptado pelo vilão!",
			"Se deixou cair sua espada realmente deve estar em apuros, preciso resgata-lo!",
		]
		
		dialog_box.start_dialogue(introducao)
