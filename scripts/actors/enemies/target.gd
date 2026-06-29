extends BaseEnemy
class_name Target

func _ready() -> void:
	super._ready()	
	base_sprite = $Sprite2D
	SPEED = 0.0
	AFFECTED_BY_GRAVITY = false
	
	max_health = 999999
	current_health = max_health
	
	add_to_group("enemies")
	add_to_group("non_damaging_enemy")

func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO
func take_damage(_amount: int) -> void:
	current_health = max_health
	
	if has_node("HitSFX"):
		$HitSFX.play()
	
	if base_sprite:
		base_sprite.modulate.a = 0.5
		await get_tree().create_timer(0.05).timeout
		base_sprite.modulate.a = 1.0

func die() -> void:
	current_health = max_health
