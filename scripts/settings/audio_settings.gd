extends Node

var saved_volumes: Dictionary = {}
@onready var button_click_sfx: AudioStreamPlayer = $ButtonClickSFX

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	_connect_existing_buttons(get_tree().root)

func _on_node_added(node: Node) -> void:
	if node is Button:
		if not node.pressed.is_connected(_on_button_pressed):
			node.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	if button_click_sfx:
		button_click_sfx.play()

func _connect_existing_buttons(root_node: Node) -> void:
	for child in root_node.get_children():
		if child is Button:
			if not child.pressed.is_connected(_on_button_pressed):
				child.pressed.connect(_on_button_pressed)
		_connect_existing_buttons(child)
