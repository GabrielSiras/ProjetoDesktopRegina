extends BaseEnemy
class_name Spider

func _ready() -> void:
	SPEED = 0
	target_player = $Regina

func _on_field_of_view_body_entered(body: Node2D) -> void:
	if body is Player:
		target_player = body

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
