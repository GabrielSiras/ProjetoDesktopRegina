extends Button

@export var action_name: String = ""

var is_listening: bool = false

func _ready() -> void:
	assert(action_name != "", "Error: You must set an action_name in the Inspector!")
	process_mode = Node.PROCESS_MODE_ALWAYS
	
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
		
	if event is InputEventMouseButton:
		return
		
	if event is InputEventKey and event.is_pressed():
		InputMap.action_erase_events(action_name)
		
		InputMap.action_add_event(action_name, event)
		
		if "saved_controls" in InputSettings:
			InputSettings.saved_controls[action_name] = event
		
		button_pressed = false
		
		get_viewport().set_input_as_handled()
