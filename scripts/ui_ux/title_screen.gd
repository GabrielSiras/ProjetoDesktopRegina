extends Control

@onready var opções: CanvasLayer = $Opções
@onready var music_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var botões: VBoxContainer = $Botões

func _ready() -> void:
	botões.visible = true
	opções.hide()
	
func _on_começar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/Level_00.tscn")

func _on_creditos_pressed() -> void:
	pass

func _on_configurações_pressed() -> void:
	print("Clicou no botão! Escondendo botões principais...")
	botões.visible = false
	print("Tentando mostrar as opções...")
	opções.show()

func _on_sairdojogo_pressed() -> void:
	get_tree().quit()

func _on_voltar_pressed() -> void:
	opções.hide()
	botões.visible = true

func _on_back_2_pressed() -> void:
	opções.hide()
	botões.visible = true
