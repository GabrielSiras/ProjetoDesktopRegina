extends Node2D

func _ready() -> void:
	await get_tree().physics_frame
	
	var dialog_box = find_child("DialogueBox", true, false)
	
	if dialog_box:
		# Lista de frases
		var introducao: Array[String] = [
			"...Como cheguei aqui?",
			"Preciso salvar meu cavaleiro!",
			"Essas paredes... parecem que estou em algum tipo de esgoto.",
			"Preciso tomar cuidado. Sinto que não estou sozinha aqui dentro...",
		]
		
		dialog_box.start_dialogue(introducao)
