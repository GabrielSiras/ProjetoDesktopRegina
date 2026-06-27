extends Node2D
class_name Sign

@export var interact_action: StringName = &"interact"
@export_multiline var sign_text := "Texto da placa aqui."

@onready var interaction_area: Area2D = $InteractionArea

var player: Player = null

func _ready() -> void:
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)

func _process(_delta: float) -> void:
	if player == null:
		return
	
	var dialogue_box = get_tree().current_scene.find_child("DialogueBox", true, false)
	var is_box_open = dialogue_box and dialogue_box.visible
	
	if is_box_open:
		if Input.is_action_just_pressed(interact_action) or Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("dash"):
			dialogue_box.visible = false
			
			await get_tree().create_timer(0.02).timeout
			
			if player: 
				player.set_physics_process(true)
				if player.base_sprite and player.base_sprite.has_method("play"):
					player.base_sprite.play("regina-idle")
			
	else:
		if Input.is_action_just_pressed(interact_action):
			player.velocity = Vector2.ZERO
			player.set_physics_process(false)
			read_sign()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		
		if body.has_method("set_interact_indicator_visible"):
			body.set_interact_indicator_visible(true)

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == player:
		var dialogue_box = get_tree().current_scene.find_child("DialogueBox", true, false)
		if dialogue_box:
			dialogue_box.visible = false
			
		player.set_physics_process(true)
		
		if player.has_method("set_interact_indicator_visible"):
			player.set_interact_indicator_visible(false)
		
		player = null

func read_sign() -> void:
	var dialogue_box = get_tree().current_scene.find_child("DialogueBox", true, false)
	
	if dialogue_box:
		dialogue_box.visible = true
		
		var label = dialogue_box.find_child("TextLabel", true, false)
		if label:
			label.text = sign_text
			
		print("Lendo placa: ", sign_text)
