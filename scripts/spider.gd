extends BaseEnemy
class_name Spider

@onready var main = get_tree().current_scene
@onready var projectile = preload("res://scenes/actors/enemies/web_projectile.tscn")
@onready var timer: Timer = $Timer

@export var respawn_time: float = 5.0

var detection_radius: float = 150.0
var start_position: Vector2
var start_rotation: float
var base_scale: Vector2
var is_weaving_web: bool = false
var respawn_timer: Timer 

func _ready() -> void:
	super._ready()
	AFFECTED_BY_GRAVITY = false
	SPEED = 0
	
	start_position = global_position
	start_rotation = rotation
	base_scale = scale
	timer.stop()

	var fov_shape = find_child("field_of_view", true, false).find_child("CollisionShape2D", true, false) if find_child("field_of_view", true, false) else null
	if fov_shape and fov_shape.shape is CircleShape2D:
		detection_radius = fov_shape.shape.radius

	add_to_group("enemies")
	respawn_timer = Timer.new()
	add_child(respawn_timer)
	respawn_timer.wait_time = respawn_time
	respawn_timer.one_shot = true
	respawn_timer.timeout.connect(respawn)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Player and not body.is_dashing:
		print("Aranha pegou a Regina!")
		body.die()

func _process(_delta: float) -> void:
	if not visible: return
		
	var regina = main.find_child("Regina", true, false)
	if regina:
		var distance = global_position.distance_to(regina.global_position)
		if distance <= detection_radius:
			if target_player == null:
				target_player = regina
				shoot_web()
				timer.start()
			look_at(regina.global_position)
		elif target_player != null:
			target_player = null
			timer.stop()

func shoot_web() -> void:
	if target_player == null or is_weaving_web: return
	
	is_weaving_web = true
	var instance: WebProjectile = projectile.instantiate()
	add_child(instance)
	instance.position = Vector2.ZERO
	instance.z_index = z_index - 1
	
	await instance.weave_animation()
	
	if not visible or target_player == null:
		if is_instance_valid(instance): instance.queue_free()
		is_weaving_web = false
		return
	
	var start_pos := instance.global_position
	var shoot_dir := start_pos.direction_to(target_player.global_position)
	
	instance.reparent(main)
	instance.global_position = start_pos
	instance.launch(shoot_dir, z_index - 1)
	
	var tween = create_tween().set_parallel(false)
	tween.tween_property(self, "scale", base_scale * 1.15, 0.06).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", base_scale, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	is_weaving_web = false

func _on_timer_timeout() -> void:
	shoot_web()

func toggle_collisions(disable: bool) -> void:
	for node in ["CollisionShape2D", "Hurtbox/CollisionShape2D"]:
		var shape = get_node_or_null(node)
		if shape: shape.set_deferred("disabled", disable)

func on_death() -> void:
	visible = false
	set_process(true)
	set_physics_process(false)
	timer.stop()
	target_player = null
	is_weaving_web = false
	
	for child in get_children():
		if child is WebProjectile: child.queue_free()
	
	toggle_collisions(true)
	respawn_timer.start()

func respawn() -> void:
	global_position = start_position
	scale = base_scale
	rotation = start_rotation
	is_weaving_web = false
	target_player = null
	
	if "current_health" in self: current_health = max_health
	
	toggle_collisions(false)
	set_process(true)
	set_physics_process(true)
	visible = true
	respawn_timer.stop()
