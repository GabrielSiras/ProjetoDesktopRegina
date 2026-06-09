extends Area2D

var room_left: float
var room_right: float
var room_top: float
var room_bottom: float

func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var shape = $CollisionShape2D.shape as RectangleShape2D
	if shape:
		var center = $CollisionShape2D.global_position
		var half_size = shape.size / 2.0
		
		room_left = center.x - half_size.x
		room_right = center.x + half_size.x
		room_top = center.y - half_size.y
		room_bottom = center.y + half_size.y
	
	body_entered.connect(_on_body_entered)
	
	for body in get_overlapping_bodies():
		if body is Player:
			_force_initial_room()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var camera = get_tree().current_scene.find_child("GameCamera", true, false)
		if camera and camera.has_method("change_room_boundaries"):
			if int(camera.limit_left) == int(room_left) and \
			   int(camera.limit_right) == int(room_right) and \
			   int(camera.limit_top) == int(room_top) and \
			   int(camera.limit_bottom) == int(room_bottom):
				return
				
			camera.change_room_boundaries(room_left, room_right, room_top, room_bottom)

func _force_initial_room() -> void:
	var camera = get_tree().current_scene.find_child("GameCamera", true, false)
	if camera and camera.has_method("force_room_start"):
		camera.force_room_start(room_left, room_right, room_top, room_bottom)
