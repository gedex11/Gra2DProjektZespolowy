extends CharacterBody2D
class_name Enemy

@export var stats: EnemyStats
@onready var detection_area: Area2D = $DetectionArea
@onready var hurtbox: Area2D = $HurtBox
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var contact_timer: Timer = $ContactTimer
@onready var health_bar = $HealthBar
@onready var attack_area: Area2D = $AttackArea 

const BASE_SPEED := 70.0

var current_hp: int
var target: Player = null
var is_dead: bool = false
var is_in_attack_range: bool = false 

func _ready() -> void:
	current_hp = stats.max_hp
	health_bar.init_health(stats.max_hp)
	contact_timer.wait_time = 1.0 / stats.attack_speed
	contact_timer.one_shot = false

	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)
	
	attack_area.body_entered.connect(_on_attack_area_entered)
	attack_area.body_exited.connect(_on_attack_area_exited)
	
	hurtbox.area_entered.connect(_on_hit_by_player)
	contact_timer.timeout.connect(_on_contact_timer_timeout)

func _physics_process(_delta: float) -> void:
	if is_dead or target == null:
		animated_sprite.play("idle")
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if is_in_attack_range:
		animated_sprite.play("idle") # Podmienic na animacje do atakowania 
		velocity = Vector2.ZERO
		
		var distance_x = target.global_position.x - global_position.x
		animated_sprite.flip_h = distance_x < 0
		
		move_and_slide()
		return

	var direction := (target.global_position - global_position).normalized()
	velocity = direction * BASE_SPEED * stats.speed_multiplier
	animated_sprite.flip_h = velocity.x < 0
	animated_sprite.play("patrol")
	move_and_slide()
	
	
func _on_player_entered(body: Node2D) -> void:
	if body is Player:
		target = body

func _on_player_exited(body: Node2D) -> void:
	if body is Player:
		target = null
		is_in_attack_range = false
		contact_timer.stop()

func _on_attack_area_entered(body: Node2D) -> void:
	if body is Player:
		is_in_attack_range = true
		contact_timer.start()
		_deal_damage_to_player()

func _on_attack_area_exited(body: Node2D) -> void:
	if body is Player:
		is_in_attack_range = false
		contact_timer.stop()

func _on_contact_timer_timeout() -> void:
	_deal_damage_to_player()

func _deal_damage_to_player() -> void:
	if target != null and not is_dead and is_in_attack_range:
		target.take_damage(stats.attack_damage)

func _on_hit_by_player(area: Area2D) -> void:
	if is_dead:
		return
	var dmg: int = area.get_meta("damage", 0)
	take_damage(dmg)

func take_damage(raw_damage: int) -> void:
	if is_dead:
		return
	var mitigated := int(raw_damage * (100.0 / (100.0 + stats.armor)))
	current_hp = max(0, current_hp - mitigated)
	health_bar.take_damage(current_hp)

	_flash_hit()

	if current_hp <= 0:
		_die()

func _flash_hit() -> void:
	animated_sprite.modulate = Color(2.0, 2.0, 2.0)
	await get_tree().create_timer(0.08).timeout
	animated_sprite.modulate = Color.WHITE

func _die() -> void:
	is_dead = true
	contact_timer.stop()
	velocity = Vector2.ZERO
	var credits := randi_range(stats.credits_drop_min, stats.credits_drop_max)
	queue_free()
