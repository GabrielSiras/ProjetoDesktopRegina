extends Area2D

@export_file("*.tscn") var next_phase_path: String

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if next_phase_path != "":
			print("Fase concluída! Carregando: ", next_phase_path)
			get_tree().call_deferred("change_scene_to_file", next_phase_path)
		else:
			print("Aviso: Caminho da próxima fase não foi definido. Indo para o menu de seleção.")
			get_tree().call_deferred("change_scene_to_file", "res://scenes/levels/level_select.tscn")
