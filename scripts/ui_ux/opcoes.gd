extends CanvasLayer

@export var audio_bus_name: String = "Master"
@export var sfx_bus_name: String = "SFX"
@onready var main_panel: Control = $UI_Container/VBoxContainer
@onready var settings_panel: Control = $Settings
@onready var check_button: CheckButton = %FullscreenControl
var sfx_bus_id: int
var audio_bus_id: int
var dialogue_was_visible := false

func _ready() -> void:
	visible = false
	
	if settings_panel:
		settings_panel.visible = false
		
	var config_vbox = get_node_or_null("Settings/ScrollContainer/VBoxContainer")
	if config_vbox:
		config_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	sfx_bus_id = AudioServer.get_bus_index(sfx_bus_name)
	
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
	var paused = !get_tree().paused
	get_tree().paused = paused
	visible = paused
	
	var dialogue_box = get_tree().current_scene.find_child("DialogueBox", true, false)
	
	if dialogue_box:
		if paused:
			dialogue_was_visible = dialogue_box.visible
			dialogue_box.visible = false
		else:
			dialogue_box.visible = dialogue_was_visible

func _on_back_pressed() -> void:
	if get_tree().paused:
		toggle_pause()
	else:
		visible = false
		var pai = get_parent()
		if pai and pai.has_node("Botões"):
			pai.get_node("Botões").visible = true
		else:
			print("Erro: Não achei o nó 'Botões' no pai: ", pai.name if pai else "Nulo")

func _on_leave_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui_ux/title_screen.tscn")

func _on_settings_pressed() -> void:
	main_panel.visible = false
	settings_panel.visible = true

func _on_back_2_pressed() -> void:
	settings_panel.visible = false
	main_panel.visible = true
