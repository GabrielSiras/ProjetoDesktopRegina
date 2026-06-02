extends BaseEnemy
class_name FloatingEnemy

@export var FLOAT_DISTANCE := 16.0
@export var FLOAT_SPEED := 2.0

var start_position := Vector2.ZERO
var time := 0.0

func _ready() -> void:
	super._ready()
	
	AFFECTED_BY_GRAVITY = false
	start_position = global_position
	SPEED /= 2

func _physics_process(delta: float) -> void:
	time += delta
	
	super(delta)
	
	global_position.y = start_position.y + sin(time * FLOAT_SPEED) * FLOAT_DISTANCE
