extends BaseEnemy
class_name Spider

@onready var main = get_tree().current_scene
@onready var projectile = load("res://scenes/actors/enemies/web_projectile.tscn")

func _ready() -> void:
	super._ready()
	
	AFFECTED_BY_GRAVITY = false
	SPEED = 0
	target_player = null

func _on_field_of_view_body_entered(body: Node2D) -> void:
	if body is Player:
		target_player = body
		_on_timer_timeout() # Dispara a teia no ritmo do timer

func _on_field_of_view_body_exited(body: Node2D) -> void:
	if body is Player:
		target_player = null
		rotation = 0

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.is_dashing:
			return
		print("Aranha pegou a Regina!")
		body.die()

func _process(delta:float):
	if target_player != null:
		look_at(target_player.global_position)

# Função de disparo
func shoot_web():
	var instance = projectile.instantiate()
	instance.dir = rotation
	instance.spawnPos = global_position
	instance.spawnRot = global_rotation
	instance.zdex = z_index-1 #Faz com que o projétil spawne por baixo da aranha
	main.add_child.call_deferred(instance)

# Sinal do timer
func _on_timer_timeout() -> void:
	shoot_web()
