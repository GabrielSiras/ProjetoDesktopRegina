extends BaseEnemy
class_name Spider

@onready var main = get_tree().current_scene
@onready var projectile = preload("res://scenes/actors/enemies/web_projectile.tscn")
@onready var timer: Timer = $Timer

var base_scale: Vector2
var pop_tween: Tween
var is_weaving_web: bool = false

func _ready() -> void:
	super._ready()
	
	AFFECTED_BY_GRAVITY = false
	SPEED = 0
	target_player = null
	
	base_scale = scale
	
	timer.stop()

func _on_field_of_view_body_entered(body: Node2D) -> void:
	if body is Player:
		target_player = body
		shoot_web()
		timer.start()

func _on_field_of_view_body_exited(body: Node2D) -> void:
	if body is Player:
		target_player = null
		timer.stop()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.is_dashing:
			return
		
		print("Aranha pegou a Regina!")
		body.die()

func _process(delta: float) -> void:
	if target_player != null:
		look_at(target_player.global_position)

func shoot_web() -> void:
	if target_player == null:
		return
	
	if is_weaving_web:
		return
	
	is_weaving_web = true
	
	var instance: WebProjectile = projectile.instantiate()
	
	add_child(instance)
	instance.position = Vector2(0, 0)
	instance.z_index = z_index - 1
	
	await instance.weave_animation()
	
	if target_player == null:
		instance.queue_free()
		is_weaving_web = false
		return
	
	var start_global_position := instance.global_position
	var shoot_direction: Vector2 = start_global_position.direction_to(target_player.global_position)
	
	instance.reparent(main)
	instance.global_position = start_global_position
	
	instance.launch(shoot_direction, z_index - 1)
	play_shoot_pop()
	
	is_weaving_web = false

func play_shoot_pop() -> void:
	if pop_tween:
		pop_tween.kill()
	
	scale = base_scale
	
	pop_tween = create_tween()
	pop_tween.tween_property(self, "scale", base_scale * 1.15, 0.06)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	pop_tween.tween_property(self, "scale", base_scale, 0.10)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)

func _on_timer_timeout() -> void:
	shoot_web()
