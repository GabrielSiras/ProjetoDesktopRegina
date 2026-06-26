extends Area2D

@export_file("*.tscn") var next_phase_path: String
@export var current_level_number: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var next_unlocked = current_level_number + 1
		
		if GameManager.max_unlocked_level < next_unlocked:
			GameManager.max_unlocked_level = next_unlocked
			
		if next_phase_path != "":
			print("Fase concluída! Carregando: ", next_phase_path)
			get_tree().call_deferred("change_scene_to_file", next_phase_path)
		else:
			print("Aviso: Caminho da próxima fase não foi definido. Indo para o menu de seleção.")
			get_tree().call_deferred("change_scene_to_file", "res://scenes/levels/level_select.tscn")
