extends CharacterBase
class_name BaseEnemy

@export_group("Configurações do Inimigo")
@export var SPEED := 150.0
@export var DAMAGE_AMOUNT := 1
@export var AFFECTED_BY_GRAVITY := true

@onready var hurtbox_area: Area2D = $Hurtbox

var target_player: Player = null

func _ready() -> void:
	if hurtbox_area:
		if not hurtbox_area.body_entered.is_connected(_on_hurtbox_body_entered):
			hurtbox_area.body_entered.connect(_on_hurtbox_body_entered)

func _physics_process(delta: float) -> void:
	super(delta)
	
	if AFFECTED_BY_GRAVITY:
		if not is_on_floor():
			velocity += get_gravity() * delta
	else:
		velocity.y = 0
	
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

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()

func die() -> void:	
	if has_method("on_death"):
		call("on_death")
	else:
		visible = false
		set_process(false)
		set_physics_process(false)
