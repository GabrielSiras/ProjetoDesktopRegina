extends CharacterBody2D
class_name CharacterBase

@export_group("Base health")
@export var max_health := 3
var current_health := max_health
var is_invincible := false

var base_sprite: Node2D

func _physics_process(delta: float) -> void:
	if is_invincible and base_sprite:
		base_sprite.modulate.a = 0.4 if Engine.get_frames_drawn() % 10 < 5 else 1.0
	elif base_sprite:
		base_sprite.modulate.a = 1.0

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func take_damage(amount: int) -> void:
	if is_invincible:
		return
	
	die()

func active_imunity(time: float) -> void:
	is_invincible = true
	await get_tree().create_timer(time).timeout
	is_invincible = false

func _on_damage_taken() -> void:
	pass

func die() -> void:
	print(name, " morreu!")
