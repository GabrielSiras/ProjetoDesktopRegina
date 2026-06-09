extends Camera2D

@export var chase_speed: float = 6.0
@export var time_transition: float = 0.35
@export var push_force: float = 14.0

var player: Node2D
var in_transition: bool = false

var current_room_left: float
var current_room_right: float
var current_room_top: float
var current_room_bottom: float

func _ready() -> void:
	player = get_tree().current_scene.find_child("Regina", true, false)
	if player:
		global_position = player.global_position

func _process(delta: float) -> void:
	if player and not in_transition:
		var target_x = player.global_position.x
		var target_y = player.global_position.y
		
		target_x = clamp(target_x, current_room_left + (640.0 / 2.0), current_room_right - (640.0 / 2.0))
		target_y = clamp(target_y, current_room_top + (360.0 / 2.0), current_room_bottom - (360.0 / 2.0))
		
		if (current_room_right - current_room_left) <= 640.0:
			target_x = current_room_left + (640.0 / 2.0)
		if (current_room_bottom - current_room_top) <= 360.0:
			target_y = current_room_top + (360.0 / 2.0)
			
		var target_position = Vector2(target_x, target_y)
		global_position = global_position.lerp(target_position, chase_speed * delta)

func force_room_start(left: float, right: float, top: float, bottom: float) -> void:
	current_room_left = left
	current_room_right = right
	current_room_top = top
	current_room_bottom = bottom
	
	limit_left = int(left)
	limit_right = int(right)
	limit_top = int(top)
	limit_bottom = int(bottom)
	
	if player:
		var destination_x = clamp(player.global_position.x, left + (640.0 / 2.0), right - (640.0 / 2.0))
		var destination_y = clamp(player.global_position.y, top + (360.0 / 2.0), bottom - (360.0 / 2.0))
		if (right - left) <= 640.0: destination_x = left + (640.0 / 2.0)
		if (bottom - top) <= 360.0: destination_y = top + (360.0 / 2.0)
		global_position = Vector2(destination_x, destination_y)

func change_room_boundaries(left: float, right: float, top: float, bottom: float) -> void:
	if in_transition: return
	in_transition = true
	
	get_tree().paused = true
	
	current_room_left = left
	current_room_right = right
	current_room_top = top
	current_room_bottom = bottom
	
	var destination_x = clamp(player.global_position.x, left + (640.0 / 2.0), right - (640.0 / 2.0))
	var destination_y = clamp(player.global_position.y, top + (360.0 / 2.0), bottom - (360.0 / 2.0))
	
	if (right - left) <= 640.0: destination_x = left + (640.0 / 2.0)
	if (bottom - top) <= 360.0: destination_y = top + (360.0 / 2.0)
	
	var destination_position = Vector2(destination_x, destination_y)

	if player:
		var diff = destination_position - global_position
		if abs(diff.x) > abs(diff.y):
			var side_direction = sign(diff.x)
			player.global_position.x += side_direction * push_force
		else:
			var vert_direction = sign(diff.y)
			player.global_position.y += vert_direction * push_force

	limit_left = int(min(limit_left, left))
	limit_right = int(max(limit_right, right))
	limit_top = int(min(limit_top, top))
	limit_bottom = int(max(limit_bottom, bottom))

	var tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE) 
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", destination_position, time_transition)
	
	tween.tween_callback(func():
		limit_left = int(left)
		limit_right = int(right)
		limit_top = int(top)
		limit_bottom = int(bottom)
		in_transition = false
		get_tree().paused = false
	)
