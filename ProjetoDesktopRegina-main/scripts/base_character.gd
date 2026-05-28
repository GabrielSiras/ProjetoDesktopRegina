extends CharacterBody2D
class_name CharacterBase

@export_group("Base health")
@export var max_health := 3
var current_health := max_health
var is_invincible := false

var base_sprite: Node2D

# Efeito de piscar ao tomar dano:
func _physics_process(delta: float) -> void:
	if is_invincible and base_sprite:
		base_sprite.modulate.a = 0.4 if Engine.get_frames_drawn() % 10 < 5 else 1.0
	elif base_sprite:
		base_sprite.modulate.a = 1.0
		

# Gravidade:
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

# Controle de Dano:
func take_damage(amount: int) -> void:
	if is_invincible:
		return
		
	
	if self is Player and self.is_dashing:
		return
	
	current_health = clamp(current_health - amount, 0, max_health)
	_on_damage_taken()
	
	if current_health <= 0:
		die()
	else:
		active_imunity(1.5)

# Invincibilidade:
func active_imunity(time: float) -> void:
	is_invincible = true
	await get_tree().create_timer(time).timeout
	is_invincible = false

func _on_damage_taken() -> void:
	pass

func die() -> void:
	print(name, " morreu!")
