extends CharacterBody2D
class_name Player

const BASE_SPEED := 100.0

@export var stats: PlayerStats
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $WeaponSocket/Hitbox
@onready var hitbox_shape: CollisionShape2D = $WeaponSocket/Hitbox/AttackRange
@onready var weapon_sprite: Sprite2D = $WeaponSocket/WeaponSprite

var inventory: Inventory = Inventory.new()
var equipped_weapon: WeaponItem
var can_attack: bool = true
@export var attack_cooldown: float = 0.4

var current_level: int = 1

func _ready() -> void:
	if stats == null:
		push_error("Brak przypisanego PlayerStats w Inspectorze!")
		return

	stats.changed.connect(_on_stats_changed)
	stats.current_hp = stats.max_hp
	current_level = stats.level
	stats.emit_changed()
	hitbox_shape.disabled = true
func _physics_process(delta: float) -> void:
	var input_vector := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()

	velocity = input_vector * BASE_SPEED * stats.speed_multiplier

	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true

	animated_sprite_2d.play("run" if velocity != Vector2.ZERO else "idle")
	move_and_slide()


func _on_stats_changed() -> void:
	if stats.level > current_level:
		_show_level_up_effect(stats.level)
		current_level = stats.level
		
	print("HP:", stats.current_hp, "/", stats.max_hp)
	print("AD: ", stats.attack_damage)

func _show_level_up_effect(new_level: int) -> void:
	var lbl = Label.new()
	lbl.text = "LEVEL UP! (" + str(new_level) + ")"
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0)) # Złoty
	lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	lbl.add_theme_constant_override("outline_size", 4)
	
	lbl.global_position = global_position + Vector2(-60, -50)
	lbl.z_index = 200
	get_tree().current_scene.add_child(lbl)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(lbl, "global_position", lbl.global_position + Vector2(0, -60), 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(lbl, "modulate:a", 0.0, 2.0).set_delay(0.5)
	
	var player_tween = get_tree().create_tween()
	player_tween.tween_property(animated_sprite_2d, "scale", Vector2(1.4, 1.4), 0.3).set_trans(Tween.TRANS_BOUNCE)
	player_tween.tween_property(animated_sprite_2d, "scale", Vector2(1.0, 1.0), 0.3).set_delay(0.3)
	
	tween.set_parallel(false)
	tween.tween_callback(lbl.queue_free)


func take_damage(amount: int) -> void:
	stats.take_damage(amount)

	if stats.current_hp <= 0:
		die()
		


func heal(amount: int) -> void:
	stats.heal(amount)
	
func add_exp(amount: int) -> void:
	stats.add_exp(amount)


func die() -> void:
	animated_sprite_2d.play("die")
	print("Gracz umarł")
	set_physics_process(false)
	set_process_input(false)
	
	await animated_sprite_2d.animation_finished
	
	# Przeniesienie do huba
	if get_tree() != null:
		get_tree().change_scene_to_file("res://scenes/levels/hub.tscn")


func _unhandled_key_input(event: InputEvent) -> void:
	
	if event.is_pressed() and event.keycode == KEY_K:
		print("DEBUG: Wymusza testowe obrażenia!")
		take_damage(9999)
		
func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("attack") and can_attack:
		attack()

	if event is InputEventKey:
		
		if event.is_pressed() and event.keycode == KEY_K:
			print("DEBUG: Wymusza testowe obrażenia!")
			take_damage(9999)
			
		if event.is_pressed() and event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var slot_index = event.keycode - KEY_1 
			_use_item_from_slot(slot_index)
		
var equipped_armor: ArmorItem = null

func _use_item_from_slot(slot_index: int) -> void:
	var item = inventory.get_item(slot_index)
	
	if item != null:
		if item is WeaponItem:
			if equipped_weapon == item:
				equipped_weapon = null
				weapon_sprite.visible = false
				print("Schowano broń.")
			else:
				equipped_weapon = item
				if item.icon: weapon_sprite.texture = item.icon 
				weapon_sprite.visible = true
				print("Wyciągnięto broń ze slotu ", slot_index + 1, ": ", item.name)
			inventory.changed.emit()
		elif item is ConsumableItem:
			heal(item.heal_amount)
			inventory.remove_item_at(slot_index)
			print("Użyto: ", item.name)
		elif item is ArmorItem:
			if equipped_armor == item:
				# Unequip
				stats.armor -= item.armor_bonus
				stats.max_hp -= item.max_hp_bonus
				stats.current_hp = max(1, stats.current_hp - item.max_hp_bonus)
				stats.current_hp = min(stats.current_hp, stats.max_hp)
				equipped_armor = null
				print("Zdjęto zbroję.")
			else:
				if equipped_armor != null:
					stats.armor -= equipped_armor.armor_bonus
					stats.max_hp -= equipped_armor.max_hp_bonus
					stats.current_hp = max(1, stats.current_hp - equipped_armor.max_hp_bonus)
					
				equipped_armor = item
				stats.armor += item.armor_bonus
				stats.max_hp += item.max_hp_bonus
				stats.current_hp += item.max_hp_bonus
				print("Założono zbroję ze slotu ", slot_index + 1, ": ", item.name)
			stats.emit_changed()
			inventory.changed.emit()

func attack() -> void:
	if equipped_weapon == null:
		print("Nie masz wyciągniętej broni!")
		return
		
	can_attack = false
	
	
	var dmg := stats.attack_damage + equipped_weapon.damage 
	
	if randf() < stats.crit_chance:
		dmg = int(dmg * stats.crit_damage)
		
	hitbox.set_meta("damage", dmg)
	hitbox.set_meta("attacker", self)
	hitbox_shape.set_deferred("disabled", false)
	
	# Animacja machnięcia bronią za pomocą Tween
	if weapon_sprite.visible:
		var tween = get_tree().create_tween()
		var start_rot = -45.0 if not animated_sprite_2d.flip_h else 45.0
		var end_rot = 90.0 if not animated_sprite_2d.flip_h else -90.0
		weapon_sprite.rotation_degrees = start_rot
		tween.tween_property(weapon_sprite, "rotation_degrees", end_rot, 0.15)
		tween.tween_callback(func(): weapon_sprite.rotation_degrees = 0)
	
	await get_tree().create_timer(0.15).timeout
	
	hitbox_shape.set_deferred("disabled", true)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
