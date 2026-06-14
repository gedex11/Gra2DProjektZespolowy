extends ProgressBar

@export var player_path: NodePath
@export var exp_label_path: NodePath

@onready var player: Player = get_node(player_path)
@onready var exp_label: Label = get_node(exp_label_path)


func _ready() -> void:
	if player == null:
		push_error("ExpBar: nie znaleziono Playera")
		return

	player.stats.changed.connect(update_exp_bar)
	update_exp_bar()


func update_exp_bar() -> void:
	max_value = player.stats.exp_to_next_level
	value = player.stats.current_exp

	var percent := 0

	if player.stats.exp_to_next_level > 0:
		percent = int((float(player.stats.current_exp) / float(player.stats.exp_to_next_level)) * 100.0)

	exp_label.text = "LVL " + str(player.stats.level) + " | " + str(percent) + "%"
