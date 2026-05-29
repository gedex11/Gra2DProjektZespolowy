extends CharacterBody2D
class_name Player

const BASE_SPEED := 130.0

@export var stats: PlayerStats 

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var inventory: Inventory
var equipped_weapon: WeaponItem

func _ready() -> void:
	inventory = Inventory.new()
	stats.changed.connect(_on_stats_changed)
	stats.current_hp = stats.max_hp

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
	pass
	
	
func take_damage(amount: int) -> void:
	stats.current_hp -= amount
	print("Gracz oberwał! Zostało HP: ", stats.current_hp)
