extends Area2D
class_name SwordPickup

@export_multiline var pickup_dialogue := "Esta é a espada de meu cavaleiro!\nVou utilizá-la com X para chegar mais longe!"

var player: Player = null
var collected := false

func _ready() -> void:
	if GameManager.sword_unlocked:
		queue_free()
		return
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if collected:
		if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("jump"):
			var dialogue_box = get_tree().current_scene.find_child("DialogueBox", true, false)
			if dialogue_box and dialogue_box.visible:
				dialogue_box.visible = false
					
				if player:
					player.set_physics_process(true)	
					if player.base_sprite and player.base_sprite.has_method("play"):
						player.base_sprite.play("regina-idle")
				
				queue_free()
		return
	
	if player == null:
		return
	
	if Input.is_action_just_pressed("interact"):
		collect_sword()

func _on_body_entered(body: Node2D) -> void:
	if collected: return
	if body is Player:
		player = body
		
		if player.has_method("set_interact_indicator_visible"):
			player.set_interact_indicator_visible(true)

func _on_body_exited(body: Node2D) -> void:
	if collected: return
	if body == player:
		if player.has_method("set_interact_indicator_visible"):
			player.set_interact_indicator_visible(false)
		
		player = null

func collect_sword() -> void:
	if player == null:
		return
	
	collected = true
	
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	
	if player.has_method("set_interact_indicator_visible"):
		player.set_interact_indicator_visible(false)
	
	player.unlock_sword()
	show_pickup_dialogue()
	
	visible = false

func show_pickup_dialogue() -> void:
	var dialogue_box = get_tree().current_scene.find_child("DialogueBox", true, false)
	
	if dialogue_box:
		dialogue_box.visible = true
		
		var label = dialogue_box.find_child("TextLabel", true, false)
		if label:
			label.text = pickup_dialogue
			
		print("Coletou espada: ", pickup_dialogue)
