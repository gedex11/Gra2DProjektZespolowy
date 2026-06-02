extends ProgressBar

@onready var timer: Timer = $Timer
@onready var damage_bar: ProgressBar = $DamageBar

@export var stats: EnemyStats

func _ready() -> void:
	if stats:
		init_health(stats.max_hp)

func init_health(max_health: int) -> void:
	max_value = max_health
	value = max_health
	damage_bar.max_value = max_health
	damage_bar.value = max_health

func take_damage(new_health: int) -> void:
	value = new_health
	timer.stop()
	timer.start(0.6)

func _on_timer_timeout() -> void:
	var tween := create_tween()
	tween.tween_property(damage_bar, "value", value, 0.4) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)

func is_alive() -> bool:
	return value > 0

func get_hp_percent() -> float:
	return value / max_value
