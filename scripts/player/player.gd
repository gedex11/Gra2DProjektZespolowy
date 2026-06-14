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

func _ready() -> void:

	if stats == null:
		push_error("Brak przypisanego PlayerStats w Inspectorze!")
		return

	stats.changed.connect(_on_stats_changed)
	stats.current_hp = stats.max_hp
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
	print("HP:", stats.current_hp, "/", stats.max_hp)
	print("AD: ", stats.attack_damage)


func take_damage(amount: int) -> void:
	stats.take_damage(amount)

	if stats.current_hp <= 0:
		die()
		


func heal(amount: int) -> void:
	stats.heal(amount)


func die() -> void:
	animated_sprite_2d.play("die")
	print("Gracz umarł")
	set_physics_process(false)
	set_process_input(false)
	
	
	await animated_sprite_2d.animation_finished
	
	
	#dodac przeniesienie do huba 
	
	

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
			_equip_weapon_from_slot(slot_index)
		
func _equip_weapon_from_slot(slot_index: int) -> void:
	var item = inventory.get_item(slot_index)
	
	if item != null and item is WeaponItem:
		if equipped_weapon == item:
			equipped_weapon = null
			weapon_sprite.visible = false
			print("Schowano broń.")
		else:
			equipped_weapon = item
			
			# TUTAJ ZMIANA: używamy 'icon' zamiast 'texture'
			weapon_sprite.texture = item.icon 
			
			weapon_sprite.visible = true
			print("Wyciągnięto broń ze slotu ", slot_index + 1, ": ", item.name)

func attack() -> void:
	if equipped_weapon == null:
		print("Nie masz wyciągniętej broni!")
		return
		
	can_attack = false
	
	
	var dmg := stats.attack_damage + equipped_weapon.damage 
	
	if randf() < stats.crit_chance:
		dmg = int(dmg * stats.crit_damage)
		
	hitbox.set_meta("damage", dmg)
	hitbox_shape.set_deferred("disabled", false)
	
	await get_tree().create_timer(0.15).timeout
	
	hitbox_shape.set_deferred("disabled", true)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
