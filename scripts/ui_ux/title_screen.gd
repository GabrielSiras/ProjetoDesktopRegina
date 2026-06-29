extends Control

@export var menu_music: AudioStream
@export var menu_volume_db: float = 0.0 #

@onready var opções: CanvasLayer = $Opções
@onready var botões: VBoxContainer = $Botões
@onready var créditos: CanvasLayer = $Créditos

func _ready() -> void:
	botões.visible = true
	créditos.hide()
	opções.hide()
	
	if menu_music and has_node("/root/AudioSettings"):
		AudioSettings.play_music(menu_music, menu_volume_db)
	
func _on_começar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/Level_00.tscn")

func _on_creditos_pressed() -> void:
	botões.visible = false
	créditos.show()

func _on_configurações_pressed() -> void:
	botões.visible = false
	opções.show()

func _on_sairdojogo_pressed() -> void:
	get_tree().quit()

func _on_voltar_pressed() -> void:
	opções.hide()
	botões.visible = true

func _on_back_2_pressed() -> void:
	opções.hide()
	botões.visible = true

func _on_back_pressed() -> void:
	créditos.hide()
	botões.visible = true
