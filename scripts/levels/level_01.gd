extends Node2D

func _ready() -> void:
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
