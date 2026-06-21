extends CanvasLayer
class_name DialogueBox
@onready var text_label: RichTextLabel = $"Scroll-background/TextLabel"
@onready var letter_timer: Timer = $LetterTimer
@onready var writing: AudioStreamPlayer = $Writing

var dialogue_lines: Array[String] = []
var current_line_index: int = 0
var is_typing: bool = false

func _ready() -> void:
	visible = false
	letter_timer.timeout.connect(_on_letter_timer_timeout)

func _process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed("ui_accept"):
		if is_typing:
			text_label.visible_characters = text_label.text.length()
			is_typing = false
			letter_timer.stop()
		else:
			advance_dialogue()

func start_dialogue(lines: Array[String]) -> void:
	dialogue_lines = lines
	current_line_index = 0
	visible = true
	
	var regina = get_tree().current_scene.find_child("Regina", true, false)
	if regina: regina.set_physics_process(false)
	
	show_line()

func show_line() -> void:
	is_typing = true
	text_label.text = dialogue_lines[current_line_index]
	
	text_label.visible_characters = 0
	
	letter_timer.start()

func _on_letter_timer_timeout() -> void:
	if text_label.visible_characters < text_label.text.length():
		text_label.visible_characters += 1
		
		if writing:
			writing.play()
			
		letter_timer.start()
	else:
		is_typing = false
		if writing:
			writing.stop()

func advance_dialogue() -> void:
	current_line_index += 1
	
	if current_line_index < dialogue_lines.size():
		show_line()
	else:
		end_dialogue()

func end_dialogue() -> void:
	visible = false
	
	var regina = get_tree().current_scene.find_child("Regina", true, false)
	if regina: regina.set_physics_process(true)
