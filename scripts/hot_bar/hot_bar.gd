extends HBoxContainer

@export var player_path: NodePath
@onready var player: Player = get_node(player_path)

@onready var slots := [
	$slot1,
	$slot2,
	$slot3,
	$slot4,
	$slot5
]


func _ready() -> void:
	if player == null:
		push_error("Hot_bar: nie znaleziono Playera")
		return

	if player.inventory == null:
		push_error("Hot_bar: Player nie ma inventory")
		return

	player.inventory.changed.connect(update_hotbar)
	update_hotbar()


func update_hotbar() -> void:
	for i in range(slots.size()):
		var item = player.inventory.get_item(i)
		var icon: TextureRect = slots[i].get_node("Icon")

		if item == null:
			icon.texture = null
		else:
			icon.texture = item.icon
