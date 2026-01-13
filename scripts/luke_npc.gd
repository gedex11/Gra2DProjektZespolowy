extends StaticBody2D

@onready var dialog_label: Label = $DialogLabel

# Zmienne konfiguracyjne
@export var dialog_lines: Array[String] = [
	"Witaj w naszym miescie! \nNacicnij E, aby kontynuowac...",
	"Znajdz statek \n[E]",
	"Pozdro"
]

var current_line: int = 0
var is_player_in_range: bool = false
var is_typing: bool = false

func _ready() -> void:
	dialog_label.text = "" 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if is_player_in_range:
			advance_dialog()

func advance_dialog() -> void:
	if is_typing:
		dialog_label.visible_ratio = 1.0
		is_typing = false
		return
		
	if current_line < dialog_lines.size():
		start_typing_effect(dialog_lines[current_line])
		current_line += 1
		
	

func start_typing_effect(text_to_show: String) -> void:
	dialog_label.text = text_to_show
	dialog_label.visible_ratio = 0.0
	is_typing = true
	
	# Animacja pisania tekstu 
	var duration = text_to_show.length() * 0.09 # 0.09s na literę
	var tween = get_tree().create_tween()
	
	tween.tween_property(dialog_label, "visible_ratio", 1.0, duration)
	
	tween.finished.connect(func(): is_typing = false)


func _on_interact_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D: 
		is_player_in_range = true
		advance_dialog()


func _on_interact_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D: 
		is_player_in_range = false
		is_typing = false
		dialog_label.text = ""
		current_line = 0
