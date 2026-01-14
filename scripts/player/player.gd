extends CharacterBody2D
class_name Player

const SPEED := 130.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var level := 1
var health := 150
var armor := 12
var attack_damage := 15
var attack_speed := 1.0

var inventory: Inventory
var equipped_weapon: WeaponItem

func _ready():
	inventory = Inventory.new()

func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")
	input_vector = input_vector.normalized()

	velocity = input_vector * SPEED

	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true

	if velocity == Vector2.ZERO:
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("run")

	move_and_slide()
