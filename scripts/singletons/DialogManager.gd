extends Node

@onready var text_box_scene = preload("res://ui/text_box/text_box.tscn")
#@onready var player = get_tree().get_first_node_in_group("player")


const max_distance: float = 30.0  


var dialog_lines: Array[String] = []
var current_line_index = 0 

var text_box
var text_box_position: Vector2

var is_dialog_active = false
var can_advance_line = false


signal dialog_finished

func _process(_delta: float) -> void:
	if is_dialog_active:
		var player = get_tree().get_first_node_in_group("player")
		var distance = player.global_position.distance_to(text_box_position)
		
		if distance > max_distance:
			_force_close_dialog()



func start_dialog(position: Vector2, lines: Array[String]):
	if is_dialog_active:
		return
		
	dialog_lines = lines
	text_box_position = position
	_show_text_box()
	
	is_dialog_active = true
	
func _show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	text_box.global_position = text_box_position
	text_box.display_text(dialog_lines[current_line_index])
	can_advance_line = false



func _on_text_box_finished_displaying():
	can_advance_line = true


func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action("interact") && is_dialog_active && can_advance_line):
		if text_box:
			text_box.queue_free()
			text_box = null
			
		current_line_index += 1
		if current_line_index >= dialog_lines.size():
			is_dialog_active = false
			current_line_index = 0
			
			dialog_finished.emit()
			return
		
		_show_text_box()

func _force_close_dialog():
	if text_box:
		text_box.fade_out() 
		text_box = null 
	
	is_dialog_active = false
	current_line_index = 0
	can_advance_line = false
	dialog_finished.emit()
