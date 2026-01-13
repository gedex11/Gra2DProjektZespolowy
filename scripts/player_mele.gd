extends CharacterBody2D

const SPEED := 130.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var level = 1 
var health = 150
var armor = 12
var attackDamage = 15
var attackSpeed = 1.0


func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")

	# Normalizujemy, żeby postać nie chodziła szybciej po skosie
	input_vector = input_vector.normalized()
	
	
	

	velocity = input_vector * SPEED

	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true
		 
	if velocity.x == 0 and velocity.y == 0:
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("run")
	move_and_slide()
