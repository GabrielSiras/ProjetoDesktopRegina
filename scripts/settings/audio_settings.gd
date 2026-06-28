extends Node

var saved_volumes: Dictionary = {}
var music_player: AudioStreamPlayer

@onready var button_click_sfx: AudioStreamPlayer = $ButtonClickSFX

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.bus = "Music"
	
	get_tree().node_added.connect(_on_node_added)
	_connect_existing_buttons(get_tree().root)

func play_music(music_stream: AudioStream, volume: float = 0.0) -> void:
	if music_stream == null:
		music_player.stop()
		music_player.stream = null
		return

	if music_player.stream != music_stream:
		music_player.stream = music_stream
		music_player.volume_db = volume
		music_player.play()
	else:
		music_player.volume_db = volume
		if not music_player.playing:
			music_player.play()

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
