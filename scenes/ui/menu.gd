extends Control

@onready var continue_button = $VBoxContainer/Continue
@onready var start_button = $VBoxContainer/start
@onready var quit_button = $VBoxContainer/quit

var is_pause_menu := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Jeżeli rodzicem Menu jest CanvasLayer, to znaczy,
	# że to menu jest używane w scenie gry jako menu pauzy.
	if get_parent() is CanvasLayer:
		is_pause_menu = true
	else:
		is_pause_menu = false

	if is_pause_menu:
		visible = false
		continue_button.visible = true
		start_button.visible = false
	else:
		visible = true
		continue_button.visible = false
		start_button.visible = true

	get_tree().paused = false


func _input(event: InputEvent) -> void:
	if is_pause_menu and event.is_action_pressed("ui_cancel"):
		if visible:
			close_menu()
		else:
			open_menu()


func open_menu() -> void:
	visible = true
	get_tree().paused = true


func close_menu() -> void:
	visible = false
	get_tree().paused = false


func _on_continue_pressed() -> void:
	close_menu()


func _on_start_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/levels/game_level_1.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
