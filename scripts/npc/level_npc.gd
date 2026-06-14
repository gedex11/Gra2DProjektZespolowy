extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea

# Scena poziomu ładowana po interakcji
@export_file("*.tscn") var level_scene: String = ""

# Czy ten NPC wymaga odblokowania Level 2 (dla NPC Level 1 zostaw false)
@export var requires_level2_unlock: bool = false

var locked_lines: Array[String] = ["Ten poziom jest jeszcze zablokowany."]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	if requires_level2_unlock and not GameState.level2_unlocked:
		DialogManager.start_dialog(global_position, locked_lines)
		await DialogManager.dialog_finished
		return

	get_tree().change_scene_to_file(level_scene)
