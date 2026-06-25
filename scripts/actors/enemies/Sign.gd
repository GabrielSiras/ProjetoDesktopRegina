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
	
	if Input.is_action_just_pressed(interact_action):
		read_sign()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		
		if body.has_method("set_interact_indicator_visible"):
			body.set_interact_indicator_visible(true)

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == player:
		if player.has_method("set_interact_indicator_visible"):
			player.set_interact_indicator_visible(false)
		
		player = null

func read_sign() -> void:
	print(sign_text)
	
	# Aqui você chama o sistema de diálogo do projeto.
	# Exemplo:
	# DialogueManager.start_dialogue(sign_text)
	# ou:
	# DialogSystem.show_text(sign_text)
