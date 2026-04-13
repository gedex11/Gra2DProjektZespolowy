extends MarginContainer


@onready var label: Label = $MarginContainer/Label
@onready var timer: Timer = $LetterDisplayTimer


const MAX_WIDTH = 224
var text = ""

var letter_index = 0
var letter_time = 0.05
var space_time = 0.06
var punctuation_time = 0.2

signal finished_displaying()


func display_text(text_to_display: String) -> void: 
	text = text_to_display
	label.text = text_to_display
	letter_index = 0
	
	
	await resized
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await get_tree().process_frame
		custom_minimum_size.y = size.y
		
	global_position.x -= size.x / 2
	global_position.y -= size.y +24
	
	
	label.text = "" 
	_display_letter()
	
	
	
func _display_letter():
	label.text += text[letter_index]
	
	letter_index += 1 
	if letter_index >= text.length():
		finished_displaying.emit()
		return
	
	match text[letter_index]:
		"!", ".", ",", "?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)
	





func fade_out():
	var tween = get_tree().create_tween()
	
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	
	tween.finished.connect(queue_free)


func _on_letter_display_timer_timeout() -> void:
	_display_letter()
