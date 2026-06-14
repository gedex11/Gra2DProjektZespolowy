extends Panel

@export var player_path: NodePath

@export var minimap_zoom: float = 0.15

@onready var player_dot: ColorRect = get_node_or_null("Player_dot")

var debug_timer := 0.0
var player: Player = null
var map_node = null
var world_min: Vector2
var world_max: Vector2

var enemy_dots := {}
var item_dots := {}


func _ready() -> void:
	player = get_node_or_null(player_path)

	if player_dot == null:
		push_error("Minimap: nie znaleziono PlayerDot")
		return

	if player == null:
		push_error("Minimap: NIE znaleziono Playera. Sprawdź Player Path.")
	else:
		print("Minimap: Player znaleziony: ", player.name)

	for node in get_tree().get_nodes_in_group("minimap_map"):
		print("Minimap: node w grupie minimap_map: ", node.name, " class: ", node.get_class())

		if node.has_method("get_used_rect"):
			map_node = node
			break

	if map_node == null:
		push_error("Minimap: nie znaleziono TileMap/TileMapLayer w grupie minimap_map")
		return

	calculate_map_bounds()


func _process(delta: float) -> void:
	update_player_dot()
	update_enemy_dots()
	update_item_dots()

	debug_timer += delta
	if debug_timer >= 1.0:
		debug_timer = 0.0

		if player != null:
			print("PLAYER POS: ", player.global_position)

		if player_dot != null:
			print("DOT POS: ", player_dot.position)


func calculate_map_bounds() -> void:
	var used_rect = map_node.get_used_rect()
	var tile_size = map_node.tile_set.tile_size

	world_min = map_node.to_global(Vector2(
		used_rect.position.x * tile_size.x,
		used_rect.position.y * tile_size.y
	))

	world_max = map_node.to_global(Vector2(
		(used_rect.position.x + used_rect.size.x) * tile_size.x,
		(used_rect.position.y + used_rect.size.y) * tile_size.y
	))

	print("MINIMAP mapa: ", map_node.name)
	print("MINIMAP world_min: ", world_min)
	print("MINIMAP world_max: ", world_max)


func world_to_minimap(world_position: Vector2) -> Vector2:
	if player == null:
		return Vector2.ZERO

	var minimap_center := size / 2
	var relative_position := world_position - player.global_position

	return minimap_center + relative_position * minimap_zoom


func update_player_dot() -> void:
	if player_dot == null:
		return

	player_dot.position.x = size.x / 2 - player_dot.size.x / 2
	player_dot.position.y = size.y / 2 - player_dot.size.y / 2

func update_enemy_dots() -> void:
	if map_node == null:
		return

	var enemies := get_tree().get_nodes_in_group("minimap_enemy")

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		if not enemy_dots.has(enemy):
			var dot := ColorRect.new()
			dot.color = Color.RED
			dot.size = Vector2(8, 8)
			dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(dot)
			enemy_dots[enemy] = dot

		var dot: ColorRect = enemy_dots[enemy]
		var dot_position := world_to_minimap(enemy.global_position)

		dot.position.x = dot_position.x - dot.size.x / 2
		dot.position.y = dot_position.y - dot.size.y / 2

	remove_invalid_dots(enemy_dots)


func update_item_dots() -> void:
	if map_node == null:
		return

	var items := get_tree().get_nodes_in_group("minimap_item")

	for item in items:
		if not is_instance_valid(item):
			continue

		if not item_dots.has(item):
			var dot := ColorRect.new()
			dot.color = Color.YELLOW
			dot.size = Vector2(7, 7)
			dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(dot)
			item_dots[item] = dot

		var dot: ColorRect = item_dots[item]
		var dot_position := world_to_minimap(item.global_position)

		dot.position.x = dot_position.x - dot.size.x / 2
		dot.position.y = dot_position.y - dot.size.y / 2

	remove_invalid_dots(item_dots)


func remove_invalid_dots(dot_dictionary: Dictionary) -> void:
	var nodes_to_remove := []

	for tracked_node in dot_dictionary.keys():
		if not is_instance_valid(tracked_node):
			nodes_to_remove.append(tracked_node)

	for tracked_node in nodes_to_remove:
		var dot = dot_dictionary[tracked_node]

		if is_instance_valid(dot):
			dot.queue_free()

		dot_dictionary.erase(tracked_node)
