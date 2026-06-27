extends Panel

@export var player_path: NodePath
@onready var player: Player = get_node(player_path)

@onready var slots := [
	$CenterContainer/Slot_grid/Slot1,
	$CenterContainer/Slot_grid/Slot2,
	$CenterContainer/Slot_grid/Slot3,
	$CenterContainer/Slot_grid/Slot4,
	$CenterContainer/Slot_grid/Slot5,
	$CenterContainer/Slot_grid/Slot6,
	$CenterContainer/Slot_grid/Slot7,
	$CenterContainer/Slot_grid/Slot8,
	$CenterContainer/Slot_grid/Slot9,
	$CenterContainer/Slot_grid/Slot10,
	$CenterContainer/Slot_grid/Slot11,
	$CenterContainer/Slot_grid/Slot12,
	$CenterContainer/Slot_grid/Slot13,
	$CenterContainer/Slot_grid/Slot14,
	$CenterContainer/Slot_grid/Slot15
]

var is_open := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	if player == null:
		push_error("InventoryPanel: nie znaleziono Playera")
		return

	if player.inventory == null:
		push_error("InventoryPanel: Player nie ma inventory")
		return

	player.inventory.changed.connect(update_slots)
	update_slots()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()


func toggle_inventory() -> void:
	is_open = !is_open
	visible = is_open


func update_slots() -> void:
	for i in range(slots.size()):
		var item = player.inventory.get_item(i)
		var icon: TextureRect = slots[i].get_node("Icon")

		if item == null:
			icon.texture = null
		elif player.equipped_armor == item or player.equipped_weapon == item:
			icon.texture = null
		else:
			icon.texture = item.icon
