extends Resource
class_name EnemyStats

@export_category("Podstawowe")
@export var enemy_name: String = "Sługus"
@export var max_hp: int = 60
@export var armor: int = 2

@export_category("Ofensywne")
@export var attack_damage: int = 12
@export var attack_speed: float = 1.0

@export_category("Mobilność")
@export var speed_multiplier: float = 0.85 

@export_category("Loot")
@export var exp_reward: int = 15 
@export var credits_drop_min: int = 1
@export var credits_drop_max: int = 5
