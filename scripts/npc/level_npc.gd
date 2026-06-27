extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea

# Scena poziomu ładowana po interakcji
@export_file("*.tscn") var level_scene: String = ""

# Czy ten NPC wymaga odblokowania (1 = odblokowany domyślnie, 2 = wymaga przejścia LVL 1, 3 = LVL 2 itd.)
@export var required_level_to_unlock: int = 1

var locked_lines: Array[String] = ["Ten poziom jest jeszcze zablokowany."]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	
	var lbl = Label.new()
	lbl.text = "LVL " + str(required_level_to_unlock)
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	lbl.add_theme_constant_override("outline_size", 2)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.position = Vector2(-15, -35)
	add_child(lbl)

func _on_interact() -> void:
	var unlocked = true
	if required_level_to_unlock == 2 and not GameState.level2_unlocked: unlocked = false
	elif required_level_to_unlock == 3 and not GameState.level3_unlocked: unlocked = false
	elif required_level_to_unlock == 4 and not GameState.level4_unlocked: unlocked = false
		
	if not unlocked:
		DialogManager.start_dialog(global_position, locked_lines)
		await DialogManager.dialog_finished
		return

	get_tree().call_deferred("change_scene_to_file", level_scene)
