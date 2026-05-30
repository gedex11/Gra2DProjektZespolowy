extends ProgressBar

@export var player_path: NodePath
@onready var player: Player = get_node(player_path)


func _ready() -> void:
	if player == null:
		push_error("Brak Playera dla HealthBar!")
		return

	player.stats.changed.connect(update_health_bar)
	update_health_bar()


func update_health_bar() -> void:
	max_value = player.stats.max_hp
	value = player.stats.current_hp
