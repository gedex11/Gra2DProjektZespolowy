extends Node2D

# HUB
const HUB_SCENE := "uid://fvmkgve4iwtp"

# Scena przeciwnika respawnowanego w falach (ta sama co przeciwnik startowy).
const ENEMY_SCENE := preload("res://scenes/characters/enemy_1.tscn")

# Czy ukończenie tego poziomu odblokowuje Level 2.
@export var unlocks_level2: bool = false

# --- Konfiguracja fal (łatwa do zmiany, także per poziom w edytorze) ---
@export var wave_count: int = 3              # ile fal PO przeciwniku startowym (3–5)
@export var enemies_per_wave: int = 3        # ilu przeciwników na falę
@export var delay_between_waves: float = 2.0 # przerwa przed kolejną falą (sekundy)

# Obszar losowego spawnu wokół gracza (nieregularnie, nie tuż obok).
@export var spawn_min_radius: float = 60.0
@export var spawn_max_radius: float = 150.0

# Wzmocnienie kolejnych fal (globalnie). Co falę losowo dokładamy HP ALBO DMG.
@export var hp_step: float = 0.15            # +15% HP gdy fala wylosuje HP
@export var dmg_step: float = 0.15           # +15% DMG gdy fala wylosuje DMG

var _current_wave: int = 0      # 0 = przeciwnik startowy, 1..wave_count = fale
var _is_busy: bool = false      # blokada w trakcie odliczania między falami
var _level_finished: bool = false
var _level_number: int = 1

func _ready() -> void:
	if get_tree() and get_tree().current_scene:
		var s_path = get_tree().current_scene.scene_file_path.to_lower()
		if "2" in s_path: _level_number = 2
		elif "3" in s_path: _level_number = 3
		elif "4" in s_path: _level_number = 4
		
	var difficulty_mult = 1.0 + (_level_number - 1) * 0.1 # +10% statystyk na poziom
	
	enemies_per_wave += (_level_number - 1) # Dodaj +1 przeciwnika na falę co poziom
	
	# Podłącz się pod zniknięcie przeciwnika startowego i przeskaluj mu statystyki
	for enemy in get_tree().get_nodes_in_group("minimap_enemy"):
		enemy.tree_exited.connect(_on_enemy_removed)
		var s: EnemyStats = enemy.stats.duplicate()
		s.max_hp = max(1, int(round(s.max_hp * difficulty_mult)))
		s.attack_damage = max(1, int(round(s.attack_damage * difficulty_mult)))
		enemy.stats = s
		
	call_deferred("_spawn_chest")

func _spawn_chest() -> void:
	var chest_scene = load("res://scenes/items/chest.tscn")
	if chest_scene:
		var chest = chest_scene.instantiate()
		var player = get_tree().get_first_node_in_group("player")
		var center: Vector2 = player.global_position if player != null else global_position
		chest.global_position = _random_spawn_point(center)
		# Losowy loot
		var pot = load("res://resources/items/health_potion.tres")
		var arm1 = load("res://resources/items/iron_armor.tres")
		var arm2 = load("res://resources/items/leather_armor.tres")
		var sword = load("res://resources/items/iron_sword.tres")
		
		if randf() < 0.7: 
			chest.items_inside.append(pot)
			
		var r = randf()
		if r < 0.33: chest.items_inside.append(arm1)
		elif r < 0.66: chest.items_inside.append(arm2)
		else: chest.items_inside.append(sword)
		
		add_child(chest)

func _on_enemy_removed() -> void:
	if _level_finished or _is_busy: return
	
	# Poczekaj klatkę, aż wróg zostanie usunięty z drzewa, potem policz pozostałych.
	if not is_inside_tree(): return
	await get_tree().process_frame
	if not is_inside_tree(): return

	if _level_finished or _is_busy:
		return

	# Dopóki żyje choć jeden przeciwnik z aktualnej fali — nic nie robimy.
	if not get_tree().get_nodes_in_group("minimap_enemy").is_empty():
		return

	# Grupa pusta: albo startujemy kolejną falę, albo kończymy poziom.
	if _current_wave < wave_count:
		_is_busy = true
		await get_tree().create_timer(delay_between_waves).timeout
		_current_wave += 1
		_spawn_wave()
		_is_busy = false
	else:
		_complete_level()

func _spawn_wave() -> void:
	# Globalny postęp: ta fala jest mocniejsza od poprzedniej (losowo HP albo DMG).
	GameState.global_wave_index += 1
	if randf() < 0.5:
		GameState.wave_hp_mult += hp_step
	else:
		GameState.wave_dmg_mult += dmg_step

	var player := get_tree().get_first_node_in_group("player")
	var center: Vector2 = player.global_position if player != null else global_position

	for i in enemies_per_wave:
		var enemy := ENEMY_SCENE.instantiate()

		# Własna kopia statystyk — skalujemy o mnożnik fali ORAZ mnożnik poziomu.
		var s: EnemyStats = enemy.stats.duplicate()
		var diff_mult = 1.0 + (_level_number - 1) * 0.1
		s.max_hp = max(1, int(round(s.max_hp * GameState.wave_hp_mult * diff_mult)))
		s.attack_damage = max(1, int(round(s.attack_damage * GameState.wave_dmg_mult * diff_mult)))
		enemy.stats = s

		add_child(enemy)
		enemy.global_position = _random_spawn_point(center)
		enemy.z_index = 30
		# Reużywamy istniejącego AI — od razu wskazujemy cel.
		if player != null:
			enemy.target = player
		enemy.tree_exited.connect(_on_enemy_removed)

func _random_spawn_point(center: Vector2) -> Vector2:
	var angle := randf() * TAU
	var dist := randf_range(spawn_min_radius, spawn_max_radius)
	return center + Vector2(dist, 0.0).rotated(angle)

func _complete_level() -> void:
	if _level_finished:
		return
	_level_finished = true

	if _level_number == 1: GameState.level2_unlocked = true
	elif _level_number == 2: GameState.level3_unlocked = true
	elif _level_number == 3: GameState.level4_unlocked = true

	# Czekamy sekundę, aby gracz mógł zobaczyć koniec poziomu,
	# i żeby silnik fizyki mógł bezpiecznie wyczyścić usunięte obiekty (zapobiega to Crashom Signal 11)
	await get_tree().create_timer(1.0).timeout

	get_tree().call_deferred("change_scene_to_file", HUB_SCENE)
