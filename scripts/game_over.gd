extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	$Reiniciar.pressed.connect(_on_btn_reiniciar_pressed)

func _on_btn_reiniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/devroom.tscn")
