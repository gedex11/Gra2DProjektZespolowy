extends Panel

@onready var slot_grid: GridContainer = $SlotGrid

var is_open := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()


func toggle_inventory() -> void:
	is_open = !is_open
	visible = is_open
