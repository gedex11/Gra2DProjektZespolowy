extends VBoxContainer

# Panel ulepszeń statystyk pod paskiem XP.
# Dynamicznie buduje wiersz dla każdej ulepszanej statystyki:
#   Nazwa   Wartość   [+ koszt]
# Przycisk "+" pojawia się tylko, gdy gracza stać na ulepszenie.

@export var player_path: NodePath
@onready var player: Player = get_node(player_path)

# Kolejność statystyk w UI (HP, Armor, Damage na górze – jak w opisie zadania).
const STATS := [
	"max_hp", "armor", "attack_damage", "attack_speed",
	"speed_multiplier", "crit_chance", "crit_damage", "life_steal", "dodge_chance",
]

var _points_label: Label
var _rows := {}  # stat -> { "value": Label, "plus": Button }


func _ready() -> void:
	if player == null or player.stats == null:
		push_error("StatsPanel: nie znaleziono Playera/stats")
		return

	_build_ui()
	player.stats.changed.connect(_refresh)
	_refresh()


func _build_ui() -> void:
	_points_label = Label.new()
	_points_label.add_theme_font_size_override("font_size", 12)
	add_child(_points_label)

	for stat in STATS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)

		var name_label := Label.new()
		name_label.text = player.stats.STAT_DISPLAY.get(stat, stat)
		name_label.custom_minimum_size = Vector2(70, 0)
		name_label.add_theme_font_size_override("font_size", 12)

		var value_label := Label.new()
		value_label.custom_minimum_size = Vector2(50, 0)
		value_label.add_theme_font_size_override("font_size", 12)

		var plus := Button.new()
		plus.add_theme_font_size_override("font_size", 12)
		plus.custom_minimum_size = Vector2(60, 0)
		plus.pressed.connect(_on_plus_pressed.bind(stat))

		row.add_child(name_label)
		row.add_child(value_label)
		row.add_child(plus)
		add_child(row)

		_rows[stat] = { "value": value_label, "plus": plus }


func _on_plus_pressed(stat: String) -> void:
	player.stats.upgrade_stat(stat)


func _refresh() -> void:
	var s := player.stats
	_points_label.text = "Punkty: " + ("%.2f" % s.available_points)

	for stat in STATS:
		var value = s.get(stat)
		_rows[stat]["value"].text = ("%.2f" % value) if value is float else str(value)

		var btn: Button = _rows[stat]["plus"]
		if s.can_upgrade(stat):
			btn.visible = true
			btn.text = "+ (" + ("%.1f" % s.get_upgrade_cost(stat)) + ")"
		else:
			btn.visible = false
