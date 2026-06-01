extends Panel

@export var audio_bus_name: String = "Master"
var audio_bus_id: int

@onready var check_button: CheckButton = $CheckButton

func _ready() -> void:
	visible = false
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	
	var mode = DisplayServer.window_get_mode()
	if check_button:
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			check_button.button_pressed = true
		else:
			check_button.button_pressed = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	visible = !visible
	get_tree().paused = visible

func _on_voltar_pressed() -> void:
	if get_tree().paused:
		toggle_pause()
	else:
		visible = false
		var pai = get_parent()
		if pai and pai.has_node("Botões"):
			pai.get_node("Botões").visible = true
		else:
			print("Erro: Não achei o nó 'Botões' no pai: ", pai.name if pai else "Nulo")

func _on_sair_pressed() -> void:
	get_tree().paused = false
	
	get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")
	
