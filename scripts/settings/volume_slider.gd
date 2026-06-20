extends HSlider

@export var audio_bus_name: String
var audio_bus_id: int

func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	
	if AudioSettings.saved_volumes.has(audio_bus_name):
		value = AudioSettings.saved_volumes[audio_bus_name]
	else:
		var db = AudioServer.get_bus_volume_db(audio_bus_id)
		value = db_to_linear(db)

func _on_value_changed(new_value: float) -> void:
	var db = linear_to_db(new_value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
	AudioServer.set_bus_mute(audio_bus_id, new_value == 0)

	AudioSettings.saved_volumes[audio_bus_name] = new_value
