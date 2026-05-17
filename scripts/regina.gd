extends CharacterBody2D
class_name Player
@onready var hearts_container: HBoxContainer = %HeartsContainer

# Configurações de Movimento
@export_group("Movimento")
@export var SPEED := 350.0
@export var ACCELERATION := 1500.0
@export var FRICTION := 1200.0
@export var JUMP_VELOCITY := -400.0

# Configurações do Dash
@export_group("Dash")
@export var DASH_SPEED_H := 1000.0
@export var DASH_SPEED_V := 500.0
@export var DASH_DURATION := 0.2
@export var DASH_COOLDOWN := 0.4

# Health
@export_group("Vida")
@export var max_health := 3
var current_health := max_health

# Estados Internos
var is_dashing := false
var can_dash := true
var dash_cooldown_active := false

func update_hearts_ui() -> void:
	if hearts_container == null: return
	
	var hearts = hearts_container.get_children()
	
	for i in range(hearts.size()):
		if hearts[i].has_node("AnimatedSprite2D"):
			var sprite = hearts[i].get_node("AnimatedSprite2D") as AnimatedSprite2D
			
			hearts[i].visible = true
			
			if i < current_health:
				if sprite.animation != "cheio":
					sprite.animation = "cheio"
					sprite.play()
			else:
				if sprite.animation != "vazio":
					sprite.animation = "vazio"
					sprite.play()

func _physics_process(delta: float) -> void:
	# Reseta dash quando estiver no chão
	if is_on_floor():
		can_dash = true

	if not is_dashing:
		apply_gravity(delta)
		handle_jump()
		handle_movement(delta)
		handle_dash_input()
	
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func handle_movement(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	
	# Flip do sprite baseado na direção
	if direction != 0:
		$Sprite2D.flip_h = direction < 0

	# Aceleração e atrito aplicados suavemente
	var target_vel = direction * SPEED
	var accel_rate = ACCELERATION if direction != 0 else FRICTION
	velocity.x = move_toward(velocity.x, target_vel, accel_rate * delta)

func handle_dash_input() -> void:
	var can_trigger_dash = can_dash and not dash_cooldown_active
	if Input.is_action_just_pressed("dash") and can_trigger_dash:
		start_dash()

func start_dash() -> void:
	# Captura direção do input ou usa a face do sprite como fallback
	var input_vec := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var dash_dir := input_vec.normalized() if input_vec != Vector2.ZERO else Vector2.LEFT if $Sprite2D.flip_h else Vector2.RIGHT
	
	# Configuração de estado
	is_dashing = true
	can_dash = false
	dash_cooldown_active = true
	
	# Aplicação da velocidade do impulso
	velocity = Vector2(dash_dir.x * DASH_SPEED_H, dash_dir.y * DASH_SPEED_V)
	
	# Sequência de timers (Duração -> Cooldown)
	await get_tree().create_timer(DASH_DURATION).timeout
	is_dashing = false
	velocity = dash_dir * SPEED # Mantém o momentum
	
	await get_tree().create_timer(DASH_COOLDOWN).timeout
	dash_cooldown_active = false
	
func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = clamp(current_health, 0, max_health) 
	
	# Avisa a HUD para atualizar os corações na tela
	update_hearts_ui()
	print("Regina tomou dano! Vida atual: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Regina morreu!")
	# Recarrega a fase atual se ela perder as 3 vidas
	get_tree().reload_current_scene()
