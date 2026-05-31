extends BaseEnemy
class_name Mimic

func _ready() -> void:
	base_sprite = $Sprite2D
	max_health = 1
	current_health = max_health
	SPEED = 60.0

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.is_dashing:
			return
		print("Mímico pegou a Regina!")
		body.die()


func _on_field_of_view_body_entered(body: Node2D) -> void:
	if body is Player:
		target_player = body


func _on_field_of_view_body_exited(body: Node2D) -> void:
	if body == target_player:
		target_player = null
