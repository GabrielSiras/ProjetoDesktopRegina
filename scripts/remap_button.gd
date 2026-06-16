extends Button

@export var action_name: String = ""

var is_listening: bool = false

func _ready() -> void:
	assert(action_name != "", "Error: You must set an action_name in the Inspector!")
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# ISSO AQUI resolve a briga do Espaço no Godot 4!
	# Impede que as teclas Espaço/Enter cliquem no botão enquanto ele estiver focado.
	shortcut_feedback = false
	
	set_process_input(false)
	update_button_text()

func update_button_text() -> void:
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		text = events[0].as_text().get_slice(" (", 0)
	else:
		text = "None"

func _toggled(toggled_on: bool) -> void:
	is_listening = toggled_on
	if is_listening:
		text = "... Aperte uma Tecla ..."
		set_process_input(true)
	else:
		update_button_text()
		set_process_input(false)

func _input(event: InputEvent) -> void:
	if not is_listening:
		return
		
	# Ignora cliques de mouse para não bugar o início da escuta
	if event is InputEventMouseButton:
		return
		
	# Se for qualquer tecla do teclado pressionada
	if event is InputEventKey and event.is_pressed():
		# 1. Remove os controles antigos
		InputMap.action_erase_events(action_name)
		
		# 2. Adiciona a nova tecla (funciona com Espaço, Letras, Setas, etc.)
		InputMap.action_add_event(action_name, event)
		
		# 3. Salva no Autoload para persistir entre as fases
		if "saved_controls" in InputSettings:
			InputSettings.saved_controls[action_name] = event
		
		# 4. Desliga o botão (Toggle) de volta para o estado normal
		button_pressed = false
		
		# Consome o input para o Godot saber que já terminamos
		get_viewport().set_input_as_handled()
