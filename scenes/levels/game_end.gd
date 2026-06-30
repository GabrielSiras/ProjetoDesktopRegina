extends Node2D

func _ready() -> void:

	var dialog_box = find_child("DialogueBox", true, false)

	if dialog_box:

		var introducao: Array[String] = [
		"REGINA: Até que enfim encontrei você, meu cavaleiro!",
		"CAVALEIRO: Ah... Regina? Meu amor... O que você está fazendo aqui?!",
		"REGINA: Vim te resgatar! Pelo menos... era o que eu achava.",
		"CAVALEIRO: Me resgatar? Ah... sim! Claro! Me ajuda, Regina!",
		"FEITICEIRO: Resgatar? Espera... você não falou com ela?",
		"REGINA: Falou o quê?",
		"CAVALEIRO: Eu posso explicar...",
		"FEITICEIRO: Eu falei que você devia ter terminado primeiro.",
		"REGINA: ...Terminado?",
		"CAVALEIRO: Não é o que parece!",
		"FEITICEIRO: É exatamente o que parece.",
		"REGINA: Eu atravessei um castelo cheio de espinhos e esqueletos...",
		"REGINA: Escapei de fantasmas...",
		"REGINA: Desviei de aranhas gigantes...",
		"REGINA: E quase morri umas milhões de vezes...",
		"REGINA: ...pra descobrir que você estava me traindo?",
		"CAVALEIRO: ...",
		"REGINA: ...",
		"REGINA: Você podia ter mandado uma carta pelo menos.",
		"CAVALEIRO: Regina, espera!",
		"REGINA: Não. Fiquem felizes juntos, estou indo embora.",
		"REGINA: E não que eu precise da sua permissão, mas estou levando a espada comigo.",
		"CAVALEIRO: ...",
		"REGINA: Seu merda!",
		"CAVALEIRO: É eu pisei na bola mesmo...",
		]
		dialog_box.start_dialogue(introducao)
