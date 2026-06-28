extends BaseEnemy
class_name Skeleton

@export var respawn_time: float = 5.0
@export var bone_pile_offset_y: float = 10.0 

var start_position: Vector2
var start_scale: Vector2
var respawn_timer: Timer
var can_play_respawn_sfx := false
var is_dead_and_waiting := false

@onready var bone_pile: Sprite2D = $BonePile
var shake_time := 0.0
func _ready() -> void:
	can_play_respawn_sfx = false
	is_dead_and_waiting = false
	
	super._ready()
	base_sprite = $AnimatedSprite2D 
	max_health = 1
	current_health = max_health
	SPEED = 60.0
	
	start_position = global_position
	start_scale = scale
	add_to_group("enemies")
	
	if base_sprite and base_sprite.has_method("play"):
		base_sprite.play("skeleton-idle")
		base_sprite.visible = true
	
	if bone_pile:
		bone_pile.top_level = true
		bone_pile.global_position = start_position + Vector2(0, bone_pile_offset_y)
		bone_pile.visible = true 
	
	respawn_timer = Timer.new()
	add_child(respawn_timer)
	respawn_timer.wait_time = respawn_time
	respawn_timer.one_shot = true
	respawn_timer.timeout.connect(respawn)

func _physics_process(delta: float) -> void:
	if not is_dead_and_waiting:
		super(delta)
	else:
		velocity = Vector2.ZERO
	
	if not is_dead_and_waiting and base_sprite:
		# Garante que a pilha fique fixa no chão original enquanto ele caminha vivo
		if bone_pile:
			bone_pile.global_position = start_position + Vector2(0, bone_pile_offset_y)
			
		if velocity.x != 0:
			base_sprite.play("skeleton-walking")
			if velocity.x > 0:
				base_sprite.flip_h = false
			elif velocity.x < 0:
				base_sprite.flip_h = true
		else:
			base_sprite.play("skeleton-idle")
			
	elif is_dead_and_waiting and respawn_timer and respawn_timer.time_left > 0:
		shake_time += delta
		
		var progress: float = 1.0 - (respawn_timer.time_left / respawn_time)
		var shake_intensity: float = progress * progress * 4.0 
		var shake_speed: float = 20.0 + (progress * 30.0)
		
		if bone_pile:
			var ground_x = start_position.x + (sin(shake_time * shake_speed) * shake_intensity)
			bone_pile.global_position = Vector2(ground_x, start_position.y + bone_pile_offset_y)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Player and not body.is_dashing and not is_dead_and_waiting: 
		body.die()

func _on_field_of_view_body_entered(body: Node2D) -> void:
	if body is Player and not is_dead_and_waiting: 
		target_player = body

func _on_field_of_view_body_exited(body: Node2D) -> void:
	if body == target_player: target_player = null

func toggle_collisions(disable: bool) -> void:
	for node in ["CollisionShape2D", "Hurtbox/CollisionShape2D"]:
		var shape = get_node_or_null(node)
		if shape: shape.set_deferred("disabled", disable)

func on_death() -> void:
	if has_node("DeathSFX"):
		$DeathSFX.play()
	
	is_dead_and_waiting = true 
	if base_sprite: base_sprite.visible = false 
	
	target_player = null
	velocity = Vector2.ZERO
	toggle_collisions(true)
	can_play_respawn_sfx = true
	
	shake_time = 0.0
	if respawn_timer: respawn_timer.start()

func respawn() -> void:
	global_position = start_position
	scale = start_scale
	current_health = max_health
	velocity = Vector2.ZERO
	is_dead_and_waiting = false 
	
	if base_sprite:
		base_sprite.visible = true 
		if base_sprite.has_method("play"): 
			base_sprite.play("skeleton-idle")
		
	toggle_collisions(false)
	
	if can_play_respawn_sfx and respawn_timer and respawn_timer.time_left <= 0.1:
		if has_node("RespawnSFX"):
			$RespawnSFX.play()
	
	if respawn_timer: respawn_timer.stop()
	can_play_respawn_sfx = false
		
	var fov_area = find_child("Field_of_view", true, false)
	if fov_area and fov_area.has_method("get_overlapping_bodies"):
		for body in fov_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				target_player = body
				_on_field_of_view_body_entered(body)
				break
