extends CharacterBody2D
class_name WebProjectile

@export var SPEED := 100.0

var dir: float
var spawnPos: Vector2
var spawnRot: float
var zdex: int

func _ready() -> void:
	global_position = spawnPos
	global_rotation = spawnRot
	z_index	= zdex
	
func _physics_process(delta: float) -> void:
	velocity = Vector2(0,-SPEED).rotated(dir)
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Ouch!")
	#queue_free()
