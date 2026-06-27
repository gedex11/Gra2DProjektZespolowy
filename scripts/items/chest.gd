extends Area2D
class_name Chest

@export var items_inside: Array[Item] = []
@export var exp_reward: int = 50

var is_open: bool = false
var player_in_range: Player = null

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	z_index = 90
	if sprite:
		sprite.z_index = 90

func _input(event: InputEvent) -> void:
	if is_open: return
	
	if event.is_action_pressed("interact") and player_in_range != null:
		open_chest()

func _on_body_entered(body: Node) -> void:
	if not is_open and body is Player:
		player_in_range = body
		print("Naciśnij E, aby otworzyć skrzynię")

func _on_body_exited(body: Node) -> void:
	if body == player_in_range:
		player_in_range = null

func open_chest() -> void:
	is_open = true
	if sprite:
		sprite.modulate = Color(0.5, 0.5, 0.5) # Szary by odróżnić zamkniętą od otwartej
	print("Otwarto skrzynię!")
	
	var loot_text = ""
	
	if player_in_range != null:
		if exp_reward > 0:
			player_in_range.add_exp(exp_reward)
			loot_text += "+" + str(exp_reward) + " EXP\n"
		
		for item in items_inside:
			if item != null:
				var added = player_in_range.inventory.add_item(item)
				if added:
					loot_text += "+ " + item.name + "\n"
				else:
					loot_text += "Brak miejsca: " + item.name + "\n"
					
		_show_floating_text(loot_text)

func _show_floating_text(txt: String) -> void:
	var label = Label.new()
	label.text = txt
	label.global_position = global_position + Vector2(-30, -30)
	label.z_index = 100
	label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
	get_tree().current_scene.add_child(label)
	
	var tween = get_tree().create_tween()
	tween.tween_property(label, "global_position", label.global_position + Vector2(0, -40), 1.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.5)
	tween.tween_callback(label.queue_free)
