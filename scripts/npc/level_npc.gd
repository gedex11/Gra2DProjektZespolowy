extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea

# Scena poziomu ładowana po interakcji
@export_file("*.tscn") var level_scene: String = ""

# Czy ten NPC wymaga odblokowania Level 2 (dla NPC Level 1 zostaw false)
@export var requires_level2_unlock: bool = false

var locked_lines: Array[String] = ["Ten poziom jest jeszcze zablokowany."]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	
	var lvl_str = "LVL 1"
	if requires_level2_unlock:
		lvl_str = "LVL 2"
	
	var lbl = Label.new()
	lbl.text = lvl_str
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	lbl.add_theme_constant_override("outline_size", 2)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.position = Vector2(-15, -35)
	add_child(lbl)

func _on_interact() -> void:
	if requires_level2_unlock and not GameState.level2_unlocked:
		DialogManager.start_dialog(global_position, locked_lines)
		await DialogManager.dialog_finished
		return

	get_tree().change_scene_to_file(level_scene)
