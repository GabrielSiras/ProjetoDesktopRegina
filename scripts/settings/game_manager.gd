extends Node

var last_checkpoint_scene: String = ""
var last_checkpoint_position: Vector2 = Vector2.ZERO

var last_room_left: float
var last_room_right: float
var last_room_top: float
var last_room_bottom: float
var last_room_index: int = -1

var sword_unlocked := false
var max_unlocked_level: int = 1

func save_checkpoint(scene_path: String, player_pos: Vector2, left: float, right: float, top: float, bottom: float, room_index: int) -> void:
	if room_index < last_room_index:
		return
		
	last_checkpoint_scene = scene_path
	last_checkpoint_position = player_pos
	last_room_left = left
	last_room_right = right
	last_room_top = top
	last_room_bottom = bottom
	last_room_index = room_index

func respawn_player() -> void:
	if last_checkpoint_scene == "":
		get_tree().reload_current_scene()
		return
		
	var regina = get_tree().current_scene.find_child("Regina", true, false)
	if regina:
		regina.velocity = Vector2.ZERO
		regina.global_position = last_checkpoint_position
		if "current_health" in regina:
			regina.current_health = regina.max_health
		if regina.has_method("revive"): 
			regina.revive()
			
	var camera = get_tree().current_scene.find_child("GameCamera", true, false)
	if camera and camera.has_method("force_room_start"):
		camera.force_room_start(last_room_left, last_room_right, last_room_top, last_room_bottom)
		
	get_tree().call_group("enemies", "respawn")
	
func reset_checkpoint_progression() -> void:
	last_room_index = -1
	last_checkpoint_scene = ""
	last_checkpoint_position = Vector2.ZERO
