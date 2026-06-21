extends BaseEnemy
class_name FloatingEnemy

@export var FLOAT_DISTANCE := 16.0
@export var FLOAT_SPEED := 2.0
@export var respawn_time: float = 5.0

var start_position := Vector2.ZERO
var start_scale: Vector2
var time := 0.0
var respawn_timer: Timer
var can_play_respawn_sfx := false

func _ready() -> void:
	super._ready()
	
	base_sprite = $Sprite2D
	AFFECTED_BY_GRAVITY = false
	SPEED /= 2
	
	start_position = global_position
	start_scale = scale
	
	add_to_group("enemies")
	respawn_timer = Timer.new()
	add_child(respawn_timer)
	respawn_timer.wait_time = respawn_time
	respawn_timer.one_shot = true
	respawn_timer.timeout.connect(respawn)
	
	can_play_respawn_sfx = false

func _exit_tree() -> void:
	can_play_respawn_sfx = false
	if respawn_timer and respawn_timer.is_inside_tree():
		respawn_timer.stop()

func _physics_process(delta: float) -> void:
	time += delta
	
	if target_player == null:
		var regina = get_tree().get_first_node_in_group("player")
		if not regina:
			regina = get_tree().current_scene.find_child("Regina", true, false)
			
		var fov_area = find_child("Field_of_view", true, false) 
		if regina and fov_area:
			var max_distance = 150.0
			var fov_shape = fov_area.find_child("CollisionShape2D", true, false)
			if fov_shape and fov_shape.shape is CircleShape2D:
				max_distance = fov_shape.shape.radius
			
			if global_position.distance_to(regina.global_position) <= max_distance:
				target_player = regina

	super(delta)
	
	if target_player == null:
		global_position.y = start_position.y + sin(time * FLOAT_SPEED) * FLOAT_DISTANCE
	else:
		velocity.y += sin(time * FLOAT_SPEED) * 5.0

func chase_target() -> void:
	if target_player:
		var direction = (target_player.global_position - global_position).normalized()
		velocity = direction * SPEED
		if base_sprite and direction.x != 0:
			base_sprite.flip_h = direction.x < 0

func toggle_collisions(disable: bool) -> void:
	for node in ["CollisionShape2D", "Hurtbox/CollisionShape2D"]:
		var shape = get_node_or_null(node)
		if shape: shape.set_deferred("disabled", disable)

func on_death() -> void:
	if has_node("DeathSFX"):
		$DeathSFX.play()

	visible = false
	set_process(false)
	set_physics_process(false)
	target_player = null
	
	toggle_collisions(true)
	
	can_play_respawn_sfx = true
	respawn_timer.start()
	
func respawn() -> void:
	global_position = start_position
	scale = start_scale
	time = 0.0 
	velocity = Vector2.ZERO
	target_player = null
	
	if "current_health" in self: current_health = max_health
		
	toggle_collisions(false)
	set_process(true)
	set_physics_process(true)
	visible = true
	
	if can_play_respawn_sfx and respawn_timer and respawn_timer.time_left <= 0.1:
		if has_node("RespawnSFX"):
			$RespawnSFX.play()
	
	if respawn_timer: respawn_timer.stop()
	can_play_respawn_sfx = false
