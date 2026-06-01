extends BaseEnemy
class_name FloatingEnemy

@export var FLOAT_DISTANCE := 16.0
@export var FLOAT_SPEED := 2.0

var start_position := Vector2.ZERO
var time := 0.0

func _ready() -> void:
	AFFECTED_BY_GRAVITY = false
	start_position = global_position
	SPEED /= 2

func _physics_process(delta: float) -> void:
	time += delta
	
	# Usa o comportamento normal do BaseEnemy:
	# detecção, perseguição em X, hitbox, move_and_slide etc.
	super(delta)
	
	# Movimento de flutuação para cima e para baixo
	global_position.y = start_position.y + sin(time * FLOAT_SPEED) * FLOAT_DISTANCE
