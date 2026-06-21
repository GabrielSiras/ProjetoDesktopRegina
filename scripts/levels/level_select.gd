extends Control

func _ready() -> void:
	pass

func _on_btn_fase_1_pressed() -> void:
	GameManager.reset_checkpoint_progression()
	get_tree().change_scene_to_file("res://scenes/levels/Level_01.tscn")

func _on_btn_fase_2_pressed() -> void:
	GameManager.reset_checkpoint_progression()
	get_tree().change_scene_to_file("res://scenes/levels/Level_02.tscn")
