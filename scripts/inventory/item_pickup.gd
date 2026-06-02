extends Area2D
class_name ItemPickup

@export var item: Item

@onready var sprite: Sprite2D = $Sprite2D

var player_in_range: Player = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	z_index = 100
	sprite.z_index = 100
	sprite.scale = Vector2(0.5, 0.5)
	sprite.visible = true

	if item != null:
		print("ItemPickup ma item: ", item.name)

		if item.icon != null:
			sprite.texture = item.icon
			print("Ustawiono ikonę itemu na Sprite2D")
		else:
			print("Item nie ma ikony!")
	else:
		print("ItemPickup nie ma przypisanego itemu!")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		print("Kliknięto E przy itemie. Player in range: ", player_in_range)
		
		if player_in_range != null:
			pickup_item()


func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_in_range = body
		print("Naciśnij E, aby podnieść item")


func _on_body_exited(body: Node) -> void:
	if body == player_in_range:
		player_in_range = null


func pickup_item() -> void:
	if item == null:
		print("Brak przypisanego itemu!")
		return

	var added := player_in_range.inventory.add_item(item)

	if added:
		print("Podniesiono: ", item.name)
		queue_free()
	else:
		print("Ekwipunek pełny")
