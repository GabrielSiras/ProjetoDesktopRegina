extends Node

var last_checkpoint_scene: String = ""
var last_checkpoint_position: Vector2 = Vector2.ZERO

# Guarda também os limites da câmera daquela sala para reposicionar a câmera ao reviver!
var last_room_left: float
var last_room_right: float
var last_room_top: float
var last_room_bottom: float
# NOVA: Guarda o "nível de progresso" da última sala salva
var last_room_index: int = -1

func save_checkpoint(scene_path: String, player_pos: Vector2, left: float, right: float, top: float, bottom: float, room_index: int) -> void:
	# A MAGICA ESTÁ AQUI: Se a sala nova tiver um índice MENOR do que a sala que já salvamos,
	# significa que o jogador caiu ou voltou para trás. Bloqueamos o salvamento!
	if room_index < last_room_index:
		print("Checkpoint recusado! O jogador voltou para uma sala antiga (Sala ", room_index, " < Sala ", last_room_index, ")")
		return
		
	# Se for maior ou igual, salva o progresso normalmente
	last_checkpoint_scene = scene_path
	last_checkpoint_position = player_pos
	last_room_left = left
	last_room_right = right
	last_room_top = top
	last_room_bottom = bottom
	last_room_index = room_index # Atualiza o maior progresso alcançado
	print("Checkpoint AVANÇADO salvo! Sala Índice: ", room_index)

func respawn_player() -> void:
	if last_checkpoint_scene == "":
		# Se morreu logo na primeira sala e não passou por nenhuma transição ainda, só recarrega a cena atual
		get_tree().reload_current_scene()
		return
		
	# 1. Se a Regina morreu, nós apenas teleportamos ela de volta para a entrada da última sala salva
	var regina = get_tree().current_scene.find_child("Regina", true, false)
	if regina:
		regina.velocity = Vector2.ZERO
		regina.global_position = last_checkpoint_position
		if "current_health" in regina:
			regina.current_health = regina.max_health # Cura ela!
		if regina.has_method("revive"): # Se você tiver uma função de reviver para resetar animações
			regina.revive()
			
	# 2. Forçamos a câmera a focar e travar nos limites corretos daquela sala imediatamente
	var camera = get_tree().current_scene.find_child("GameCamera", true, false)
	if camera and camera.has_method("force_room_start"):
		camera.force_room_start(last_room_left, last_room_right, last_room_top, last_room_bottom)
		
	# 3. Avisamos todos os monstros da fase para darem respawn nos seus lugares originais!
	get_tree().call_group("enemies", "respawn")
	
	# Adicione isso no final do seu GameManager.gd
func reset_checkpoint_progression() -> void:
	last_room_index = -1
	last_checkpoint_scene = ""
	last_checkpoint_position = Vector2.ZERO
	print("Progresso de checkpoints resetado com sucesso para uma nova fase!")
