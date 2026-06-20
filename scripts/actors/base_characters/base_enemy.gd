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
		# Se a Regina estiver no meio de um dash, o inimigo NÃO PODE dar dano nela!
		if body.is_dashing:
			return
		body.die()

func die() -> void: 
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
		
	# 2. Desativa a área que dá dano na Regina (Hurtbox)
	# (Substitua 'CollisionShape2D' pelo nome do nó filho de colisão da sua Hurtbox se for diferente)
	if has_node("Hurtbox/CollisionShape2D"):
		$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	elif hurtbox_area and hurtbox_area.has_node("CollisionShape2D"):
		hurtbox_area.get_node("CollisionShape2D").set_deferred("disabled", true)

	# 3. Executa o resto da sua lógica padrão
	if has_method("on_death"):
		call("on_death")
	else:
		visible = false
		set_process(false)
		set_physics_process(false)
		# Opcional: se ele não tiver animação de morte complexa, 
		# você pode dar queue_free() aqui para sumir com ele da memória de vez!
		queue_free()
