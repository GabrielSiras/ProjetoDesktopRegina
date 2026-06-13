extends BaseEnemy
class_name FloatingEnemy

@export var FLOAT_DISTANCE := 16.0
@export var FLOAT_SPEED := 2.0
@export var respawn_time: float = 5.0

var start_position := Vector2.ZERO
var start_scale: Vector2
var time := 0.0
var respawn_timer: Timer

func _ready() -> void:
	super._ready()
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

func _physics_process(delta: float) -> void:
	time += delta
	super(delta)
	
	if target_player == null:
		global_position.y = start_position.y + sin(time * FLOAT_SPEED) * FLOAT_DISTANCE
	else:
		velocity.y += sin(time * FLOAT_SPEED) * 5.0 

func toggle_collisions(disable: bool) -> void:
	for node in ["CollisionShape2D", "Hurtbox/CollisionShape2D"]:
		var shape = get_node_or_null(node)
		if shape: shape.set_deferred("disabled", disable)

func on_death() -> void:
	visible = false
	set_process(false)
	set_physics_process(false)
	target_player = null
	
	toggle_collisions(true)
	respawn_timer.start()

func respawn() -> void:
	global_position = start_position
	scale = start_scale
	time = 0.0 
	
	if "current_health" in self: current_health = max_health
	
	var regina = get_tree().current_scene.find_child("Regina", true, false)
	var fov_area = find_child("field_of_view", true, false)
	
	target_player = regina if (regina and fov_area and fov_area.overlaps_body(regina)) else null
		
	toggle_collisions(false)
	set_process(true)
	set_physics_process(true)
	visible = true
	respawn_timer.stop()
