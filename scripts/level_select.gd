extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	$HBoxContainer/BtnFase1.pressed.connect(_on_fase_1_pressed)
	$HBoxContainer/BtnFase2.pressed.connect(_on_fase_2_pressed)

func _on_fase_1_pressed() -> void:
	# Carrega a primeira fase do jogo
	get_tree().change_scene_to_file("res://scenes/levels/devroom.tscn")

func _on_fase_2_pressed() -> void:
	# Carrega a segunda fase (coloque o caminho correto da sua cena)
	get_tree().change_scene_to_file("res://scenes/levels/level_select.tscn")
