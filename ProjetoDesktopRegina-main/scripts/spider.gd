extends BaseEnemy
class_name Spider

func _ready() -> void:
	SPEED = 0

func _process(delta:float):
	if target_player != null:
		look_at(target_player.global_position)
