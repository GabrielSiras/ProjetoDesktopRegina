extends Node

var saved_controls: Dictionary = {}

func _ready() -> void:
	for action in saved_controls.keys():
		var saved_event = saved_controls[action]
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, saved_event)
