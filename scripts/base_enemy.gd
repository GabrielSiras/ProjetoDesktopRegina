extends CharacterBase
class_name BaseEnemy

@export_group("Configurações do Inimigo")
@export var SPEED := 150.0
@export var DAMAGE_AMOUNT := 1

var target_player: Player = null

func _physics_process(delta: float) -> void:
	super(delta)
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if target_player:
		chase_target()
	else:
		stand_still()
		
	move_and_slide()

func chase_target() -> void:
	var direction = (target_player.global_position - global_position).normalized()
	velocity.x = direction.x * SPEED
	
	if base_sprite and direction.x != 0:
		base_sprite.flip_h = direction.x < 0

func stand_still() -> void:
	velocity.x = move_toward(velocity.x, 0, SPEED)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Player:
		target_player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target_player:
		target_player = null

func _on_hitbox_area_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(DAMAGE_AMOUNT)

func die() -> void:
	print(name, " foi destruído!")
	queue_free() # Todo inimigo se deleta ao morrer
