extends CharacterBody2D
class_name WebProjectile

@export var SPEED: float = 200.0
@export var LIFE_TIME: float = 2.0

@export var WEAVE_TIME: float = 1
@export var WEAVE_START_SCALE: float = 0.1
@export var WEAVE_ROTATIONS: float = 3.0

@export var END_SCALE_MULTIPLIER: float = 0.5
@export var FADE_START_PERCENT: float = 0.9

var direction: Vector2 = Vector2.RIGHT
var launched: bool = false

var default_scale: Vector2
var launch_scale: Vector2
var life_timer: float = 0.0

@onready var area: Area2D = $Area2D

func _ready() -> void:
	default_scale = scale
	
	if not area.body_entered.is_connected(_on_area_2d_body_entered):
		area.body_entered.connect(_on_area_2d_body_entered)
	
	area.monitoring = false
	modulate.a = 1.0

func weave_animation() -> void:
	launched = false
	area.monitoring = false
	
	life_timer = 0.0
	modulate.a = 1.0
	
	scale = default_scale * WEAVE_START_SCALE
	rotation = 0
	
	var tween := create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "scale", default_scale, WEAVE_TIME)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "rotation", TAU * WEAVE_ROTATIONS, WEAVE_TIME)
	
	await tween.finished

func launch(shoot_direction: Vector2, projectile_z_index: int = 0) -> void:
	direction = shoot_direction.normalized()
	rotation = direction.angle() + PI / 2
	z_index = projectile_z_index
	
	launched = true
	area.monitoring = true
	
	life_timer = 0.0
	launch_scale = scale
	modulate.a = 1.0

func _physics_process(delta: float) -> void:
	if not launched:
		return
	
	life_timer += delta
	
	var life_progress: float = clampf(life_timer / LIFE_TIME, 0.0, 1.0)
	
	# Diminui o tamanho durante todo o tempo de vida
	scale = launch_scale.lerp(default_scale * END_SCALE_MULTIPLIER, life_progress)
	
	# Só começa a desaparecer no final da vida
	if life_progress >= FADE_START_PERCENT:
		var fade_progress: float = inverse_lerp(FADE_START_PERCENT, 1.0, life_progress)
		modulate.a = lerpf(1.0, 0.0, fade_progress)
	
	velocity = direction * SPEED
	move_and_slide()
	
	if life_progress >= 1.0:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not launched:
		return
	
	if body is TileMapLayer or body.name.to_lower().contains("tilemap") or body is StaticBody2D:
		queue_free()
		return
	
	if body is Player:
		if body.is_dashing:
			queue_free()
			return
			
		print("Ouch!")
		body.die()
		queue_free()
