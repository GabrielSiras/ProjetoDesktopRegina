extends CanvasLayer
class_name DialogueBox

@onready var text_label: RichTextLabel = $Panel/TextLabel
@onready var letter_timer: Timer = $LetterTimer

# Lista de frases que vão aparecer nessa conversa
var dialogue_lines: Array[String] = []
var current_line_index: int = 0
var is_typing: bool = false

func _ready() -> void:
	# Começa invisível até que alguém chame o diálogo
	visible = false
	letter_timer.timeout.connect(_on_letter_timer_timeout)

func _process(_delta: float) -> void:
	# Se o diálogo estiver aberto e o jogador apertar o botão de avançar (ex: Espaço, Enter ou botão de pulo)
	if visible and Input.is_action_just_pressed("ui_accept"):
		if is_typing:
			# Se ainda está digitando, o clique "pula" a animação e mostra a frase inteira na hora!
			text_label.visible_characters = text_label.text.length()
			is_typing = false
			letter_timer.stop()
		else:
			# Se já terminou de digitar, avança para a próxima frase
			advance_dialogue()

# Função para iniciar a conversa de qualquer lugar do jogo
func start_dialogue(lines: Array[String]) -> void:
	dialogue_lines = lines
	current_line_index = 0
	visible = true
	
	# Congela a física da Regina para ela não andar enquanto conversa
	var regina = get_tree().current_scene.find_child("Regina", true, false)
	if regina: regina.set_physics_process(false)
	
	show_line()

func show_line() -> void:
	is_typing = true
	text_label.text = dialogue_lines[current_line_index]
	
	# MÁGICA DO GODOT: Dizemos que 0 letras estão visíveis no começo
	text_label.visible_characters = 0
	
	# Dispara o cronômetro para começar a revelar as letras
	letter_timer.start()

func _on_letter_timer_timeout() -> void:
	if text_label.visible_characters < text_label.text.length():
		# Mostra mais uma letra!
		text_label.visible_characters += 1
		# Reinicia o timer para a próxima letra
		letter_timer.start()
	else:
		# Terminou de digitar o texto inteiro
		is_typing = false

func advance_dialogue() -> void:
	current_line_index += 1
	
	# Se ainda tiver frases na lista, mostra a próxima
	if current_line_index < dialogue_lines.size():
		show_line()
	else:
		# Se acabaram as frases, fecha a caixa de diálogo
		end_dialogue()

func end_dialogue() -> void:
	visible = false
	
	# Devolve o controle físico para a Regina voltar a andar
	var regina = get_tree().current_scene.find_child("Regina", true, false)
	if regina: regina.set_physics_process(true)
