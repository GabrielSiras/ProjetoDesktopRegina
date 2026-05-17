extends CharacterBody2D

# No script do Mímico:
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Player: 
		if body.is_dashing:
			destroy_mimic(body)
		else:
			body.take_damage(1)
			print("Regina tomou dano do baú!")

func destroy_mimic(player: Node2D) -> void:
	print("Mímico destruído pelo Dash!")
	
	player.is_dashing = false
	player.can_dash = true
	player.dash_cooldown_active = false
	
	player.velocity.y = -1000.0 
	queue_free() # Remove o mímico do jogo
