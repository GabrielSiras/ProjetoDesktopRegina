extends Control

func _ready() -> void:
	_update_level_buttons()
	
func _update_level_buttons() -> void:
	var max_level = GameManager.max_unlocked_level
	
	if has_node("Tutorial"): $Tutorial.disabled = (0 > max_level)
	if has_node("BtnFase1"): $BtnFase1.disabled = (1 > max_level)
	if has_node("BtnFase2"): $BtnFase2.disabled = (2 > max_level)
	if has_node("BtnFase3"): $BtnFase3.disabled = (3 > max_level)
	if has_node("BtnFase4"): $BtnFase4.disabled = (4 > max_level)
	if has_node("BtnFase5"): $BtnFase5.disabled = (5 > max_level)
	if has_node("BtnFase6"): $BtnFase6.disabled = (6 > max_level)

func _on_button_pressed() -> void:
	GameManager.reset_checkpoint_progression()
	get_tree().change_scene_to_file("res://scenes/levels/Level_00.tscn")
	
func _on_btn_fase_1_pressed() -> void:
	GameManager.reset_checkpoint_progression()
	get_tree().change_scene_to_file("res://scenes/levels/Level_01.tscn")

func _on_btn_fase_2_pressed() -> void:
	GameManager.reset_checkpoint_progression()
	get_tree().change_scene_to_file("res://scenes/levels/Level_02.tscn")

func _on_btn_fase_3_pressed() -> void:
	GameManager.reset_checkpoint_progression()
	get_tree().change_scene_to_file("res://scenes/levels/Level_03.tscn")

func _on_btn_fase_4_pressed() -> void:
	GameManager.reset_checkpoint_progression()
	get_tree().change_scene_to_file("res://scenes/levels/Level_04.tscn")

func _on_btn_fase_5_pressed() -> void:
	GameManager.reset_checkpoint_progression()
	get_tree().change_scene_to_file("res://scenes/levels/Level_05.tscn")

func _on_btn_fase_6_pressed() -> void:
	GameManager.reset_checkpoint_progression()
	get_tree().change_scene_to_file("res://scenes/levels/Level_06.tscn")
