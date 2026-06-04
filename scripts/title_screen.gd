extends Control

@onready var music_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var opções: Panel = $Opções
@onready var botões: VBoxContainer = $Botões

func _ready() -> void:
	botões.visible = true
	opções.visible = false

func _on_começar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/Level_01.tscn")

func _on_creditos_pressed() -> void:
	pass

func _on_opções_pressed() -> void:
	botões.visible = false
	opções.visible = true

func _on_sairdojogo_pressed() -> void:
	get_tree().quit()

func _on_voltar_pressed() -> void:
	opções.visible = false
	botões.visible = true
