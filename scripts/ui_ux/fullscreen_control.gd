extends CheckButton

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		# O EXCLUSIVE_FULLSCREEN resolve problemas de janelas presas e bordas
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
