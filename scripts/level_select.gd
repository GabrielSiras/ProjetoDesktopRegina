extends Control

func _ready() -> void:
	pass # Replace with function body.


func _on_btn_fase_1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/devroom.tscn")


func _on_btn_fase_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/game-basico.tscn")
