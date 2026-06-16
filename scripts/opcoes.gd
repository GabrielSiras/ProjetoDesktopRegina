extends Panel

@export var audio_bus_name: String = "Master"
var audio_bus_id: int

# --- NEW PANEL REFERENCES ---
# Remember to match these names with your Scene Tree nodes!
@onready var main_panel: Control = $VBoxContainer
@onready var settings_panel: Control = $Settings

@onready var check_button: CheckButton = %FullscreenControl

func _ready() -> void:
	visible = false
	# Make sure the sub-panel starts hidden
	if settings_panel:
		settings_panel.visible = false
		
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
	
	# RESET PANELS UPON PAUSE/UNPAUSE
	# When opening or closing, force the main menu to show and the sub-panel to hide
	if visible:
		main_panel.visible = true
		settings_panel.visible = false

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
	get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")

# --- SETTINGS TRANSITIONS ---

# This triggers when clicking "Configurações" on the main pause menu
func _on_settings_pressed() -> void:
	main_panel.visible = false
	settings_panel.visible = true

# This is your 'back2' - the back button INSIDE the sub-settings panel
func _on_back_2_pressed() -> void:
	settings_panel.visible = false
	main_panel.visible = true
