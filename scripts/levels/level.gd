extends Node2D

# HUB
const HUB_SCENE := "uid://fvmkgve4iwtp"

# Czy ukończenie tego poziomu odblokowuje Level 2.
@export var unlocks_level2: bool = false

func _ready() -> void:
	# Podłącz się pod zniknięcie każdego wroga obecnego na starcie poziomu.
	for enemy in get_tree().get_nodes_in_group("minimap_enemy"):
		enemy.tree_exited.connect(_on_enemy_removed)

func _on_enemy_removed() -> void:
	# Poczekaj klatkę, aż wróg zostanie usunięty z drzewa, potem policz pozostałych.
	await get_tree().process_frame

	if get_tree().get_nodes_in_group("minimap_enemy").is_empty():
		_complete_level()

func _complete_level() -> void:
	if unlocks_level2:
		GameState.level2_unlocked = true

	get_tree().change_scene_to_file(HUB_SCENE)
