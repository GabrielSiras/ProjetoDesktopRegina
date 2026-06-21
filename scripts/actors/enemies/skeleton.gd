extends BaseEnemy
class_name Skeleton

@export var respawn_time: float = 5.0

var start_position: Vector2
var start_scale: Vector2
var respawn_timer: Timer
var can_play_respawn_sfx := false

func _ready() -> void:
	can_play_respawn_sfx = false
	
	super._ready()
	base_sprite = $Sprite2D
	max_health = 1
	current_health = max_health
	SPEED = 60.0
	
	start_position = global_position
	start_scale = scale
	add_to_group("enemies")
	
	respawn_timer = Timer.new()
	add_child(respawn_timer)
	respawn_timer.wait_time = respawn_time
	respawn_timer.one_shot = true
	respawn_timer.timeout.connect(respawn)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Player and not body.is_dashing: body.die()

func _on_field_of_view_body_entered(body: Node2D) -> void:
	if body is Player: target_player = body

func _on_field_of_view_body_exited(body: Node2D) -> void:
	if body == target_player: target_player = null

func toggle_collisions(disable: bool) -> void:
	for node in ["CollisionShape2D", "Hurtbox/CollisionShape2D"]:
		var shape = get_node_or_null(node)
		if shape: shape.set_deferred("disabled", disable)

func on_death() -> void:
	if has_node("DeathSFX"):
		$DeathSFX.play()
	
	visible = false
	target_player = null
	velocity = Vector2.ZERO
	toggle_collisions(true)
	can_play_respawn_sfx = true
	
	if respawn_timer: respawn_timer.start()

func respawn() -> void:
	global_position = start_position
	scale = start_scale
	current_health = max_health
	velocity = Vector2.ZERO
	target_player = null
	
	if base_sprite and base_sprite.has_method("play"): base_sprite.play("idle")
		
	toggle_collisions(false)
	visible = true
	
	if can_play_respawn_sfx and respawn_timer and respawn_timer.time_left <= 0.1:
		if has_node("RespawnSFX"):
			
			$RespawnSFX.play()
	
	if respawn_timer: respawn_timer.stop()
	can_play_respawn_sfx = false
		
	var regina = get_tree().current_scene.find_child("Regina", true, false)
	var fov_area = find_child("field_of_view", true, false)
	if regina and fov_area and fov_area.overlaps_body(regina):
		_on_field_of_view_body_entered(regina)
